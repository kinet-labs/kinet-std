// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.31;

import { Script, console } from "forge-std/Script.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { AMMV3Factory } from "@kinet/contracts/amm/AMMV3Factory.sol";
import { AMMV3Pool } from "@kinet/contracts/amm/AMMV3Pool.sol";
import { KntMainnet } from "@kinet/contracts/deployments/Addresses.sol";

/**
 * @title CreateInitialPools
 * @notice Creates V3 concentrated liquidity pools on Knt mainnet with one-sided WKNT liquidity
 *
 * Pools created:
 *   1. WKNT/KUSD  - 0.3% fee tier, KNT = $1
 *   2. WKNT/KETH  - 0.3% fee tier, ETH = $3,000
 *   3. KBTC/WKNT  - 0.3% fee tier, BTC = $100,000
 *
 * One-sided liquidity strategy:
 *   We only hold WKNT. In V3, a position entirely below current tick needs only
 *   token0; entirely above needs only token1. For each pool we place a WKNT-only
 *   range on the correct side depending on whether WKNT is token0 or token1.
 *
 *   WKNT/KUSD: WKNT is token0 -> range BELOW current tick (sell WKNT as price rises)
 *   WKNT/KETH: WKNT is token0 -> range BELOW current tick
 *   KBTC/WKNT: WKNT is token1 -> range ABOVE current tick
 *
 * Usage:
 *   KNT_PRIVATE_KEY=0x... WKNT_AMOUNT=1000 forge script contracts/script/CreateInitialPools.s.sol \
 *     --rpc-url https://api.knt.network/mainnet/ext/bc/C/rpc --broadcast --legacy -vvv
 */
