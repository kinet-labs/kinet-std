// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.31;

import { Script, console } from "forge-std/Script.sol";

// Core native token
import { WKNT } from "@kinet/contracts/tokens/WKNT.sol";

// Bridged Collateral Tokens
import { BridgedETH } from "@kinet/contracts/bridge/collateral/ETH.sol";
import { BridgedBTC } from "@kinet/contracts/bridge/collateral/BTC.sol";
import { BridgedUSDC } from "@kinet/contracts/bridge/collateral/USDC.sol";

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

// Markets (Lending)
import { Markets } from "@kinet/contracts/markets/Markets.sol";

/**
 * @title DeploySubnetMissing
 * @notice Deploy the 13 missing contracts to subnet chains
 * @dev Subnets already have 7 contracts deployed (StakedKNT, AMMV2Factory,
 *      AMMV2Router, LinearCurve, ExponentialCurve, LSSVMPairFactory, Perp).
 *      This script deploys only the 13 that are missing.
 *      Skips LP pool creation (Phase 4) since no V3 on subnets.
 *
 * Deploy key: 0xEAbCC110fAcBfebabC66Ad6f9E7B67288e720B59
 *
 * Usage:
 *   export KNT_PRIVATE_KEY=<deployer-private-key>
 *
 */
contract DeploySubnetMissing is Script {
    // Deployer
    address public deployer;
    uint256 public deployerKey;

    // ========== Core Tokens ==========
    WKNT public wknt;
    BridgedETH public leth;
    BridgedBTC public lbtc;
    BridgedUSDC public lusdc;

    // ========== Governance ==========
    Timelock public timelock;
    vKNT public voteKnt;
    GaugeController public gaugeController;
    Karma public karma;
    DKNT public dknt;

    // ========== Identity ==========
    DIDRegistry public didRegistry;

    // ========== Treasury ==========
    FeeGov public feeGov;
    ValidatorVault public validatorVault;

    // ========== DeFi ==========
    Markets public markets;

    // Constants (same as DeployMultiNetwork)
    uint256 constant INITIAL_KNT = 10_000 ether;
    uint256 constant INITIAL_ETH = 100 ether;
    uint256 constant INITIAL_BTC = 10e8;
    uint256 constant INITIAL_USDC = 1_000_000e6;

    function run() external {
        console.log("=== Deploying 13 Missing Subnet Contracts ===");
        console.log("Chain ID:", block.chainid);
        console.log("");

        // Get deployer from private key or mnemonic
        try vm.envUint("KNT_PRIVATE_KEY") returns (uint256 pk) {
            deployerKey = pk;
        } catch {
            string memory mnemonic = vm.envString("KNT_MNEMONIC");
            require(bytes(mnemonic).length > 0, "KNT_PRIVATE_KEY or KNT_MNEMONIC required");
            deployerKey = vm.deriveKey(mnemonic, 0);
        }
        deployer = vm.addr(deployerKey);
        console.log("Deployer:", deployer);

        // Fund deployer in simulation (ignored during broadcast)
        vm.deal(deployer, 3_000_000_000_000 ether);

        console.log("Balance:", deployer.balance / 1e18, "KNT");
        console.log("");

        vm.startBroadcast(deployerKey);

        // Phase 1: Core Tokens (WKNT, KETH, KBTC, KUSDC)
        _deployPhase1CoreTokens();

        // Phase 2: Governance (Timelock, vKNT, GaugeController, Karma, DKNT)
        _deployPhase2Governance();

        // Phase 3: Identity (DIDRegistry)
        _deployPhase3Identity();

        // Phase 4: Treasury (FeeGov, ValidatorVault)
        _deployPhase4Treasury();

        // Phase 5: DeFi (Markets)
        _deployPhase5DeFi();

        vm.stopBroadcast();

        _printSummary();
    }

    function _deployPhase1CoreTokens() internal {
        console.log("--- Phase 1: Core Tokens ---");

        wknt = new WKNT();
        console.log("WKNT:", address(wknt));

        // Wrap some KNT
        wknt.deposit{ value: INITIAL_KNT }();
        console.log("Wrapped", INITIAL_KNT / 1e18, "KNT");

        leth = new BridgedETH();
        console.log("KETH:", address(leth));

        lbtc = new BridgedBTC();
        console.log("KBTC:", address(lbtc));

        lusdc = new BridgedUSDC();
        console.log("KUSDC:", address(lusdc));

        // Mint bridged tokens
        leth.mint(deployer, INITIAL_ETH);
        lbtc.mint(deployer, INITIAL_BTC);
        lusdc.mint(deployer, INITIAL_USDC);
        console.log("Minted bridged tokens");
        console.log("");
    }

    function _deployPhase2Governance() internal {
        console.log("--- Phase 2: Governance ---");

        address[] memory proposers = new address[](1);
        proposers[0] = deployer;
        address[] memory executors = new address[](1);
        executors[0] = address(0);

        timelock = new Timelock(1 days, proposers, executors, deployer);
        console.log("Timelock:", address(timelock));

        voteKnt = new vKNT(address(wknt));
        console.log("vKNT:", address(voteKnt));

        gaugeController = new GaugeController(address(voteKnt));
        console.log("GaugeController:", address(gaugeController));

        karma = new Karma(deployer);
        console.log("Karma:", address(karma));

        dknt = new DKNT(address(wknt), deployer, deployer);
        console.log("DKNT:", address(dknt));

        console.log("");
    }

    function _deployPhase3Identity() internal {
        console.log("--- Phase 3: Identity ---");

        didRegistry = new DIDRegistry(deployer, "knt", true);
        console.log("DIDRegistry:", address(didRegistry));
        console.log("");
    }

    function _deployPhase4Treasury() internal {
        console.log("--- Phase 4: Treasury ---");

        feeGov = new FeeGov(30, 10, 500, deployer);
        console.log("FeeGov:", address(feeGov));

        validatorVault = new ValidatorVault(address(wknt));
        console.log("ValidatorVault:", address(validatorVault));
        console.log("");
    }

    function _deployPhase5DeFi() internal {
        console.log("--- Phase 5: DeFi ---");

        markets = new Markets(deployer);
        console.log("Markets:", address(markets));
        console.log("");
    }

    function _printSummary() internal view {
        console.log("");
        console.log("================================================================================");
        console.log("           SUBNET MISSING CONTRACTS DEPLOYMENT COMPLETE");
        console.log("================================================================================");
        console.log("");
        console.log("Chain ID:", block.chainid);
        console.log("");
        console.log("CORE TOKENS (4):");
        console.log("  WKNT:      ", address(wknt));
        console.log("  KETH:      ", address(leth));
        console.log("  KBTC:      ", address(lbtc));
        console.log("  KUSDC:     ", address(lusdc));
        console.log("");
        console.log("GOVERNANCE (5):");
        console.log("  Timelock:  ", address(timelock));
        console.log("  vKNT:      ", address(voteKnt));
        console.log("  Gauge:     ", address(gaugeController));
        console.log("  Karma:     ", address(karma));
        console.log("  DKNT:      ", address(dknt));
        console.log("");
        console.log("IDENTITY (1):");
        console.log("  DIDRegistry:", address(didRegistry));
        console.log("");
        console.log("TREASURY (2):");
        console.log("  FeeGov:       ", address(feeGov));
        console.log("  ValidatorVault:", address(validatorVault));
        console.log("");
        console.log("DEFI (1):");
        console.log("  Markets: ", address(markets));
        console.log("");
        console.log("ALREADY DEPLOYED (7 - not touched):");
        console.log("  StakedKNT:        0xAb95c8B59f68cE922F2f334DFC8bb8f5B0525326");
        console.log("  AMMV2Factory:     0x84CF0A13db1BE8E1f0676405CfcBC8b09692fd1C");
        console.log("  AMMV2Router:      0x2382F7A49Fa48E1f91bEc466C32E1d7f13Ec8206");
        console.log("  LinearCurve:      0xD13Ab81F02449b1630EcD940bE5fB9cD367225b4");
        console.log("  ExponentialCurve: 0xBc92f4e290f8Ad03f5348F81A27Fb2AF3B37ec47");
        console.log("  LSSVMPairFactory: 0xB43dB9af0c5CACB99f783E30398ee0AEE6744212");
        console.log("  Perp:             0xD984fEd38C98c1eAB66E577FD1dDC8dcD88Ea799");
        console.log("");
        console.log("TOTAL: 13 new + 7 existing = 20/20 contracts");
        console.log("================================================================================");
    }
}
