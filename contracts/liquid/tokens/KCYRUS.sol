// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

/*
    Liquid CYRUS - 1:1 liquid staking token for CYRUS
    Deposit CYRUS → Receive KCYRUS
    Can be used as collateral for ASHA bonding (TIER_1)
 */

import { KRC20B } from "../../bridge/KRC20B.sol";

contract LiquidCYRUS is KRC20B {
    constructor() KRC20B("Liquid CYRUS", "KCYRUS") { }

    /// @notice C-02 fix: use MINTER_ROLE not DEFAULT_ADMIN_ROLE for vault minting
    function mint(address account, uint256 amount) public onlyAdmin {
        _mint(account, amount);
    }

    /// @notice C-02 fix: use MINTER_ROLE not DEFAULT_ADMIN_ROLE for vault burning
    function burn(address account, uint256 amount) public onlyAdmin {
        _burn(account, amount);
    }
}
