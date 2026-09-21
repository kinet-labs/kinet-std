// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

import { KRC20B } from "../KRC20B.sol";

/**
 * @title Bridged Native TON
 * @author kinet labs
 * @notice 1:1 bridged Toncoin (native) under MPC custody, minted on Knt
 * @dev TON basket — sole member, matches the TON broadcaster agent in kinet/bridge.
 *
 * Decimals: 9 — preserves nanoton parity (1 TON = 1e9 nanoton).
 */
contract BridgedNativeTON is KRC20B {
    string public constant _name = "Bridged Native TON";
    string public constant _symbol = "nTON";
    uint8 public constant _decimals = 9;

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
