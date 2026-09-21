// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

import { ConfidentialWKNT } from "../../../token/KRC20/ConfidentialWKNT.sol";

contract TestConfidentialWKNT is ConfidentialWKNT {
    constructor(uint256 maxDecryptionDelay_) ConfidentialWKNT(maxDecryptionDelay_) { }
}
