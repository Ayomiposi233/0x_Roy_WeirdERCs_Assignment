// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {A21} from "../../src/ERC-20s/A21.sol";

contract A21Test is Test {
    A21 public a21;

    function setUp() public {
        a21 = new A21();
    }

    function testCheckEffectInconsistency() public {
        address user = makeAddr("user");
        address recipient = makeAddr("recipient");
        uint256 amount = 1000 * 10 ** 18;

        // Mint tokens to the user
        vm.prank(a21.owner());
        a21.transfer(user, amount);

        // Approve the recipient to spend tokens on behalf of the user
        vm.prank(user);
        a21.approve(recipient, amount);

        // Attempt to transfer from user to recipient
        vm.prank(recipient);
        vm.expectRevert();
        bool success = a21.transferFrom(user, recipient, amount);
    }
}