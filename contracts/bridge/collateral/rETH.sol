// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

import { KRC20B } from "../KRC20B.sol";

/**
 * @title Bridged rETH
 * @author kinet labs
 * @notice 1:1 bridged Rocket Pool ETH collateral on Knt
 * @dev ETH basket member — accepted as deposit into LiquidETH pool.
 *      rETH is non-rebasing on Ethereum (share-priced via exchangeRate),
 *      so balances on Knt track shares directly.
 */
contract BridgedrETH is KRC20B {
    string public constant _name = "Bridged rETH";
    string public constant _symbol = "rETH";

    constructor() KRC20B(_name, _symbol) { }

    function mint(address account, uint256 amount) public onlyAdmin {
        bridgeMint(account, amount);
    }

    function burn(address account, uint256 amount) public onlyAdmin {
        _burn(account, amount);
    }
}
