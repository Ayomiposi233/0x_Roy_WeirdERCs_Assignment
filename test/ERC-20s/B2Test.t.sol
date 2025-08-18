// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {B2} from "../../src/ERC-20s/B2.sol";

contract B2Test is Test {
    B2 public token;
    address public alice;
    address public bob;

    function setUp() public {
        token = new B2();
        alice = makeAddr("alice");
        bob = makeAddr("bob");

        // Give alice some tokens
        deal(address(token), alice, 10000 * 10 ** 18);
    }

    function test_IncompatibilityProof_ApproveNoReturn() public {
        uint256 approvalAmount = 5000 * 10 ** 18;

        console.log("INCOMPATIBILITY ISSUE: approve() has no return value");
        console.log("This breaks compatibility with contracts expecting bool return");

        vm.prank(alice);
        token.approve(bob, approvalAmount);

        assertEq(token.allowance(alice, bob), approvalAmount);

        console.log("Approval set successfully:", token.allowance(alice, bob));
        console.log("But external contracts expecting 'bool success = token.approve(...)' will fail");
    }

    function test_TransferFromStillWorks() public {
        uint256 approvalAmount = 5000 * 10 ** 18;
        uint256 transferAmount = 2000 * 10 ** 18;

        vm.prank(alice);
        token.approve(bob, approvalAmount);

        vm.prank(bob);
        bool success = token.transferFrom(alice, bob, transferAmount);

        assertTrue(success);
        assertEq(token.balanceOf(bob), transferAmount);
        assertEq(token.balanceOf(alice), 10000 * 10 ** 18 - transferAmount);
        assertEq(token.allowance(alice, bob), approvalAmount - transferAmount);

        console.log("TransferFrom works correctly despite approve incompatibility");
    }

    function test_TransferStillWorks() public {
        uint256 transferAmount = 1000 * 10 ** 18;

        vm.prank(alice);
        bool success = token.transfer(bob, transferAmount);

        assertTrue(success);
        assertEq(token.balanceOf(bob), transferAmount);
        assertEq(token.balanceOf(alice), 10000 * 10 ** 18 - transferAmount);

        console.log("Transfer works normally");
    }

    function test_MultipleApprovals() public {
        address spender1 = makeAddr("spender1");
        address spender2 = makeAddr("spender2");
        uint256 amount1 = 3000 * 10 ** 18;
        uint256 amount2 = 2000 * 10 ** 18;

        vm.prank(alice);
        token.approve(spender1, amount1);

        vm.prank(alice);
        token.approve(spender2, amount2);

        assertEq(token.allowance(alice, spender1), amount1);
        assertEq(token.allowance(alice, spender2), amount2);

        console.log("Multiple approvals work despite missing return value");
        console.log("Spender1 allowance:", token.allowance(alice, spender1));
        console.log("Spender2 allowance:", token.allowance(alice, spender2));
    }

    function test_ApprovalEventEmitted() public {
        uint256 approvalAmount = 1000 * 10 ** 18;

        vm.prank(alice);
        vm.expectEmit(true, true, false, true);
        emit Approval(alice, bob, approvalAmount);
        token.approve(bob, approvalAmount);

        console.log("Approval event is emitted correctly");
    }

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
