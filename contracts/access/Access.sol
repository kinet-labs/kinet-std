// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

/**
 * @title Access Control Re-exports
 * @author kinet labs
 * @notice OpenZeppelin access control re-exports for @kinet/contracts
 * @dev Import from here - no need for @openzeppelin imports
 *
 * Usage:
 *   import {Ownable} from "@kinet/contracts/access/Access.sol";
 *   import {AccessControl} from "@kinet/contracts/access/Access.sol";
 */

// Ownable
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Ownable2Step } from "@openzeppelin/contracts/access/Ownable2Step.sol";

// Access Control
import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { IAccessControl } from "@openzeppelin/contracts/access/IAccessControl.sol";
import { AccessControlEnumerable } from "@openzeppelin/contracts/access/extensions/AccessControlEnumerable.sol";
import {
    AccessControlDefaultAdminRules
} from "@openzeppelin/contracts/access/extensions/AccessControlDefaultAdminRules.sol";
