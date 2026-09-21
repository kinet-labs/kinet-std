// SPDX-License-Identifier: BSD-3-Clause
// Copyright (c) 2025 kinet labs.
pragma solidity ^0.8.31;

import { KRC20 } from "../tokens/KRC20.sol";

/**
 * @title Mock Tokens for Testing
 * @notice Test versions of Knt ecosystem tokens with public mint
 * @dev NOT FOR PRODUCTION - testing only
 *      Built on KRC20 standard (Knt Request for Comments 20)
 */

/// @notice Mock Knt Dollar for testing
contract MockKUSD is KRC20 {
    constructor() KRC20("Mock Knt Dollar", "KUSD") { }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        _burn(from, amount);
    }
}

/// @notice Mock Bridged ETH for testing
contract MockKETH is KRC20 {
    constructor() KRC20("Mock Knt ETH", "KETH") { }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        _burn(from, amount);
    }
}

/// @notice Mock Bridged BTC for testing (8 decimals)
contract MockKBTC is KRC20 {
    uint8 private constant _decimals = 8;

    constructor() KRC20("Mock Knt BTC", "KBTC") { }

    function decimals() public pure override returns (uint8) {
        return _decimals;
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        _burn(from, amount);
    }
}

/// @notice Mock Wrapped KNT for testing
contract MockWKNT is KRC20 {
    constructor() KRC20("Mock Wrapped KNT", "WKNT") { }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        _burn(from, amount);
    }

    /// @notice Wrap native KNT
    function deposit() external payable {
        _mint(msg.sender, msg.value);
    }

    /// @notice Unwrap to native KNT
    function withdraw(uint256 amount) external {
        _burn(msg.sender, amount);
        payable(msg.sender).transfer(amount);
    }

    receive() external payable {
        _mint(msg.sender, msg.value);
    }
}

/// @notice Mock Bridged SOL for testing (9 decimals)
contract MockKSOL is KRC20 {
    uint8 private constant _decimals = 9;

    constructor() KRC20("Mock Knt SOL", "KSOL") { }

    function decimals() public pure override returns (uint8) {
        return _decimals;
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        _burn(from, amount);
    }
}
