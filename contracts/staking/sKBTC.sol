// SPDX-License-Identifier: BSD-3-Clause
// Copyright (c) 2026 kinet labs.
pragma solidity ^0.8.31;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { sKToken } from "./sKToken.sol";

/// @title sKBTC — staked LiquidBTC ERC-4626 yield vault
contract sKBTC is sKToken {
    constructor(IERC20 lbtc, address admin) sKToken(lbtc, "Staked LiquidBTC", "sKBTC", admin) { }
}
