// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

/**
 * @title FHEVMConfig
 * @dev Configuration for KntFHE VM - placeholder for native deployment
 * @notice This is a minimal implementation for compatibility
 */
abstract contract FHEVMConfig {
    // KntFHE native chain doesn't need external configuration
    // FHE operations are handled natively by the VM
}

// Network-specific configs
abstract contract KntFHEVMConfig is FHEVMConfig { }

abstract contract KntTestnetFHEVMConfig is FHEVMConfig { }

abstract contract KntMainnetFHEVMConfig is FHEVMConfig { }

// Legacy aliases for backward compatibility
abstract contract SepoliaLegacyFHEVMConfig is KntFHEVMConfig { }

abstract contract SepoliaFHEVMConfig is KntTestnetFHEVMConfig { }

abstract contract MainnetFHEVMConfig is KntMainnetFHEVMConfig { }
