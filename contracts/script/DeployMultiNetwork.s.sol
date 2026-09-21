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

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title DeployMultiNetwork
 * @notice Deploy Knt standard contracts to multiple networks
 * @dev Simplified deployment for Mainnet, Testnet, and Devnet
 *
 * Networks (all use chain-id 1337 in dev mode):
 * - Mainnet: https://api.knt.network/ext/bc/C/rpc
 * - Testnet: https://api.knt-test.network/ext/bc/C/rpc
 * - Devnet: https://api.knt-dev.network/ext/bc/C/rpc
 *
 * Funded account (from "light energy" mnemonic):
 * - Primary: 0x35D64Ff3f618f7a17DF34DCb21be375A4686a8de
 *
 * Usage:
 *   export KNT_MNEMONIC="<your-mnemonic>"
 *
 *   # Deploy to mainnet
 *   forge script contracts/script/DeployMultiNetwork.s.sol --rpc-url https://api.knt.network/ext/bc/C/rpc --broadcast -vvv
 *
 *   # Deploy to testnet
 *   forge script contracts/script/DeployMultiNetwork.s.sol --rpc-url https://api.knt-test.network/ext/bc/C/rpc --broadcast -vvv
 *
 *   # Deploy to devnet
 *   forge script contracts/script/DeployMultiNetwork.s.sol --rpc-url https://api.knt-dev.network/ext/bc/C/rpc --broadcast -vvv
 */
