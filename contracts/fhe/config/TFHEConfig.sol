// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

/**
 * @title TFHEConfig
 * @dev Configuration for T-Chain threshold decryption endpoints
 * @notice Network-specific T-Chain gateway addresses for TFHE decryption
 */
abstract contract TFHEConfig {
    address internal constant TFHE_GATEWAY = address(0); // Set per network
}

abstract contract KntTFHEConfig is TFHEConfig { }

abstract contract KntTestnetTFHEConfig is TFHEConfig { }

abstract contract KntMainnetTFHEConfig is TFHEConfig { }
