// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/SinaneToken.sol";

contract SinaneTokenTest is Test {
    SinaneToken token;

    function setUp () public {
        token = new SinaneToken();
    }

    function reachMaxSupply () public {
        for (uint256 supply = 0; supply <= 300; supply++) {
            token.safeMint(address(this));
        }
    }
}
