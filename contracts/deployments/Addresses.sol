// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Knt Addresses - Canonical contract addresses across all Knt networks
// Source of truth: RLP imports from ~/work/knt/state/rlp/
// Reference: ~/work/knt/exchange/packages/exchange/src/contracts/addresses.ts
//
// Usage:
//   import {KntMainnet, KntTestnet} from "@knt/standard/deployments/Addresses.sol";
//   address router = KntMainnet.V3_SWAP_ROUTER;

// ============ Chain IDs ============
uint256 constant KNT_MAINNET_CHAIN_ID = 96369;
uint256 constant KNT_TESTNET_CHAIN_ID = 96368;
uint256 constant KNT_DEV_CHAIN_ID = 1337;

/**
 * @title Knt Mainnet Addresses (Chain ID: 96369)
 * @notice Source of truth: RLP imports from ~/work/knt/state/rlp/
 */
library KntMainnet {
    // Core (from RLP import - source of truth)
    address constant WKNT = 0x4888E4a2Ee0F03051c72D2BD3ACf755eD3498B3E;
    address constant MULTICALL3 = 0xd25F88CBdAe3c2CCA3Bb75FC4E723b44C0Ea362F;

    // Bridge Tokens (K* prefix = bridged from source chains) - from RLP
    address constant KETH = 0x60E0a8167FC13dE89348978860466C9ceC24B9ba;
    address constant KBTC = 0x1E48D32a4F5e9f08DB9aE4959163300FaF8A6C8e;
    address constant KUSD = 0x848Cff46eb323f323b6Bbe1Df274E40793d7f2c2;
    address constant KSOL = 0x1AF00A2590a834d14F4A8a26D1b03EBbA8cf7961;
    address constant KTON = 0xF5a313885832D4Fc71d1Ef80115197c4479B58C8;
    address constant KBNB = 0x6EdcF3645DeF09DB45050638c41157D8B9FEa1cf;
    address constant KPOL = 0x28BfC5DD4B7E15659e41190983e5fE3df1132bB9;
    address constant KCELO = 0x3078847F879A33994cDa2Ec1540ca52b5E0eE2e5;
    address constant KFTM = 0x8B982132d639527E8a0eAAD385f97719af8f5e04;

    // AMM V2 (QuantumSwap) - from RLP
    address constant V2_FACTORY = 0xD173926A10A0C4eCd3A51B1422270b65Df0551c1;
    address constant V2_ROUTER = 0xAe2cf1E403aAFE6C05A5b8Ef63EB19ba591d8511;

    // AMM V3 (Concentrated Liquidity) - from RLP
    address constant V3_FACTORY = 0x80bBc7C4C7a59C899D1B37BC14539A22D5830a84;
    address constant V3_SWAP_ROUTER = 0xE8fb25086C8652c92f5AF90D730Bac7C63Fc9A58;
    address constant V3_SWAP_ROUTER_02 = 0x939bC0Bca6F9B9c52E6e3AD8A3C590b5d9B9D10E;
    address constant V3_QUOTER = 0x12e2B76FaF4dDA5a173a4532916bb6Bfa3645275;
    address constant V3_QUOTER_V2 = 0x15C729fdd833Ba675edd466Dfc63E1B737925A4c;
    address constant V3_TICK_LENS = 0x57A22965AdA0e52D785A9Aa155beF423D573b879;
    address constant V3_NFT_POSITION_MANAGER = 0x7a4C48B9dae0b7c396569b34042fcA604150Ee28;
    address constant V3_NFT_DESCRIPTOR = 0x53B1aAA5b6DDFD4eD00D0A7b5Ef333dc74B605b5;
}

/**
 * @title Knt Testnet Addresses (Chain ID: 96368)
 * @notice Bridge tokens use same CREATE2 addresses as mainnet
 */
library KntTestnet {
    // Core
    address constant WKNT = 0x4888E4a2Ee0F03051c72D2BD3ACf755eD3498B3E;
    address constant MULTICALL3 = 0xd25F88CBdAe3c2CCA3Bb75FC4E723b44C0Ea362F;

    // Bridge Tokens (same CREATE2 addresses as mainnet)
    address constant KETH = 0x60E0a8167FC13dE89348978860466C9ceC24B9ba;
    address constant KBTC = 0x1E48D32a4F5e9f08DB9aE4959163300FaF8A6C8e;
    address constant KUSD = 0x848Cff46eb323f323b6Bbe1Df274E40793d7f2c2;
    address constant KSOL = 0x1AF00A2590a834d14F4A8a26D1b03EBbA8cf7961;
    address constant KTON = 0xF5a313885832D4Fc71d1Ef80115197c4479B58C8;
    address constant KBNB = 0x6EdcF3645DeF09DB45050638c41157D8B9FEa1cf;
    address constant KPOL = 0x28BfC5DD4B7E15659e41190983e5fE3df1132bB9;
    address constant KCELO = 0x3078847F879A33994cDa2Ec1540ca52b5E0eE2e5;
    address constant KFTM = 0x8B982132d639527E8a0eAAD385f97719af8f5e04;

    // AMM V2 (same CREATE2 addresses as mainnet)
    address constant V2_FACTORY = 0xD173926A10A0C4eCd3A51B1422270b65Df0551c1;
    address constant V2_ROUTER = 0xAe2cf1E403aAFE6C05A5b8Ef63EB19ba591d8511;

    // AMM V3 (same CREATE2 addresses as mainnet)
    address constant V3_FACTORY = 0x80bBc7C4C7a59C899D1B37BC14539A22D5830a84;
    address constant V3_SWAP_ROUTER = 0xE8fb25086C8652c92f5AF90D730Bac7C63Fc9A58;
    address constant V3_SWAP_ROUTER_02 = 0x939bC0Bca6F9B9c52E6e3AD8A3C590b5d9B9D10E;
    address constant V3_QUOTER = 0x12e2B76FaF4dDA5a173a4532916bb6Bfa3645275;
    address constant V3_QUOTER_V2 = 0x15C729fdd833Ba675edd466Dfc63E1B737925A4c;
    address constant V3_TICK_LENS = 0x57A22965AdA0e52D785A9Aa155beF423D573b879;
    address constant V3_NFT_POSITION_MANAGER = 0x7a4C48B9dae0b7c396569b34042fcA604150Ee28;
    address constant V3_NFT_DESCRIPTOR = 0x53B1aAA5b6DDFD4eD00D0A7b5Ef333dc74B605b5;
}