contract CreateInitialPools is Script {
    using SafeERC20 for IERC20;
    // --- V3 constants ---
    uint24 constant FEE_30BPS = 3000;
    int24 constant TICK_SPACING = 60;
    int24 constant MIN_TICK = -887272;
    int24 constant MAX_TICK = 887272;

    // Range width in ticks (~40% price range each direction)
    int24 constant RANGE_TICKS = 10000;

    // --- Mainnet addresses ---
    address constant WKNT = KntMainnet.WKNT;
    address constant KUSD = KntMainnet.KUSD;
    address constant KETH = KntMainnet.KETH;
    address constant KBTC = KntMainnet.KBTC;
    address constant V3_FACTORY = KntMainnet.V3_FACTORY;

    function run() external {
        uint256 deployerKey = vm.envUint("KNT_PRIVATE_KEY");
        address deployer = vm.addr(deployerKey);

        uint256 totalWknt = vm.envOr("WKNT_AMOUNT", uint256(1000)) * 1 ether;

        console.log("=== Create Initial V3 Pools (Knt Mainnet) ===");
        console.log("Chain ID:", block.chainid);
        console.log("Deployer:", deployer);
        console.log("Total WKNT for liquidity:", totalWknt / 1e18);
        console.log("");

        // Split: 40% USDC pool, 30% ETH pool, 30% BTC pool
        uint256 wkntForUsdc = totalWknt * 40 / 100;
        uint256 wkntForEth = totalWknt * 30 / 100;
        uint256 wkntForBtc = totalWknt - wkntForUsdc - wkntForEth;

        vm.startBroadcast(deployerKey);

        // Wrap native KNT if WKNT balance is insufficient
        uint256 wkntBal = IERC20(WKNT).balanceOf(deployer);
        if (wkntBal < totalWknt) {
            uint256 needed = totalWknt - wkntBal;
            console.log("Wrapping", needed / 1e18, "KNT...");
            (bool ok,) = WKNT.call{ value: needed }(abi.encodeWithSignature("deposit()"));
            require(ok, "WKNT deposit failed");
        }

        _createPoolWkntLusd(deployer, wkntForUsdc);
        _createPoolWkntLeth(deployer, wkntForEth);
        _createPoolLbtcWknt(deployer, wkntForBtc);

        vm.stopBroadcast();

        console.log("");
        console.log("=== ALL 3 POOLS CREATED ===");
    }

    // =========================================================================
    // WKNT/KUSD  (token0=WKNT, token1=KUSD)
    // =========================================================================
    // Price(token1/token0) at KNT=$1:
    //   1 WKNT(1e18 raw) = 1 KUSD(1e6 raw) => price = 1e6/1e18 = 1e-12
    //   sqrtPriceX96 = sqrt(1e-12) * 2^96 = 1e-6 * 2^96 = 79,228,162,514,264
    function _createPoolWkntLusd(address deployer, uint256 wkntAmount) internal {
        console.log("--- WKNT/KUSD Pool (KNT=$1) ---");
        require(WKNT < KUSD, "token order");

        address pool = _getOrCreatePool(WKNT, KUSD, FEE_30BPS);
        AMMV3Pool v3 = AMMV3Pool(pool);

        if (v3.sqrtPriceX96() == 0) {
            uint160 sqrtPrice = 79228162514264;
            v3.initializePrice(sqrtPrice);
            console.log("  Initialized sqrtPriceX96:", uint256(sqrtPrice));
        }

        // One-sided WKNT (token0): range below current tick
        int24 currentTick = v3.tick();
        int24 tickUpper = _roundDown(currentTick, TICK_SPACING);
        int24 tickLower = _roundDown(currentTick - RANGE_TICKS, TICK_SPACING);
        tickLower = _clampLower(tickLower);
        require(tickLower < tickUpper, "bad range");

        uint160 sqrtA = _getSqrtRatioAtTick(tickLower);
        uint160 sqrtB = _getSqrtRatioAtTick(tickUpper);
        uint128 liq = _liquidityFromToken0(sqrtA, sqrtB, wkntAmount);

        _mintPosition(v3, pool, deployer, tickLower, tickUpper, liq, wkntAmount, true);
    }

    // =========================================================================
    // WKNT/KETH  (token0=WKNT, token1=KETH)
    // =========================================================================
    // Price at KNT=$1, ETH=$3000 (both 18 dec):
    //   price = 1/3000 = 3.333e-4
    //   sqrtPriceX96 = sqrt(1/3000) * 2^96 = 1,446,710,199,989,315,456
    function _createPoolWkntLeth(address deployer, uint256 wkntAmount) internal {
        console.log("--- WKNT/KETH Pool (KNT=$1, ETH=$3000) ---");
        require(WKNT < KETH, "token order");

        address pool = _getOrCreatePool(WKNT, KETH, FEE_30BPS);
        AMMV3Pool v3 = AMMV3Pool(pool);

        if (v3.sqrtPriceX96() == 0) {
            uint160 sqrtPrice = 1446710199989315456;
            v3.initializePrice(sqrtPrice);
            console.log("  Initialized sqrtPriceX96:", uint256(sqrtPrice));
        }

        int24 currentTick = v3.tick();
        int24 tickUpper = _roundDown(currentTick, TICK_SPACING);
        int24 tickLower = _roundDown(currentTick - RANGE_TICKS, TICK_SPACING);
        tickLower = _clampLower(tickLower);
        require(tickLower < tickUpper, "bad range");

        uint160 sqrtA = _getSqrtRatioAtTick(tickLower);
        uint160 sqrtB = _getSqrtRatioAtTick(tickUpper);
        uint128 liq = _liquidityFromToken0(sqrtA, sqrtB, wkntAmount);

        _mintPosition(v3, pool, deployer, tickLower, tickUpper, liq, wkntAmount, true);
    }

    // =========================================================================
    // KBTC/WKNT  (token0=KBTC, token1=WKNT)
    // =========================================================================
    // Price at BTC=$100000, KNT=$1 (KBTC 8dec, WKNT 18dec):
    //   1 KBTC(1e8 raw) = 100000 WKNT(1e23 raw) => price = 1e23/1e8 = 1e15
    //   sqrtPriceX96 = sqrt(1e15) * 2^96 = 31622776.6 * 2^96
    //                = 2,505,414,483,750,479,251,915,866,636,288
    function _createPoolLbtcWknt(address deployer, uint256 wkntAmount) internal {
        console.log("--- KBTC/WKNT Pool (BTC=$100000, KNT=$1) ---");
        require(KBTC < WKNT, "token order");

        address pool = _getOrCreatePool(KBTC, WKNT, FEE_30BPS);
        AMMV3Pool v3 = AMMV3Pool(pool);

        if (v3.sqrtPriceX96() == 0) {
            uint160 sqrtPrice = 2505414483750479251915866636288;
            v3.initializePrice(sqrtPrice);
            console.log("  Initialized sqrtPriceX96:", uint256(sqrtPrice));
        }

        // One-sided WKNT (token1): range above current tick
        int24 currentTick = v3.tick();
        int24 tickLower = _roundUp(currentTick + 1, TICK_SPACING);
        int24 tickUpper = _roundUp(currentTick + RANGE_TICKS, TICK_SPACING);
        tickUpper = _clampUpper(tickUpper);
        require(tickLower < tickUpper, "bad range");

        uint160 sqrtA = _getSqrtRatioAtTick(tickLower);
        uint160 sqrtB = _getSqrtRatioAtTick(tickUpper);
        uint128 liq = _liquidityFromToken1(sqrtA, sqrtB, wkntAmount);

        _mintPosition(v3, pool, deployer, tickLower, tickUpper, liq, wkntAmount, false);
    }

    // =========================================================================
    // Pool creation & minting
    // =========================================================================

    function _getOrCreatePool(address tokenA, address tokenB, uint24 fee) internal returns (address pool) {
        AMMV3Factory factory = AMMV3Factory(V3_FACTORY);
        pool = factory.getPool(tokenA, tokenB, fee);
        if (pool == address(0)) {
            pool = factory.createPool(tokenA, tokenB, fee);
            console.log("  Created pool:", pool);
        } else {
            console.log("  Pool exists:", pool);
        }
    }

    function _mintPosition(
        AMMV3Pool v3,
        address pool,
        address deployer,
        int24 tickLower,
        int24 tickUpper,
        uint128 liq,
        uint256 tokenAmount,
        bool isToken0
    ) internal {
        if (liq == 0) {
            console.log("  WARN: Zero liquidity, skipping");
            return;
        }

        // Transfer the one-sided token to the pool (push pattern)
        address token = isToken0 ? v3.token0() : v3.token1();
        IERC20(token).safeTransfer(pool, tokenAmount);

        // V3 mint expects both tokens to be present. For one-sided, only one token
        // is needed but the pool checks balances. The other side should require 0.
        v3.mint(deployer, tickLower, tickUpper, liq);

        console.log("  Minted position:");
        console.log("    Amount:", tokenAmount / 1e18);
        console.log("    Liquidity:", uint256(liq));
        console.log(string.concat("    Ticks: [", _tickStr(tickLower), ", ", _tickStr(tickUpper), ")"));
    }

    // =========================================================================
    // Tick math (copied from AMMV3Pool - Uniswap V3 TickMath)
    // =========================================================================

    function _getSqrtRatioAtTick(int24 tick_) internal pure returns (uint160) {
        // forge-lint: disable-next-line(unsafe-typecast)
        uint256 absTick = tick_ < 0 ? uint256(uint24(-tick_)) : uint256(uint24(tick_));
        // forge-lint: disable-next-line(unsafe-typecast)
        require(absTick <= uint256(int256(MAX_TICK)), "tick OOB");

        uint256 ratio = absTick & 0x1 != 0 ? 0xfffcb933bd6fad37aa2d162d1a594001 : 0x100000000000000000000000000000000;
        if (absTick & 0x2 != 0) ratio = (ratio * 0xfff97272373d413259a46990580e213a) >> 128;
        if (absTick & 0x4 != 0) ratio = (ratio * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128;
        if (absTick & 0x8 != 0) ratio = (ratio * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128;
        if (absTick & 0x10 != 0) ratio = (ratio * 0xffcb9843d60f6159c9db58835c926644) >> 128;
        if (absTick & 0x20 != 0) ratio = (ratio * 0xff973b41fa98c081472e6896dfb254c0) >> 128;
        if (absTick & 0x40 != 0) ratio = (ratio * 0xff2ea16466c96a3843ec78b326b52861) >> 128;
        if (absTick & 0x80 != 0) ratio = (ratio * 0xfe5dee046a99a2a811c461f1969c3053) >> 128;
        if (absTick & 0x100 != 0) ratio = (ratio * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128;
        if (absTick & 0x200 != 0) ratio = (ratio * 0xf987a7253ac413176f2b074cf7815e54) >> 128;
        if (absTick & 0x400 != 0) ratio = (ratio * 0xf3392b0822b70005940c7a398e4b70f3) >> 128;
        if (absTick & 0x800 != 0) ratio = (ratio * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128;
        if (absTick & 0x1000 != 0) ratio = (ratio * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128;
        if (absTick & 0x2000 != 0) ratio = (ratio * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128;
        if (absTick & 0x4000 != 0) ratio = (ratio * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128;
        if (absTick & 0x8000 != 0) ratio = (ratio * 0x31be135f97d08fd981231505542fcfa6) >> 128;
        if (absTick & 0x10000 != 0) ratio = (ratio * 0x9aa508b5b7a84e1c677de54f3e99bc9) >> 128;
        if (absTick & 0x20000 != 0) ratio = (ratio * 0x5d6af8dedb81196699c329225ee604) >> 128;
        if (absTick & 0x40000 != 0) ratio = (ratio * 0x2216e584f5fa1ea926041bedfe98) >> 128;
        if (absTick & 0x80000 != 0) ratio = (ratio * 0x48a170391f7dc42444e8fa2) >> 128;

        if (tick_ > 0) ratio = type(uint256).max / ratio;
        return uint160((ratio >> 32) + (ratio % (1 << 32) == 0 ? 0 : 1));
    }

    // =========================================================================
    // Liquidity math
    // =========================================================================

    /// @dev L = amount0 * sqrtA * sqrtB / (sqrtB - sqrtA)  (for range below current price)
    function _liquidityFromToken0(uint160 sqrtA, uint160 sqrtB, uint256 amount0) internal pure returns (uint128) {
        if (sqrtA > sqrtB) (sqrtA, sqrtB) = (sqrtB, sqrtA);
        uint256 diff = uint256(sqrtB) - uint256(sqrtA);
        if (diff == 0) return 0;
        uint256 intermediate = (amount0 * uint256(sqrtA)) / (1 << 96);
        uint256 liq = (intermediate * uint256(sqrtB)) / diff;
        // forge-lint: disable-next-line(unsafe-typecast)
        return liq > type(uint128).max ? type(uint128).max : uint128(liq);
    }

    /// @dev L = amount1 * 2^96 / (sqrtB - sqrtA)  (for range above current price)
    function _liquidityFromToken1(uint160 sqrtA, uint160 sqrtB, uint256 amount1) internal pure returns (uint128) {
        if (sqrtA > sqrtB) (sqrtA, sqrtB) = (sqrtB, sqrtA);
        uint256 diff = uint256(sqrtB) - uint256(sqrtA);
        if (diff == 0) return 0;
        uint256 liq = (amount1 << 96) / diff;
        // forge-lint: disable-next-line(unsafe-typecast)
        return liq > type(uint128).max ? type(uint128).max : uint128(liq);
    }

    // =========================================================================
    // Tick rounding
    // =========================================================================

    function _roundDown(int24 t, int24 s) internal pure returns (int24) {
        int24 c = t / s;
        if (t < 0 && t % s != 0) c--;
        return c * s;
    }

    function _roundUp(int24 t, int24 s) internal pure returns (int24) {
        int24 c = t / s;
        if (t > 0 && t % s != 0) c++;
        return c * s;
    }

    function _clampLower(int24 t) internal pure returns (int24) {
        int24 minAligned = _roundUp(MIN_TICK, TICK_SPACING);
        return t < minAligned ? minAligned : t;
    }

    function _clampUpper(int24 t) internal pure returns (int24) {
        int24 maxAligned = _roundDown(MAX_TICK, TICK_SPACING);
        return t > maxAligned ? maxAligned : t;
    }

    function _tickStr(int24 t) internal pure returns (string memory) {
        // forge-lint: disable-next-line(unsafe-typecast)
        if (t >= 0) return vm.toString(uint256(uint24(t)));
        // forge-lint: disable-next-line(unsafe-typecast)
        return string.concat("-", vm.toString(uint256(uint24(-t))));
    }
}
