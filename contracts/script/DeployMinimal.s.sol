// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.31;

import { Script, console } from "forge-std/Script.sol";

// Core native token
import { WKNT } from "@kinet/contracts/tokens/WKNT.sol";

// Bridged Collateral Tokens
import { BridgedETH } from "@kinet/contracts/bridge/collateral/ETH.sol";
import { BridgedBTC } from "@kinet/contracts/bridge/collateral/BTC.sol";
import { BridgedUSDC } from "@kinet/contracts/bridge/collateral/USDC.sol";

// Staking
import { sKNT as StakedKNT } from "@kinet/contracts/staking/sKNT.sol";

// AMM
import { AMMV2Factory } from "@kinet/contracts/amm/AMMV2Factory.sol";
import { AMMV2Router } from "@kinet/contracts/amm/AMMV2Router.sol";

// Governance
import { Timelock } from "@kinet/contracts/governance/Timelock.sol";
import { vKNT } from "@kinet/contracts/governance/vKNT.sol";
import { GaugeController } from "@kinet/contracts/governance/GaugeController.sol";
import { Karma } from "@kinet/contracts/governance/Karma.sol";
import { DKNT } from "@kinet/contracts/governance/DKNT.sol";

// Identity/DID
import { DIDRegistry } from "@kinet/contracts/identity/DIDRegistry.sol";

// Treasury
import { FeeGov } from "@kinet/contracts/treasury/FeeGov.sol";
import { ValidatorVault } from "@kinet/contracts/treasury/ValidatorVault.sol";

// LSSVM (NFT AMM)
import { LSSVMPairFactory } from "@kinet/contracts/lssvm/LSSVMPairFactory.sol";
import { LinearCurve } from "@kinet/contracts/lssvm/LinearCurve.sol";
import { ExponentialCurve } from "@kinet/contracts/lssvm/ExponentialCurve.sol";

// Markets (Lending)
import { Markets } from "@kinet/contracts/markets/Markets.sol";

// Perps
import { Perp } from "@kinet/contracts/perps/Perp.sol";

/**
 * @title DeployMinimal
 * @notice Deploy all Knt standard contracts with minimal token operations
 * @dev Uses only gas, no large KNT wrapping/staking/pooling
 *
 * Usage:
 *   KNT_PRIVATE_KEY=0x... forge script contracts/script/DeployMinimal.s.sol \
 *     --rpc-url https://api.knt.network/mainnet/ext/bc/C/rpc --broadcast --legacy -vvv
 */
contract DeployMinimal is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("KNT_PRIVATE_KEY");
        address deployer = vm.addr(deployerKey);

        console.log("=== Minimal Knt Standard Deployment ===");
        console.log("Chain ID:", block.chainid);
        console.log("Deployer:", deployer);
        console.log("Balance:", deployer.balance / 1e18, "KNT");
        console.log("");

        vm.startBroadcast(deployerKey);

        // Phase 1: Core Tokens (deploy only, minimal wrap)
        WKNT wknt = new WKNT();
        console.log("WKNT:", address(wknt));

        // Wrap just 1 KNT for setup
        wknt.deposit{ value: 1 ether }();

        BridgedETH leth = new BridgedETH();
        console.log("KETH:", address(leth));

        BridgedBTC lbtc = new BridgedBTC();
        console.log("KBTC:", address(lbtc));

        BridgedUSDC lusdc = new BridgedUSDC();
        console.log("KUSDC:", address(lusdc));

        // Phase 2: Staking
        StakedKNT stakedKnt = new StakedKNT(address(wknt));
        console.log("StakedKNT:", address(stakedKnt));

        // Phase 3: AMM
        AMMV2Factory factory = new AMMV2Factory(deployer);
        console.log("AMMV2Factory:", address(factory));

        AMMV2Router router = new AMMV2Router(address(factory), address(wknt));
        console.log("AMMV2Router:", address(router));

        // Phase 4: Governance
        address[] memory proposers = new address[](1);
        proposers[0] = deployer;
        address[] memory executors = new address[](1);
        executors[0] = address(0);

        Timelock timelock = new Timelock(1 days, proposers, executors, deployer);
        console.log("Timelock:", address(timelock));

        vKNT voteKnt = new vKNT(address(wknt));
        console.log("vKNT:", address(voteKnt));

        GaugeController gaugeController = new GaugeController(address(voteKnt));
        console.log("GaugeController:", address(gaugeController));

        Karma karma = new Karma(deployer);
        console.log("Karma:", address(karma));

        DKNT dknt = new DKNT(address(wknt), deployer, deployer);
        console.log("DKNT:", address(dknt));

        // Phase 5: Identity (may revert on subnet EVM - Cancun opcode issue)
        try new DIDRegistry(deployer, "knt", true) returns (DIDRegistry did) {
            console.log("DIDRegistry:", address(did));
        } catch {
            console.log("DIDRegistry: REVERTED (Cancun opcode incompatibility)");
        }

        // Phase 6: Treasury
        FeeGov feeGov = new FeeGov(30, 10, 500, deployer);
        console.log("FeeGov:", address(feeGov));

        ValidatorVault validatorVault = new ValidatorVault(address(wknt));
        console.log("ValidatorVault:", address(validatorVault));

        // Phase 7: LSSVM
        LinearCurve linearCurve = new LinearCurve();
        console.log("LinearCurve:", address(linearCurve));

        ExponentialCurve exponentialCurve = new ExponentialCurve();
        console.log("ExponentialCurve:", address(exponentialCurve));

        LSSVMPairFactory lssvmFactory = new LSSVMPairFactory(deployer);
        console.log("LSSVMPairFactory:", address(lssvmFactory));

        lssvmFactory.setBondingCurveAllowed(address(linearCurve), true);
        lssvmFactory.setBondingCurveAllowed(address(exponentialCurve), true);

        // Phase 8: DeFi
        Markets markets = new Markets(deployer);
        console.log("Markets:", address(markets));

        Perp perp = new Perp(address(wknt), deployer, deployer);
        console.log("Perp:", address(perp));

        vm.stopBroadcast();

        console.log("");
        console.log("=== DEPLOYMENT COMPLETE ===");
        console.log("Total contracts: 20");
    }
}
