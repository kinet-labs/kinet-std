// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

import { KRC20B } from "../../bridge/KRC20B.sol";

/// @title LiquidXRP — the XRP-basket pool token (6 decimals, drop parity).
contract LiquidXRP is KRC20B {
    uint8 public constant _decimals = 6;

    constructor() KRC20B("Liquid XRP", "KXRP") { }

    function decimals() public pure override returns (uint8) {
        return _decimals;
    }

    function mint(address account, uint256 amount) public onlyAdmin {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) public onlyAdmin {
        _burn(account, amount);
    }
}
