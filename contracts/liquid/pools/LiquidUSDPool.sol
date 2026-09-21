// SPDX-License-Identifier: BSD-3-Clause
// Copyright (c) 2026 kinet labs.
pragma solidity ^0.8.31;

import { LiquidPool } from "./LiquidPool.sol";
import { BasketRegistry } from "../../bridge/v4/BasketRegistry.sol";

/**
 * @title LiquidUSDPool
 * @author kinet labs
 * @notice Unified USD-basket pool. Accepts USDT/USDC/DAI/FRAX/PYUSD/RKUSD/TUSD
 *         at 1:1 (decimal-normalized) and issues KUSD (18 decimals).
 */
contract LiquidUSDPool is LiquidPool {
    constructor(address admin, address _liquidToken, address _basketRegistry)
        LiquidPool(admin, _liquidToken, _basketRegistry, uint8(BasketRegistry.BasketClass.USD), 18)
    { }

    function _basketClassEnum() internal pure override returns (BasketRegistry.BasketClass) {
        return BasketRegistry.BasketClass.USD;
    }
}
