// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

import { ConfidentialKRC20Mintable } from "../../../token/KRC20/extensions/ConfidentialKRC20Mintable.sol";

contract TestConfidentialKRC20Mintable is ConfidentialKRC20Mintable {
    constructor(string memory name_, string memory symbol_, address owner_)
        ConfidentialKRC20Mintable(name_, symbol_, owner_)
    {
        //
    }
}
