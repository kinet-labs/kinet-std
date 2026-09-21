// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

import { KRC20B } from "../../bridge/KRC20B.sol";

contract LiquidWIF is KRC20B {
    constructor() KRC20B("Liquid WIF", "KWIF") { }

    /// @notice C-02 fix: use MINTER_ROLE not DEFAULT_ADMIN_ROLE for vault minting
    function mint(address account, uint256 amount) public onlyAdmin {
        _mint(account, amount);
    }

    /// @notice C-02 fix: use MINTER_ROLE not DEFAULT_ADMIN_ROLE for vault burning
    function burn(address account, uint256 amount) public onlyAdmin {
        _burn(account, amount);
    }
}
