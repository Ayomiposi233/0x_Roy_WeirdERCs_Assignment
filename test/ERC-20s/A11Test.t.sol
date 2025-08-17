// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {A11} from "../../src/ERC-20s/A11.sol";

contract A11Test is Test {
    A11 public a11;
    address public owner = makeAddr("owner");

    function setUp() public {
        a11 = new A11(owner);
    }

    function testAnyoneCanEnableTokenTransfer() public {
        address randomUser = makeAddr("randomUser");
        vm.startPrank(randomUser);
        a11.enableTokenTransfer();
        vm.stopPrank();
        assertTrue(a11.tokenTransfer(), "Token transfer should be enabled by anyone");
    }

    // Same goes for disableTokenTransfer
    // The owner anyways cannot call.
}