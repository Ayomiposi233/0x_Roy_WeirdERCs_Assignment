// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {A17} from "../../src/ERC-20s/A17.sol";

contract A17Test is Test {
    A17 public a17;
    address public owner = makeAddr("owner");

    function setUp() public {
        a17 = new A17();
    }

    function testAnyoneCanSetOwner() public {
        address newOwner = makeAddr("newOwner");

        // Anyone can call setOwner
        a17.setOwner(newOwner);

        // Check if the owner has been changed
        assertEq(a17.owner(), newOwner, "Owner should be changed to newOwner");
    }
}
