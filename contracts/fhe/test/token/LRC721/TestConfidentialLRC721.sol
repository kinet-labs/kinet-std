// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

import { ConfidentialKRC721Mintable } from "../../../token/KRC721/extensions/ConfidentialKRC721Mintable.sol";

/**
 * @title TestConfidentialKRC721
 * @notice Test contract for ConfidentialKRC721Mintable
 */
contract TestConfidentialKRC721 is ConfidentialKRC721Mintable {
    constructor(string memory name_, string memory symbol_, address owner_, string memory baseURI_)
        ConfidentialKRC721Mintable(name_, symbol_, owner_, baseURI_)
    {
        //
    }
}
