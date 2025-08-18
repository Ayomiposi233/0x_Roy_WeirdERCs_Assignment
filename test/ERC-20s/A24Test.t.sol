// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {A24} from "../../src/ERC-20s/A24.sol";

contract A24Test is Test {
    A24 public a24;

    function setUp() public {
        a24 = new A24();
    }

    function testGetTokenAnyone() public {
        uint256 initialBalance = a24.balances(address(a24.owner()));
        uint256 tokensToGet = 1000 * 10 ** a24.decimals();

        // Call getToken to mint tokens to the caller
        vm.prank(address(a24.owner()));
        bool success = a24.getToken(tokensToGet);
        assertTrue(success, "getToken should succeed");

        uint256 newBalance = a24.balances(address(a24.owner()));
        assertEq(newBalance, initialBalance + tokensToGet, "Balance should increase by the minted amount");
    }
}
