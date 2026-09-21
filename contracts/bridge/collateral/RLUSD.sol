// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

import { KRC20B } from "../KRC20B.sol";

/**
 * @title Bridged RKUSD
 * @author kinet labs
 * @notice 1:1 bridged Ripple USD collateral on Knt (minted by BridgeV4)
 * @dev USD basket member — accepted as deposit into LiquidUSD pool
 */
contract BridgedRKUSD is KRC20B {
    string public constant _name = "Bridged RKUSD";
    string public constant _symbol = "RKUSD";
    uint8 public constant _decimals = 6;

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
