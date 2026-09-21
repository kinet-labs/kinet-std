// SPDX-License-Identifier: BSD-3-Clause
// Copyright (c) 2026 kinet labs.
pragma solidity ^0.8.31;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { sKToken } from "./sKToken.sol";

/// @title sKUSD — staked LiquidUSD ERC-4626 yield vault
contract sKUSD is sKToken {
    constructor(IERC20 kusd, address admin) sKToken(kusd, "Staked LiquidUSD", "sKUSD", admin) { }
}
