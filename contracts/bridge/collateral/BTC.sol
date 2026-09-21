// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

import { KRC20B } from "../KRC20B.sol";

/**
 * @title Bridged BTC
 * @author kinet labs
 * @notice 1:1 bridged BTC collateral on Knt (minted by Teleporter)
 * @dev This is the canonical bridged BTC - NOT the debt token
 *
 * Token Model:
 * - BTC (this): Bridged collateral, 1:1 backed by BTC (via WBTC on Ethereum)
 * - KBTC: Debt token minted when borrowing from LiquidBTC vault
 */
contract BridgedBTC is KRC20B {
    string public constant _name = "Bridged BTC";
    string public constant _symbol = "BTC";
    uint8 public constant _decimals = 8;

    constructor() KRC20B(_name, _symbol) { }

    function decimals() public pure override returns (uint8) {
        return _decimals;
    }

    /// @notice Mint via daily-limited bridgeMint (C-01 fix: no direct _mint bypass)
    function mint(address account, uint256 amount) public onlyAdmin {
        bridgeMint(account, amount);
    }

    function burn(address account, uint256 amount) public onlyAdmin {
        _burn(account, amount);
    }
}
