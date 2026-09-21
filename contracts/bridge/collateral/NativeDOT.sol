// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

import { KRC20B } from "../KRC20B.sol";

/**
 * @title Bridged Native DOT
 * @author kinet labs
 * @notice 1:1 bridged Polkadot (native) under MPC custody, minted on Knt
 * @dev DOT basket — sole member, matches the DOT broadcaster agent in kinet/bridge.
 *
 * Decimals: 10 — preserves planck parity on the Polkadot relay (1 DOT = 1e10 planck).
 *             Kusama planck would be 12; Knt mints against the Polkadot relay only.
 */
contract BridgedNativeDOT is KRC20B {
    string public constant _name = "Bridged Native DOT";
    string public constant _symbol = "nDOT";
    uint8 public constant _decimals = 10;

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
