// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from  "forge-std/Test.sol";
import {LegacyNFT} from "src/ERC-721s/E2.sol";
import {VulnerableWrapper} from "src/ERC-721s/E2.sol";

contract WrapperTest is Test {
    LegacyNFT legacyNFT;
    VulnerableWrapper wrapper;
    address user1 = address(1);
    address user2 = address(2);

    function setUp() public {
        legacyNFT = new LegacyNFT();
        wrapper = new VulnerableWrapper(address(legacyNFT));
    }

    function testWrapperVulnerability() public {
        uint256 id = legacyNFT.mint();
        legacyNFT.transfer(user1, id);

        vm.startPrank(user1);
        vm.expectRevert("Not owner");
        wrapper.wrap(id);
        assertNotEq(wrapper.owners(id), user1);
        vm.stopPrank();

        vm.prank(user2);
        wrapper.transferFrom(user1, user2, id);

        // State is now inconsistent
        assertEq(wrapper.owners(id), user2);
        assertNotEq(legacyNFT.owners(id), address(wrapper));
    }
}