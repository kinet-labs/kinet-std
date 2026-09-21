// SPDX-License-Identifier: MIT

pragma solidity ^0.8.31;

import { MintableBaseToken } from "./MintableBaseToken.sol";

/// @title LPX Token
/// @notice Governance token for the Knt Perps protocol
contract LPX is MintableBaseToken {
    constructor() MintableBaseToken("Knt Perps", "LPX", 0) { }
}
