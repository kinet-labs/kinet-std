// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

import { KRC20B } from "../KRC20B.sol";

/**
 * @title Bridged USDT
 * @author kinet labs
 * @notice 1:1 bridged USDT collateral on Knt (minted by Teleporter)
 * @dev Bridged USDT can be deposited into LiquidUSD to borrow KUSD
 */
contract BridgedUSDT is KRC20B {
    string public constant _name = "Bridged USDT";
    string public constant _symbol = "USDT";
    uint8 public constant _decimals = 6;

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
