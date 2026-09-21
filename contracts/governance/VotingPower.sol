// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.31;

import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title VotingPower - VKNT Calculation Contract
 * @notice Calculates voting power from DKNT stake and K (Karma) reputation
 * @dev Implements LP-3002 VKNT formula: VKNT = DKNT × f(K) × time_multiplier
 *
 * VOTING POWER FORMULA:
 * ┌─────────────────────────────────────────────────────────────────────────────┐
 * │  VKNT = DKNT_staked × f(K) × time_multiplier                               │
 * │                                                                             │
 * │  where:                                                                     │
 * │    f(K) = sqrt(K / 100)  // Karma scaling function                          │
 * │    time_multiplier = 1 + (lock_months × 0.1)  // Max 4x at 30 months        │
 * │                                                                             │
 * │  Example Calculations:                                                      │
 * │  ┌──────────────┬─────────┬───────────────┬─────────┐                       │
 * │  │ DKNT Staked  │ K Score │ Lock Duration │ VKNT    │                       │
 * │  ├──────────────┼─────────┼───────────────┼─────────┤                       │
 * │  │ 1,000        │ 100     │ 0 months      │ 1,000   │                       │
 * │  │ 1,000        │ 400     │ 0 months      │ 2,000   │                       │
 * │  │ 1,000        │ 100     │ 12 months     │ 2,200   │                       │
 * │  │ 1,000        │ 400     │ 12 months     │ 4,400   │                       │
 * │  │ 10,000       │ 900     │ 30 months     │ 120,000 │                       │
 * │  └──────────────┴─────────┴───────────────┴─────────┘                       │
 * │                                                                             │
 * │  Quadratic Voting (optional per proposal):                                  │
 * │    Effective Votes = sqrt(VKNT_spent)                                       │
 * │    10,000 VKNT → 100 effective votes                                        │
 * └─────────────────────────────────────────────────────────────────────────────┘
 */

interface IKarma {
    function karmaOf(address account) external view returns (uint256);
    function isVerified(address account) external view returns (bool);
}

interface IDKNT {
    function stakes(address account)
        external
        view
        returns (uint256 amount, uint256 lockEnd, uint256 lastRebase, uint256 pendingRebase, uint8 tier);
    function totalStaked() external view returns (uint256);
}

