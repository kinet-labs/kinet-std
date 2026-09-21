// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

import { ConfidentialKRC20Votes } from "../../governance/ConfidentialKRC20Votes.sol";

contract TestConfidentialKRC20Votes is ConfidentialKRC20Votes {
    constructor(address owner_, string memory name_, string memory symbol_, string memory version_, uint64 totalSupply_)
        ConfidentialKRC20Votes(owner_, name_, symbol_, version_, totalSupply_)
    {
        //
    }
}
