// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {A19} from "../../src/ERC-20s/A19.sol";

contract A19Test is Test {
    A19 public a19;
    address public owner = makeAddr("owner");
    address public dex = makeAddr("dex");
    address public user = makeAddr("user");

    function setUp() public {
        a19 = new A19();
    }

    function testApproveBalanceVerifyBug() public {
    uint256 futureBalance = 20000 * 10**18;  
    vm.prank(user);
    vm.expectRevert();
    a19.approve(dex, futureBalance);
    }
}