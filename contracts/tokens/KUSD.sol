/*
 ___       ___  ___     ___    ___
|\  \     |\  \|\  \   |\  \  /  /|
\ \  \    \ \  \\\  \  \ \  \/  / |
 \ \  \    \ \  \\\  \  \ \    / /
  \ \  \____\ \  \\\  \  /     \/
   \ \_______\ \_______\/  /\   \
    \|_______|\|_______/__/ /\ __\
                       |__|/ \|__|


*/
// SPDX-License-Identifier: BSD-3-Clause
// Copyright (c) 2025 kinet labs.
pragma solidity ^0.8.31;

import { KRC20B } from "./KRC20B.sol";

contract KntDollar is KRC20B {
    string public constant _name = "Knt Dollar";
    string public constant _symbol = "KUSD";
    constructor() KRC20B(_name, _symbol) { }
}

