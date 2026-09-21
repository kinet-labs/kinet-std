// SPDX-License-Identifier: BSD-3-Clause
// Copyright (c) 2025 kinet labs.
pragma solidity ^0.8.31;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IKRC20 } from "../interfaces/IKRC20.sol";

/**
 * @title SafeKRC20
 * @author Kinet Network
 * @notice Safe wrapper for KRC20/ERC20 token transfers
 * @dev Wraps OpenZeppelin's SafeERC20 for Knt naming consistency
 *
 * WHY USE THIS:
 * - Standard `transfer` and `transferFrom` can fail silently (return false)
 * - Some tokens don't return a value (USDT, BNB)
 * - SafeKRC20 reverts on failure, preventing loss of funds
 *
 * USAGE:
 * ```solidity
 * using SafeKRC20 for IKRC20;
 * token.safeTransfer(recipient, amount);
 * token.safeTransferFrom(sender, recipient, amount);
 * token.safeIncreaseAllowance(spender, addedValue);
 * ```
 */
library SafeKRC20 {
    using SafeERC20 for IERC20;

    /**
     * @notice Safely transfer tokens, reverts on failure
     * @param token Token to transfer
     * @param to Recipient address
     * @param value Amount to transfer
     */
    function safeTransfer(IKRC20 token, address to, uint256 value) internal {
        IERC20(address(token)).safeTransfer(to, value);
    }

    /**
     * @notice Safely transfer tokens from, reverts on failure
     * @param token Token to transfer
     * @param from Sender address (must have approval)
     * @param to Recipient address
     * @param value Amount to transfer
     */
    function safeTransferFrom(IKRC20 token, address from, address to, uint256 value) internal {
        IERC20(address(token)).safeTransferFrom(from, to, value);
    }

    /**
     * @notice Safely approve tokens, reverts on failure
     * @dev Note: Prefer safeIncreaseAllowance/safeDecreaseAllowance to avoid front-running
     * @param token Token to approve
     * @param spender Spender address
     * @param value Allowance amount
     */
    function safeApprove(IKRC20 token, address spender, uint256 value) internal {
        IERC20(address(token)).forceApprove(spender, value);
    }

    /**
     * @notice Safely increase allowance, reverts on failure
     * @param token Token to modify allowance
     * @param spender Spender address
     * @param value Amount to add to current allowance
     */
    function safeIncreaseAllowance(IKRC20 token, address spender, uint256 value) internal {
        IERC20(address(token)).safeIncreaseAllowance(spender, value);
    }

    /**
     * @notice Safely decrease allowance, reverts on failure
     * @param token Token to modify allowance
     * @param spender Spender address
     * @param requestedDecrease Amount to subtract from current allowance
     */
    function safeDecreaseAllowance(IKRC20 token, address spender, uint256 requestedDecrease) internal {
        IERC20(address(token)).safeDecreaseAllowance(spender, requestedDecrease);
    }

    /**
     * @notice Force approve with reset to zero first (for non-standard tokens)
     * @dev Use this for tokens that require zero approval before changing
     * @param token Token to approve
     * @param spender Spender address
     * @param value New allowance amount
     */
    function forceApprove(IKRC20 token, address spender, uint256 value) internal {
        IERC20(address(token)).forceApprove(spender, value);
    }
}
