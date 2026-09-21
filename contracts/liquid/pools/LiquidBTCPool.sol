// SPDX-License-Identifier: BSD-3-Clause
// Copyright (c) 2026 kinet labs.
pragma solidity ^0.8.31;

import { LiquidPool } from "./LiquidPool.sol";
import { BasketRegistry } from "../../bridge/v4/BasketRegistry.sol";

/**
 * @title LiquidBTCPool
 * @author kinet labs
 * @notice Unified BTC-basket pool. Accepts BTC (WBTC-ETH) / BTCB / tBTC / cbBTC
 *         / NativeBTC and issues KBTC.
 *
 * Pool decimals match the existing LiquidBTC token (18 decimals on Knt, same
 * scale as the rest of the L-token family). Bridged BTC sources land at sat
 * parity (8 decimals for NativeBTC/cbBTC/BTC, 18 for BTCB/tBTC); the pool
 * up-scales 8-decimal sources by 1e10 and accepts 18-decimal sources 1:1.
 * Burn does the inverse so the user round-trips cleanly.
 */
contract LiquidBTCPool is LiquidPool {
    constructor(address admin, address _liquidToken, address _basketRegistry)
        LiquidPool(admin, _liquidToken, _basketRegistry, uint8(BasketRegistry.BasketClass.BTC), 18)
    { }

    function _basketClassEnum() internal pure override returns (BasketRegistry.BasketClass) {
        return BasketRegistry.BasketClass.BTC;
    }
}
