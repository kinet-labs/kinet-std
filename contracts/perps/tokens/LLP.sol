// SPDX-License-Identifier: MIT

pragma solidity ^0.8.31;

import { MintableBaseToken } from "./MintableBaseToken.sol";

/// @title LLP Token
/// @notice Liquidity provider token representing shares in the LLP pool
contract LLP is MintableBaseToken {
    constructor() MintableBaseToken("Knt LP", "LLP", 0) { }
}
