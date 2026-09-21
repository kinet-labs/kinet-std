// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

import { KRC20B } from "../KRC20B.sol";

/**
 * @title Bridged Native SOL
 * @author kinet labs
 * @notice 1:1 bridged Solana (native) under MPC custody, minted on Knt
 * @dev SOL basket — sole member, matches the SOL broadcaster agent in kinet/bridge.
 *
 * Decimals: 9 — preserves lamport parity (1 SOL = 1e9 lamports).
 */
contract BridgedNativeSOL is KRC20B {
    string public constant _name = "Bridged Native SOL";
    string public constant _symbol = "nSOL";
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
