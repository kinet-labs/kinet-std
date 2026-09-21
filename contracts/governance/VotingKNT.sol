// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.31;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title VotingKNT
 * @author kinet labs
 * @notice Aggregates voting power: vKNT = xKNT + DKNT
 *
 * GOVERNANCE FORMULA:
 * ┌─────────────────────────────────────────────────────────────────────────────┐
 * │                                                                             │
 * │   vKNT (Voting Power) = xKNT (Liquid Staked) + DKNT (Governance Token)     │
 * │                                                                             │
 * │   • xKNT: Yield-bearing liquid staked KNT (from LiquidKNT vault)           │
 * │   • DKNT: OHM-style governance token (vote-only, no yield)                 │
 * │   • vKNT: Non-transferable aggregated voting power                         │
 * │                                                                             │
 * └─────────────────────────────────────────────────────────────────────────────┘
 *
 * This contract provides read-only aggregation of voting power.
 * It is NOT transferable (no transfer/approve functions).
 * Used by VotingWeightVKNT adapter for Strategy voting weight calculation.
 *
 * NOTE: This is separate from the existing vKNT.sol which uses ve-tokenomics.
 * The existing vKNT remains for backwards compatibility.
 */
contract VotingKNT {
    /// @notice xKNT token (LiquidKNT shares)
    IERC20 public immutable xKNT;

    /// @notice DKNT governance token
    IERC20 public immutable dKNT;

    /// @notice Token metadata
    string public constant name = "Voting KNT";
    string public constant symbol = "vKNT2"; // vKNT2 to differentiate from existing vKNT
    uint8 public constant decimals = 18;

    // ============ Errors ============

    error NonTransferable();

    // ============ Constructor ============

    constructor(address _xKNT, address _dKNT) {
        require(_xKNT != address(0) && _dKNT != address(0), "Invalid address");
        xKNT = IERC20(_xKNT);
        dKNT = IERC20(_dKNT);
    }

    // ============ ERC20-like View Functions (Read Only) ============

    /**
     * @notice Get voting power for an address
     * @param account The address to query
     * @return Aggregated voting power (xKNT + DKNT balance)
     */
    function balanceOf(address account) external view returns (uint256) {
        return xKNT.balanceOf(account) + dKNT.balanceOf(account);
    }

    /**
     * @notice Get total voting power across all holders
     * @return Aggregated total supply (xKNT + DKNT supply)
     */
    function totalSupply() external view returns (uint256) {
        return xKNT.totalSupply() + dKNT.totalSupply();
    }

    // ============ Checkpointed Voting (if tokens support ERC20Votes) ============

    /**
     * @notice Get past voting power at a specific block
     * @dev Falls back to current balance if tokens don't support getPastVotes
     * @param account The address to query
     * @param blockNumber The block number to query
     * @return Aggregated past voting power
     */
    function getPastVotes(address account, uint256 blockNumber) external view returns (uint256) {
        uint256 xKntVotes = _getPastVotes(address(xKNT), account, blockNumber);
        uint256 dKntVotes = _getPastVotes(address(dKNT), account, blockNumber);
        return xKntVotes + dKntVotes;
    }

    /**
     * @notice Get past total supply at a specific block
     * @param blockNumber The block number to query
     * @return Aggregated past total supply
     */
    function getPastTotalSupply(uint256 blockNumber) external view returns (uint256) {
        uint256 xKntSupply = _getPastTotalSupply(address(xKNT), blockNumber);
        uint256 dKntSupply = _getPastTotalSupply(address(dKNT), blockNumber);
        return xKntSupply + dKntSupply;
    }

    // ============ Non-Transferable ============

    /**
     * @notice Transfer is disabled - voting power is non-transferable
     */
    function transfer(address, uint256) external pure returns (bool) {
        revert NonTransferable();
    }

    /**
     * @notice TransferFrom is disabled - voting power is non-transferable
     */
    function transferFrom(address, address, uint256) external pure returns (bool) {
        revert NonTransferable();
    }

    /**
     * @notice Approve is disabled - voting power is non-transferable
     */
    function approve(address, uint256) external pure returns (bool) {
        revert NonTransferable();
    }

    /**
     * @notice Allowance always returns 0
     */
    function allowance(address, address) external pure returns (uint256) {
        return 0;
    }

    // ============ Component Breakdown ============

    /**
     * @notice Get breakdown of voting power components
     * @param account The address to query
     * @return xKntBalance xKNT component
     * @return dKntBalance DKNT component
     * @return total Total voting power
     */
    function getVotingPowerBreakdown(address account)
        external
        view
        returns (uint256 xKntBalance, uint256 dKntBalance, uint256 total)
    {
        xKntBalance = xKNT.balanceOf(account);
        dKntBalance = dKNT.balanceOf(account);
        total = xKntBalance + dKntBalance;
    }

    // ============ Internal ============

    /**
     * @dev Try to get past votes, fallback to current balance
     */
    function _getPastVotes(address token, address account, uint256 blockNumber) internal view returns (uint256) {
        // Try ERC20Votes interface
        (bool success, bytes memory data) =
            token.staticcall(abi.encodeWithSignature("getPastVotes(address,uint256)", account, blockNumber));

        if (success && data.length >= 32) {
            return abi.decode(data, (uint256));
        }

        // Fallback to current balance
        return IERC20(token).balanceOf(account);
    }

    /**
     * @dev Try to get past total supply, fallback to current supply
     */
    function _getPastTotalSupply(address token, uint256 blockNumber) internal view returns (uint256) {
        // Try ERC20Votes interface
        (bool success, bytes memory data) =
            token.staticcall(abi.encodeWithSignature("getPastTotalSupply(uint256)", blockNumber));

        if (success && data.length >= 32) {
            return abi.decode(data, (uint256));
        }

        // Fallback to current supply
        return IERC20(token).totalSupply();
    }
}
