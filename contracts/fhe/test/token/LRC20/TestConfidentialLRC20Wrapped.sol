// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

import { ConfidentialKRC20Wrapped } from "../../../token/KRC20/ConfidentialKRC20Wrapped.sol";

contract TestConfidentialKRC20Wrapped is ConfidentialKRC20Wrapped {
    constructor(address krc20_, uint256 maxDecryptionDelay_) ConfidentialKRC20Wrapped(krc20_, maxDecryptionDelay_) { }
}
