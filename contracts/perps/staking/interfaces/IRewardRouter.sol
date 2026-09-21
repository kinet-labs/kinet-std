// SPDX-License-Identifier: MIT

pragma solidity ^0.8.31;

/// @title IRewardRouter
/// @notice Interface for the LPX perpetuals reward routing system
/// @dev DKNT is the single governance rewards token across the Knt ecosystem
interface IRewardRouter {
    function feeLLPTracker() external view returns (address);
    function stakedLLPTracker() external view returns (address);
}
