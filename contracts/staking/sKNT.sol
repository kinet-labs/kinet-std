// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.31;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title sKNT - Staked KNT
 * @notice Yield-bearing staked KNT token for Liquid protocol
 * @dev Users stake KNT to receive sKNT which accrues staking rewards
 *
 * KNT FEE ARCHITECTURE (differs from Avalanche):
 * ┌─────────────────────────────────────────────────────────────┐
 * │  Tx Fees ──► Protocol Vault ──► DAO Governance              │
 * │                                      │                      │
 * │              ┌───────────────────────┼────────────┐         │
 * │              ▼           ▼           ▼            ▼         │
 * │           Burn %    Stakers %   Delegators %   Dev Fund     │
 * │          (optional)   (sKNT)    (validators)                │
 * └─────────────────────────────────────────────────────────────┘
 *
 * Key differences from Avalanche:
 * - No automatic fee burning (EIP-1559 burn disabled)
 * - All coinbase rewards → Protocol Vault (C-Chain)
 * - DAO governs allocation percentages
 * - sKNT receives yield via addRewards() from Protocol Vault
 *
 * sKNT can be used as collateral in LiquidVault to mint L* tokens
 */
contract sKNT is ERC20, ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    /// @notice The underlying KNT token (WKNT)
    IERC20 public immutable knt;

    /// @notice Total KNT staked (includes rewards)
    uint256 public totalStaked;

    /// @notice Annual percentage yield (basis points, e.g., 1100 = 11%)
    /// @dev This is the TARGET APY - actual yield comes from Protocol Vault distributions
    uint256 public apy = 1100; // 11% default - DAO governed

    /// @notice Last time rewards were distributed
    uint256 public lastRewardTime;

    /// @notice Protocol Vault address (receives all tx fees, distributes to sKNT)
    address public protocolVault;

    /// @notice Pending rewards to be distributed (for simulated yield in testing)
    uint256 public pendingRewards;

    /// @notice Minimum stake amount
    uint256 public constant MIN_STAKE = 1e18; // 1 KNT

    /// @notice Cooldown period for unstaking (seconds)
    uint256 public cooldownPeriod = 7 days;

    /// @notice User cooldown timestamps
    mapping(address => uint256) public cooldownStart;
    mapping(address => uint256) public cooldownAmount;

    // Events
    event Staked(address indexed user, uint256 kntAmount, uint256 sKntMinted);
    event Unstaked(address indexed user, uint256 sKntBurned, uint256 kntReturned);
    event CooldownStarted(address indexed user, uint256 amount);
    event RewardsDistributed(uint256 amount);
    event APYUpdated(uint256 newAPY);
    event ProtocolVaultUpdated(address indexed oldVault, address indexed newVault);

    // Errors
    error OnlyProtocolVault();
    error InvalidProtocolVault();

    constructor(address _knt) ERC20("Staked KNT", "sKNT") Ownable(msg.sender) {
        knt = IERC20(_knt);
        lastRewardTime = block.timestamp;
    }

    /// @notice Get the exchange rate of sKNT to KNT
    /// @return Exchange rate scaled by 1e18
    function exchangeRate() public view returns (uint256) {
        uint256 supply = totalSupply();
        if (supply == 0) return 1e18;
        return (totalStaked * 1e18) / supply;
    }

    /// @notice Preview how much sKNT will be minted for a KNT deposit
    function previewDeposit(uint256 kntAmount) public view returns (uint256) {
        uint256 supply = totalSupply();
        if (supply == 0) return kntAmount;
        return (kntAmount * supply) / totalStaked;
    }

    /// @notice Preview how much KNT will be returned for sKNT redemption
    function previewRedeem(uint256 sKntAmount) public view returns (uint256) {
        uint256 supply = totalSupply();
        if (supply == 0) return sKntAmount;
        return (sKntAmount * totalStaked) / supply;
    }

    /// @notice Stake KNT to receive sKNT
    /// @param kntAmount Amount of KNT to stake
    /// @return sKntMinted Amount of sKNT minted
    function stake(uint256 kntAmount) external nonReentrant returns (uint256 sKntMinted) {
        require(kntAmount >= MIN_STAKE, "sKNT: below minimum stake");

        // Accrue rewards first
        _accrueRewards();

        // Calculate sKNT to mint
        sKntMinted = previewDeposit(kntAmount);
        require(sKntMinted > 0, "sKNT: zero shares");

        // Transfer KNT from user
        knt.safeTransferFrom(msg.sender, address(this), kntAmount);

        // Update state
        totalStaked += kntAmount;
        _mint(msg.sender, sKntMinted);

        emit Staked(msg.sender, kntAmount, sKntMinted);
    }

    /// @notice Start cooldown to unstake
    /// @param sKntAmount Amount of sKNT to unstake
    function startCooldown(uint256 sKntAmount) external {
        require(balanceOf(msg.sender) >= sKntAmount, "sKNT: insufficient balance");
        cooldownStart[msg.sender] = block.timestamp;
        cooldownAmount[msg.sender] = sKntAmount;
        emit CooldownStarted(msg.sender, sKntAmount);
    }

    /// @notice Unstake sKNT after cooldown to receive KNT
    /// @return kntReturned Amount of KNT returned
    function unstake() external nonReentrant returns (uint256 kntReturned) {
        uint256 sKntAmount = cooldownAmount[msg.sender];
        require(sKntAmount > 0, "sKNT: no cooldown active");
        require(block.timestamp >= cooldownStart[msg.sender] + cooldownPeriod, "sKNT: cooldown not complete");
        require(balanceOf(msg.sender) >= sKntAmount, "sKNT: insufficient balance");

        // Accrue rewards first
        _accrueRewards();

        // Calculate KNT to return
        kntReturned = previewRedeem(sKntAmount);
        require(kntReturned > 0, "sKNT: zero assets");
        require(kntReturned <= totalStaked, "sKNT: insufficient staked");

        // Clear cooldown
        cooldownStart[msg.sender] = 0;
        cooldownAmount[msg.sender] = 0;

        // Update state
        totalStaked -= kntReturned;
        _burn(msg.sender, sKntAmount);

        // Transfer KNT to user
        knt.safeTransfer(msg.sender, kntReturned);

        emit Unstaked(msg.sender, sKntAmount, kntReturned);
    }

    /// @notice Instant unstake with penalty (for testing/emergency)
    /// @param sKntAmount Amount of sKNT to unstake
    /// @return kntReturned Amount of KNT returned (after 10% penalty)
    function instantUnstake(uint256 sKntAmount) external nonReentrant returns (uint256 kntReturned) {
        require(balanceOf(msg.sender) >= sKntAmount, "sKNT: insufficient balance");

        _accrueRewards();

        // Calculate KNT with 10% penalty
        uint256 kntAmount = previewRedeem(sKntAmount);
        kntReturned = (kntAmount * 90) / 100; // 10% penalty
        require(kntReturned <= totalStaked, "sKNT: insufficient staked");

        // Update state
        totalStaked -= kntReturned;
        _burn(msg.sender, sKntAmount);

        knt.safeTransfer(msg.sender, kntReturned);

        emit Unstaked(msg.sender, sKntAmount, kntReturned);
    }

    /// @notice Distribute rewards (called by keeper or anyone)
    function distributeRewards() external {
        _accrueRewards();
    }

    /// @notice Add rewards to the pool (called by Protocol Vault)
    /// @dev In production, only protocolVault can call. For testing, owner can also call.
    /// @param amount Amount of KNT to add as rewards
    function addRewards(uint256 amount) external {
        // Allow protocolVault or owner (for testing/bootstrapping)
        require(msg.sender == protocolVault || msg.sender == owner(), "sKNT: not authorized");
        knt.safeTransferFrom(msg.sender, address(this), amount);
        totalStaked += amount;
        emit RewardsDistributed(amount);
    }

    /// @notice Set the Protocol Vault address (DAO controlled)
    /// @param newVault Address of the Protocol Vault contract
    function setProtocolVault(address newVault) external onlyOwner {
        if (newVault == address(0)) revert InvalidProtocolVault();
        address oldVault = protocolVault;
        protocolVault = newVault;
        emit ProtocolVaultUpdated(oldVault, newVault);
    }

    /// @notice Set the APY (owner only)
    /// @param newAPY New APY in basis points
    function setAPY(uint256 newAPY) external onlyOwner {
        require(newAPY <= 5000, "sKNT: APY too high"); // Max 50%
        _accrueRewards();
        apy = newAPY;
        emit APYUpdated(newAPY);
    }

    /// @notice Set cooldown period (owner only)
    function setCooldownPeriod(uint256 newPeriod) external onlyOwner {
        require(newPeriod <= 30 days, "sKNT: cooldown too long");
        cooldownPeriod = newPeriod;
    }

    /// @dev Accrue pending rewards to totalStaked
    /// @notice In production, rewards are added via addRewards() from Protocol Vault.
    function _accrueRewards() internal {
        if (totalStaked == 0) {
            lastRewardTime = block.timestamp;
            return;
        }

        // If there are pending rewards, add them to totalStaked
        if (pendingRewards > 0) {
            totalStaked += pendingRewards;
            emit RewardsDistributed(pendingRewards);
            pendingRewards = 0;
        }

        lastRewardTime = block.timestamp;
    }

    /// @notice Queue rewards for drip distribution (called by Protocol Vault)
    /// @param amount Amount of KNT to queue for next accrual
    function queueRewards(uint256 amount) external {
        require(msg.sender == protocolVault || msg.sender == owner(), "sKNT: not authorized");
        knt.safeTransferFrom(msg.sender, address(this), amount);
        pendingRewards += amount;
    }

    /// @notice Simulate APY yield for testing
    /// @dev For testnet/development only - simulates Protocol Vault distributions
    function simulateYield() external onlyOwner {
        if (totalStaked == 0) return;

        uint256 timeElapsed = block.timestamp - lastRewardTime;
        if (timeElapsed == 0) return;

        // Calculate simulated rewards based on target APY
        uint256 rewards = (totalStaked * apy * timeElapsed) / (365 days * 10000);

        if (rewards > 0) {
            totalStaked += rewards;
            lastRewardTime = block.timestamp;
            emit RewardsDistributed(rewards);
        }
    }
}
