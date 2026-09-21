// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

import { KRC20B } from "../KRC20B.sol";

/**
 * @title Bridged stETH
 * @author kinet labs
 * @notice 1:1 bridged Lido Staked ETH collateral on Knt
 * @dev ETH basket member — accepted as deposit into LiquidETH pool.
 *      Note: stETH is a rebasing token on Ethereum; the bridge attests an
 *      underlying-ETH-equivalent amount on each mint so the on-Knt balance
 *      tracks shares, not the rebased value. Yield accrual lives in
 *      the sKETH yield-strategy plug, not on this token.
 */
contract BridgedstETH is KRC20B {
    string public constant _name = "Bridged stETH";
    string public constant _symbol = "stETH";

    constructor() KRC20B(_name, _symbol) { }

    function mint(address account, uint256 amount) public onlyAdmin {
        bridgeMint(account, amount);
    }

    function burn(address account, uint256 amount) public onlyAdmin {
        _burn(account, amount);
    }
}
