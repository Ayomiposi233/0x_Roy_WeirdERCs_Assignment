pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {A14} from "../../src/ERC-20s/A14.sol";

contract A14Test is Test {
    A14 public a14;
    address public owner = makeAddr("owner");

    function setUp() public {
        a14 = new A14();
        a14.Owned(); // Set the owner to the contract deployer
    }

    function testAnyoneCanOwn() public {
        address randomUser = makeAddr("randomUser");
        vm.startPrank(randomUser);
        a14.Owned(); // Random user can call Owned to set themselves as owner
        vm.stopPrank();
        assertEq(a14.owner(), randomUser, "Random user should be the owner");
    }
}