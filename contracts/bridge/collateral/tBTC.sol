// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

import { KRC20B } from "../KRC20B.sol";

/**
 * @title Bridged tBTC
 * @author kinet labs
 * @notice 1:1 bridged Threshold Network tBTC collateral on Knt
 * @dev BTC basket member — accepted as deposit into LiquidBTC pool
 *
 * tBTC is 18 decimals on Ethereum; normalization to KBTC sat parity happens in
 * LiquidBTCPool.
 */
contract BridgedtBTC is KRC20B {
    string public constant _name = "Bridged tBTC";
    string public constant _symbol = "tBTC";

    constructor() KRC20B(_name, _symbol) { }

    function mint(address account, uint256 amount) public onlyAdmin {
        bridgeMint(account, amount);
    }

    function burn(address account, uint256 amount) public onlyAdmin {
        _burn(account, amount);
    }
}
