// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

import { KRC20B } from "../KRC20B.sol";

/**
 * @title Bridged cbBTC
 * @author kinet labs
 * @notice 1:1 bridged Coinbase Wrapped BTC collateral on Knt
 * @dev BTC basket member — accepted as deposit into LiquidBTC pool
 */
contract BridgedcbBTC is KRC20B {
    string public constant _name = "Bridged cbBTC";
    string public constant _symbol = "cbBTC";
    uint8 public constant _decimals = 8;

    constructor() KRC20B(_name, _symbol) { }

    function decimals() public pure override returns (uint8) {
        return _decimals;
    }

    function mint(address account, uint256 amount) public onlyAdmin {
        bridgeMint(account, amount);
    }

    function burn(address account, uint256 amount) public onlyAdmin {
        _burn(account, amount);
    }
}
