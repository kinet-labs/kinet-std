// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

import { KRC20B } from "../../bridge/KRC20B.sol";

contract LiquidAI16Z is KRC20B {
    constructor() KRC20B("Liquid AI16Z", "KAI16Z") { }

    /// @notice C-02 fix: use MINTER_ROLE not DEFAULT_ADMIN_ROLE for vault minting
    function mint(address account, uint256 amount) public onlyAdmin {
        _mint(account, amount);
    }

    /// @notice C-02 fix: use MINTER_ROLE not DEFAULT_ADMIN_ROLE for vault burning
    function burn(address account, uint256 amount) public onlyAdmin {
        _burn(account, amount);
    }
}
