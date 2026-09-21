// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

import {
    ConfidentialKRC20WithErrorsMintable
} from "../../../token/KRC20/extensions/ConfidentialKRC20WithErrorsMintable.sol";

contract TestConfidentialKRC20WithErrorsMintable is ConfidentialKRC20WithErrorsMintable {
    constructor(string memory name_, string memory symbol_, address owner_)
        ConfidentialKRC20WithErrorsMintable(name_, symbol_, owner_)
    {
        //
    }
}
