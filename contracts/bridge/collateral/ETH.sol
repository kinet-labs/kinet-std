// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

/*
    ██████╗ ██████╗ ██╗██████╗  ██████╗ ███████╗██████╗     ███████╗████████╗██╗  ██╗
    ██╔══██╗██╔══██╗██║██╔══██╗██╔════╝ ██╔════╝██╔══██╗    ██╔════╝╚══██╔══╝██║  ██║
    ██████╔╝██████╔╝██║██║  ██║██║  ███╗█████╗  ██║  ██║    █████╗     ██║   ███████║
    ██╔══██╗██╔══██╗██║██║  ██║██║   ██║██╔══╝  ██║  ██║    ██╔══╝     ██║   ██╔══██║
    ██████╔╝██║  ██║██║██████╔╝╚██████╔╝███████╗██████╔╝    ███████╗   ██║   ██║  ██║
    ╚═════╝ ╚═╝  ╚═╝╚═╝╚═════╝  ╚═════╝ ╚══════╝╚═════╝     ╚══════╝   ╚═╝   ╚═╝  ╚═╝
 */

import { KRC20B } from "../KRC20B.sol";

/**
 * @title Bridged ETH
 * @author kinet labs
 * @notice 1:1 bridged ETH collateral on Knt (minted by Teleporter)
 * @dev This is the canonical bridged ETH - NOT the debt token
 *
 * Token Model:
 * - ETH (this): Bridged collateral, 1:1 backed by ETH on Ethereum
 * - KETH: Debt token minted when borrowing from LiquidETH vault
 *
 * Flow:
 * 1. User deposits ETH on Ethereum → LiquidVault
 * 2. MPC attests deposit → Teleporter mints ETH to user on Knt
 * 3. User can hold ETH, or deposit into LiquidETH to earn yield + borrow KETH
 */
contract BridgedETH is KRC20B {
    string public constant _name = "Bridged ETH";
    string public constant _symbol = "ETH";

    constructor() KRC20B(_name, _symbol) { }

    /// @notice Mint via daily-limited bridgeMint (C-01 fix: no direct _mint bypass)
    function mint(address account, uint256 amount) public onlyAdmin {
        bridgeMint(account, amount);
    }

    function burn(address account, uint256 amount) public onlyAdmin {
        _burn(account, amount);
    }
}
