// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

/**
 * @title Governance Re-exports
 * @author kinet labs
 * @notice OpenZeppelin governance re-exports for @kinet/contracts
 * @dev Import from here - no need for @openzeppelin imports
 *
 * Usage:
 *   import {TimelockController} from "@kinet/contracts/governance/Governance.sol";
 *   import {Governor} from "@kinet/contracts/governance/Governance.sol";
 */

// Timelock
import { TimelockController } from "@openzeppelin/contracts/governance/TimelockController.sol";

// Governor
import { Governor } from "@openzeppelin/contracts/governance/Governor.sol";
import { IGovernor } from "@openzeppelin/contracts/governance/IGovernor.sol";

// Governor Extensions
import { GovernorSettings } from "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import { GovernorVotes } from "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import {
    GovernorVotesQuorumFraction
} from "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import { GovernorTimelockControl } from "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";
import { GovernorCountingSimple } from "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import { GovernorPreventLateQuorum } from "@openzeppelin/contracts/governance/extensions/GovernorPreventLateQuorum.sol";
