// SPDX-License-Identifier: MIT
// Copyright (c) 2026 kinet labs
pragma solidity ^0.8.17;

// Single import barrel for the ERC-3643 (T-REX) registry / compliance
// stack. Consumers import only from `@kinet/contracts` — no separate
// `@kinet/erc-3643` / `@onchain-id/solidity` package dependency.
//
// Implementation files live under `securities/erc3643/` (vendored from
// upstream Tokeny T-REX 4.1.6 with OZ v5 patches; upstream is OZ-v4-
// locked and officially deprecated). The canonical per-issuance
// security-token contract is Knt's own
// `securities/token/SecurityToken.sol`, deployed through Knt's
// `securities/factory/SecurityTokenFactory.sol`. The upstream Tokeny
// `Token`, `TREXImplementationAuthority`, and `TREXFactory` are not
// re-exported — Liquidity does not use the upstream proxy/suite path.

// --- Registry implementations -----------------------------------------

import {IdentityRegistry} from "@kinet/contracts/securities/erc3643/registry/implementation/IdentityRegistry.sol";
import {IdentityRegistryStorage} from "@kinet/contracts/securities/erc3643/registry/implementation/IdentityRegistryStorage.sol";
import {ClaimTopicsRegistry} from "@kinet/contracts/securities/erc3643/registry/implementation/ClaimTopicsRegistry.sol";
import {TrustedIssuersRegistry} from "@kinet/contracts/securities/erc3643/registry/implementation/TrustedIssuersRegistry.sol";

// --- Registry interfaces ----------------------------------------------

import {IIdentityRegistry} from "@kinet/contracts/securities/erc3643/registry/interface/IIdentityRegistry.sol";
import {IIdentityRegistryStorage} from "@kinet/contracts/securities/erc3643/registry/interface/IIdentityRegistryStorage.sol";
import {IClaimTopicsRegistry} from "@kinet/contracts/securities/erc3643/registry/interface/IClaimTopicsRegistry.sol";
import {ITrustedIssuersRegistry} from "@kinet/contracts/securities/erc3643/registry/interface/ITrustedIssuersRegistry.sol";

// --- Compliance + module base -----------------------------------------

import {ModularCompliance} from "@kinet/contracts/securities/erc3643/compliance/modular/ModularCompliance.sol";
import {IModularCompliance} from "@kinet/contracts/securities/erc3643/compliance/modular/IModularCompliance.sol";
import {AbstractModule} from "@kinet/contracts/securities/erc3643/compliance/modular/modules/AbstractModule.sol";

// --- Token interface (the contract is Knt's, not re-exported) ---------

import {IToken} from "@kinet/contracts/securities/erc3643/token/IToken.sol";
