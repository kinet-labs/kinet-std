// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

import { KRC20B } from "../../bridge/KRC20B.sol";

/// @title LiquidDOT — the DOT-basket pool token (10 decimals, Polkadot planck parity).
contract LiquidDOT is KRC20B {
    uint8 public constant _decimals = 10;

    constructor() KRC20B("Liquid DOT", "KDOT") { }

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