/**
 * @title Knt Dev Addresses (Chain ID: 1337)
 * @dev Deterministic CREATE addresses from DeployFullStack.s.sol deployed by anvil account 0
 */
library KntDev {
    // Core (Nonce 0)
    address constant WKNT = 0x5FbDB2315678afecb367f032d93F642f64180aa3;
    address constant MULTICALL3 = 0xd25F88CBdAe3c2CCA3Bb75FC4E723b44C0Ea362F;

    // Bridge Tokens (Deterministic deployment nonces 1-3)
    address constant KETH = 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512; // Nonce 1
    address constant KBTC = 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0; // Nonce 2
    address constant KUSD = 0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9; // Nonce 3

    // AMM V2
    address constant V2_FACTORY = 0x959922bE3CAee4b8Cd9a407cc3ac1C251C2007B1;
    address constant V2_ROUTER = 0x9A9f2CCfdE556A7E9Ff0848998Aa4a0CFD8863AE;

    // Staking
    address constant STAKED_KNT = 0xA51c1fc2f0D1a1b8494Ed1FE312d7C3a78Ed91C0;
}

/**
 * @title DEX Precompiles (Native AMM)
 * @notice Precompile addresses for native DEX functionality
 * @dev Address format: 0x0000...00LPNUMBER (addresses end with LP number)
 */
library DexPrecompiles {
    // Core DEX (LP-9010 series - Uniswap v4 style)
    address constant POOL_MANAGER = 0x0000000000000000000000000000000000009010; // LP-9010
    address constant ORACLE_HUB = 0x0000000000000000000000000000000000009011; // LP-9011
    address constant SWAP_ROUTER = 0x0000000000000000000000000000000000009012; // LP-9012
    address constant HOOKS_REGISTRY = 0x0000000000000000000000000000000000009013; // LP-9013
    address constant FLASH_LOAN = 0x0000000000000000000000000000000000009014; // LP-9014
    address constant CLOB = 0x0000000000000000000000000000000000009020; // LP-9020
    address constant VAULT = 0x0000000000000000000000000000000000009030; // LP-9030

    // Bridges (LP-6xxx)
    address constant TELEPORT = 0x0000000000000000000000000000000000006010; // LP-6010
}

/**
 * @title AddressResolver
 * @notice Helper to resolve addresses by chain ID
 */
library AddressResolver {
    error UnsupportedChainId(uint256 chainId);

    function getV3Factory(uint256 chainId) internal pure returns (address) {
        if (chainId == KNT_MAINNET_CHAIN_ID) return KntMainnet.V3_FACTORY;
        if (chainId == KNT_TESTNET_CHAIN_ID) return KntTestnet.V3_FACTORY;
        revert UnsupportedChainId(chainId);
    }

    function getV3Router(uint256 chainId) internal pure returns (address) {
        if (chainId == KNT_MAINNET_CHAIN_ID) return KntMainnet.V3_SWAP_ROUTER_02;
        if (chainId == KNT_TESTNET_CHAIN_ID) return KntTestnet.V3_SWAP_ROUTER_02;
        revert UnsupportedChainId(chainId);
    }

    function getWrappedNative(uint256 chainId) internal pure returns (address) {
        if (chainId == KNT_MAINNET_CHAIN_ID) return KntMainnet.WKNT;
        if (chainId == KNT_TESTNET_CHAIN_ID) return KntTestnet.WKNT;
        if (chainId == KNT_DEV_CHAIN_ID) return KntDev.WKNT;
        revert UnsupportedChainId(chainId);
    }

    function getMulticall3(uint256 chainId) internal pure returns (address) {
        // Multicall3 is deployed at same address on all chains
        if (chainId == KNT_MAINNET_CHAIN_ID) return KntMainnet.MULTICALL3;
        if (chainId == KNT_TESTNET_CHAIN_ID) return KntTestnet.MULTICALL3;
        if (chainId == KNT_DEV_CHAIN_ID) return KntDev.MULTICALL3;
        revert UnsupportedChainId(chainId);
    }
}
