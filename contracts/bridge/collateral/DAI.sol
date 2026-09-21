// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

import { KRC20B } from "../KRC20B.sol";

/**
 * @title Bridged DAI
 * @author kinet labs
 * @notice 1:1 bridged DAI collateral on Knt (minted by Teleporter)
 * @dev Bridged DAI can be deposited into LiquidUSD to borrow KUSD
 */
contract BridgedDAI is KRC20B {
    string public constant _name = "Bridged DAI";
    string public constant _symbol = "DAI";

    constructor() KRC20B(_name, _symbol) { }

    /// @notice Mint via daily-limited bridgeMint (C-01 fix: no direct _mint bypass)
    function mint(address account, uint256 amount) public onlyAdmin {
        bridgeMint(account, amount);
    }

    function burn(address account, uint256 amount) public onlyAdmin {
        _burn(account, amount);
    }
}