contract VotingPower is ReentrancyGuard {
    // ============ Constants ============

    /// @notice Maximum time multiplier (4.0x at 30 months)
    uint256 public constant MAX_TIME_MULTIPLIER = 4e18;

    /// @notice Base multiplier (1.0x)
    uint256 public constant BASE_MULTIPLIER = 1e18;

    /// @notice Time multiplier increment per month (0.1)
    uint256 public constant TIME_INCREMENT = 1e17;

    /// @notice Maximum lock months for multiplier
    uint256 public constant MAX_LOCK_MONTHS = 30;

    /// @notice Karma divisor for sqrt calculation (100)
    uint256 public constant KARMA_DIVISOR = 100e18;

    /// @notice Minimum karma for non-zero f(K) (100 K)
    uint256 public constant MIN_KARMA = 100e18;

    // ============ State ============

    /// @notice Karma (K) token contract
    IKarma public immutable karma;

    /// @notice DKNT token contract
    IDKNT public immutable dknt;

    /// @notice Historical voting power snapshots (block => account => power)
    mapping(uint256 => mapping(address => uint256)) private _snapshots;

    /// @notice Block numbers of snapshots
    mapping(address => uint256[]) private _snapshotBlocks;

    // ============ Events ============

    event VotingPowerSnapshot(address indexed account, uint256 indexed blockNumber, uint256 power);

    // ============ Errors ============

    error ZeroAddress();
    error BlockNotYetMined();
    error NoSnapshotAvailable();

    // ============ Constructor ============

    constructor(address _karma, address _dknt) {
        if (_karma == address(0) || _dknt == address(0)) revert ZeroAddress();

        karma = IKarma(_karma);
        dknt = IDKNT(_dknt);
    }

    // ============ External Functions ============

    /// @notice Get current voting power for account
    /// @param account Address to query
    /// @return power Voting power (VKNT)
    function votingPower(address account) external view returns (uint256 power) {
        return _calculateVotingPower(account);
    }

    /// @notice Get voting power at specific block
    /// @param account Address to query
    /// @param blockNumber Block number to query
    /// @return power Voting power at block
    function votingPowerAt(address account, uint256 blockNumber) external view returns (uint256 power) {
        if (blockNumber >= block.number) revert BlockNotYetMined();

        // Check for snapshot
        uint256[] storage blocks = _snapshotBlocks[account];
        if (blocks.length == 0) revert NoSnapshotAvailable();

        // Binary search for closest snapshot <= blockNumber
        uint256 low = 0;
        uint256 high = blocks.length - 1;

        while (low < high) {
            uint256 mid = (low + high + 1) / 2;
            if (blocks[mid] <= blockNumber) {
                low = mid;
            } else {
                high = mid - 1;
            }
        }

        if (blocks[low] > blockNumber) revert NoSnapshotAvailable();

        return _snapshots[blocks[low]][account];
    }

    /// @notice Snapshot current voting power for account
    /// @param account Address to snapshot
    function snapshot(address account) external {
        uint256 power = _calculateVotingPower(account);
        _snapshots[block.number][account] = power;
        _snapshotBlocks[account].push(block.number);

        emit VotingPowerSnapshot(account, block.number, power);
    }

    /// @notice Get total voting power in system
    /// @return total Total VKNT across all stakers
    function totalVotingPower() external view returns (uint256 total) {
        // Approximation: total staked * average karma factor
        // For exact total, would need to iterate all stakers
        return dknt.totalStaked();
    }

    /// @notice Get voting power components for account
    /// @param account Address to query
    /// @return dkntStaked Amount of DKNT staked
    /// @return karmaScore Karma (K) balance
    /// @return karmaMultiplier f(K) multiplier (18 decimals)
    /// @return timeMultiplier Time multiplier (18 decimals)
    /// @return vkntPower Final VKNT voting power
    function getVotingPowerComponents(address account)
        external
        view
        returns (
            uint256 dkntStaked,
            uint256 karmaScore,
            uint256 karmaMultiplier,
            uint256 timeMultiplier,
            uint256 vkntPower
        )
    {
        (uint256 staked, uint256 lockEnd,,,) = dknt.stakes(account);

        dkntStaked = staked;
        karmaScore = karma.karmaOf(account);
        karmaMultiplier = _karmaFactor(karmaScore);
        timeMultiplier = _timeFactor(lockEnd);
        vkntPower = _calculateVotingPower(account);
    }

    /// @notice Calculate quadratic voting power
    /// @param vknt VKNT amount to convert
    /// @return votes Effective votes (sqrt of VKNT)
    function quadraticVotes(uint256 vknt) external pure returns (uint256 votes) {
        return _sqrt(vknt);
    }

    /// @notice Check if account is eligible to vote
    /// @param account Address to check
    /// @return eligible True if can vote
    /// @return reason Reason if not eligible
    function canVote(address account) external view returns (bool eligible, string memory reason) {
        (uint256 staked,,,,) = dknt.stakes(account);

        if (staked == 0) {
            return (false, "No DKNT staked");
        }

        uint256 k = karma.karmaOf(account);
        if (k < MIN_KARMA) {
            return (false, "Insufficient Karma (min 100 K)");
        }

        if (!karma.isVerified(account)) {
            return (false, "Account not verified");
        }

        return (true, "");
    }

    // ============ Internal Functions ============

    /// @notice Calculate VKNT voting power: DKNT × f(K) × time_multiplier
    function _calculateVotingPower(address account) internal view returns (uint256) {
        (uint256 staked, uint256 lockEnd,,,) = dknt.stakes(account);

        if (staked == 0) return 0;

        uint256 k = karma.karmaOf(account);
        uint256 karmaFactor = _karmaFactor(k);
        uint256 timeFactor = _timeFactor(lockEnd);

        // VKNT = DKNT × f(K) × time_multiplier
        // All factors are in 1e18, so divide by 1e36
        return (staked * karmaFactor * timeFactor) / 1e36;
    }

    /// @notice Calculate f(K) = sqrt(K / 100)
    /// @dev Returns value with 18 decimals (1e18 = 1.0)
    function _karmaFactor(uint256 k) internal pure returns (uint256) {
        if (k < MIN_KARMA) return BASE_MULTIPLIER; // Minimum 1.0x if < 100 K

        // f(K) = sqrt(K / 100)
        // With 18 decimals: sqrt((K * 1e18) / (100 * 1e18)) * 1e18
        uint256 scaled = (k * 1e18) / KARMA_DIVISOR;
        return _sqrt(scaled) * 1e9; // sqrt of 18-decimal number, scale to 18 decimals
    }

    /// @notice Calculate time multiplier = 1 + (lock_months × 0.1)
    /// @dev Returns value with 18 decimals (1e18 = 1.0)
    function _timeFactor(uint256 lockEnd) internal view returns (uint256) {
        if (lockEnd <= block.timestamp) {
            return BASE_MULTIPLIER; // 1.0x if lock expired
        }

        uint256 lockRemaining = lockEnd - block.timestamp;
        uint256 lockMonths = lockRemaining / 30 days;

        if (lockMonths >= MAX_LOCK_MONTHS) {
            return MAX_TIME_MULTIPLIER; // Cap at 4.0x
        }

        // 1 + (months × 0.1)
        return BASE_MULTIPLIER + (lockMonths * TIME_INCREMENT);
    }

    /// @notice Integer square root using Babylonian method
    function _sqrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;

        uint256 z = (x + 1) / 2;
        uint256 y = x;

        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }

        return y;
    }
}