contract DeployMultiNetwork is Script {
    // Deployer
    address public deployer;
    uint256 public deployerKey;

    // ========== Core Tokens ==========
    WKNT public wknt;
    BridgedETH public leth;
    BridgedBTC public lbtc;
    BridgedUSDC public lusdc;

    // ========== Staking ==========
    StakedKNT public stakedKnt;

    // ========== AMM ==========
    AMMV2Factory public factory;
    AMMV2Router public router;

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

    // ========== LSSVM ==========
    LinearCurve public linearCurve;
    ExponentialCurve public exponentialCurve;
    LSSVMPairFactory public lssvmFactory;

    // ========== DeFi ==========
    Markets public markets;
    Perp public perp;

    // Constants (reduced for low-balance deployments)
    uint256 constant INITIAL_KNT = 100 ether;
    uint256 constant INITIAL_ETH = 10 ether;
    uint256 constant INITIAL_BTC = 1e8;
    uint256 constant INITIAL_USDC = 100_000e6;

    function run() external {
        console.log("=== Deploying Knt Standard Contracts ===");
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

        // Phase 1: Core Tokens
        _deployPhase1CoreTokens();

        // Phase 2: Staking
        _deployPhase2Staking();

        // Phase 3: AMM
        _deployPhase3AMM();

        // Phase 4: LP Pools
        _deployPhase4LPPools();

        // Phase 5: Governance
        _deployPhase5Governance();

        // Phase 6: Identity
        _deployPhase6Identity();

        // Phase 7: Treasury
        _deployPhase7Treasury();

        // Phase 8: LSSVM
        _deployPhase8LSSVM();

        // Phase 9: DeFi
        _deployPhase9DeFi();

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

    function _deployPhase2Staking() internal {
        console.log("--- Phase 2: Staking ---");

        stakedKnt = new StakedKNT(address(wknt));
        console.log("StakedKNT:", address(stakedKnt));

        // Stake some KNT
        uint256 stakeAmount = 10 ether;
        wknt.approve(address(stakedKnt), stakeAmount);
        stakedKnt.stake(stakeAmount);
        console.log("Staked", stakeAmount / 1e18, "KNT");
        console.log("");
    }

    function _deployPhase3AMM() internal {
        console.log("--- Phase 3: AMM ---");

        factory = new AMMV2Factory(deployer);
        console.log("AMMV2Factory:", address(factory));

        router = new AMMV2Router(address(factory), address(wknt));
        console.log("AMMV2Router:", address(router));
        console.log("");
    }

    function _deployPhase4LPPools() internal {
        console.log("--- Phase 4: LP Pools ---");

        // WKNT/KETH
        _createPool(address(wknt), address(leth), 10 ether, 1 ether);
        console.log("WKNT/KETH pool created");

        // WKNT/KBTC
        _createPool(address(wknt), address(lbtc), 10 ether, 1e7);
        console.log("WKNT/KBTC pool created");

        // WKNT/KUSDC
        _createPool(address(wknt), address(lusdc), 10 ether, 500e6);
        console.log("WKNT/KUSDC pool created");

        console.log("");
    }

    function _deployPhase5Governance() internal {
        console.log("--- Phase 5: Governance ---");

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

    function _deployPhase6Identity() internal {
        console.log("--- Phase 6: Identity ---");

        didRegistry = new DIDRegistry(deployer, "knt", true);
        console.log("DIDRegistry:", address(didRegistry));
        console.log("");
    }

    function _deployPhase7Treasury() internal {
        console.log("--- Phase 7: Treasury ---");

        feeGov = new FeeGov(30, 10, 500, deployer);
        console.log("FeeGov:", address(feeGov));

        validatorVault = new ValidatorVault(address(wknt));
        console.log("ValidatorVault:", address(validatorVault));
        console.log("");
    }

    function _deployPhase8LSSVM() internal {
        console.log("--- Phase 8: LSSVM (NFT AMM) ---");

        linearCurve = new LinearCurve();
        console.log("LinearCurve:", address(linearCurve));

        exponentialCurve = new ExponentialCurve();
        console.log("ExponentialCurve:", address(exponentialCurve));

        lssvmFactory = new LSSVMPairFactory(deployer);
        console.log("LSSVMPairFactory:", address(lssvmFactory));

        lssvmFactory.setBondingCurveAllowed(address(linearCurve), true);
        lssvmFactory.setBondingCurveAllowed(address(exponentialCurve), true);
        console.log("");
    }

    function _deployPhase9DeFi() internal {
        console.log("--- Phase 9: DeFi ---");

        markets = new Markets(deployer);
        console.log("Markets:", address(markets));

        perp = new Perp(address(wknt), deployer, deployer);
        console.log("Perp:", address(perp));
        console.log("");
    }

    function _createPool(address tokenA, address tokenB, uint256 amountA, uint256 amountB) internal {
        IERC20(tokenA).approve(address(router), amountA);
        IERC20(tokenB).approve(address(router), amountB);

        router.addLiquidity(tokenA, tokenB, amountA, amountB, 0, 0, deployer, block.timestamp + 1 hours);
    }

    function _printSummary() internal view {
        console.log("");
        console.log("================================================================================");
        console.log("                    DEPLOYMENT COMPLETE");
        console.log("================================================================================");
        console.log("");
        console.log("Chain ID:", block.chainid);
        console.log("");
        console.log("CORE TOKENS:");
        console.log("  WKNT:      ", address(wknt));
        console.log("  KETH:      ", address(leth));
        console.log("  KBTC:      ", address(lbtc));
        console.log("  KUSDC:     ", address(lusdc));
        console.log("");
        console.log("STAKING:");
        console.log("  StakedKNT: ", address(stakedKnt));
        console.log("");
        console.log("AMM:");
        console.log("  Factory:   ", address(factory));
        console.log("  Router:    ", address(router));
        console.log("");
        console.log("GOVERNANCE:");
        console.log("  Timelock:  ", address(timelock));
        console.log("  vKNT:      ", address(voteKnt));
        console.log("  Gauge:     ", address(gaugeController));
        console.log("  Karma:     ", address(karma));
        console.log("  DKNT:      ", address(dknt));
        console.log("");
        console.log("IDENTITY:");
        console.log("  DIDRegistry:", address(didRegistry));
        console.log("");
        console.log("TREASURY:");
        console.log("  FeeGov:       ", address(feeGov));
        console.log("  ValidatorVault:", address(validatorVault));
        console.log("");
        console.log("LSSVM:");
        console.log("  LinearCurve:     ", address(linearCurve));
        console.log("  ExponentialCurve:", address(exponentialCurve));
        console.log("  LSSVMFactory:    ", address(lssvmFactory));
        console.log("");
        console.log("DEFI:");
        console.log("  Markets: ", address(markets));
        console.log("  Perp:    ", address(perp));
        console.log("");
        console.log("================================================================================");
    }
}
