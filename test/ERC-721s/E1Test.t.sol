// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {E1} from "../../src/ERC-721s/E1.sol";
import {E1Helper} from "../../src/ERC-721s/E1.sol";

// contract E1Test is Test {
//     E1 token;
//     E1Helper automation;
//     address user1 = address(0x1);
//     address user2 = address(0x2);

//     function setUp() public {
//         token = new E1();
//         automation = new E1Helper();
//     }

//     function testIncorrectTransfer() public {
//         // User1 is the original owner of token ID 1
//         assertEq(token.balance(user1, 1), 1);
//         assertEq(token.ownerOf(1), user1);

//         // Attempt to transfer using automation
//         automation.transferAsset(address(token), user1, user2, 1, 1);

//         // Check results - this will show the inconsistency
//         // ERC721 transfer happened (ownership changed)
//         assertEq(token.ownerOf(1), user2);
        
//         // But ERC1155 balance wasn't properly transferred
//         // This is the vulnerability - the automation thought it was only ERC721
//         assertEq(token.balanceOf(user1, 1), 1); // Still has balance
//         assertEq(token.balanceOf(user2, 1), 0); // Didn't receive
//     }

//     // Helper functions to make assertions clearer
//     function tokenBalanceOf(address account, uint256 id) public view returns (uint256) {
//         (bool success, bytes memory data) = address(token).staticcall(
//             abi.encodeWithSignature("balanceOf(address,uint256)", account, id)
//         );
//         require(success, "balanceOf call failed");
//         return abi.decode(data, (uint256));
//     }

//     function tokenOwnerOf(uint256 tokenId) public view returns (address) {
//         (bool success, bytes memory data) = address(token).staticcall(
//             abi.encodeWithSignature("ownerOf(uint256)", tokenId)
//         );
//         require(success, "ownerOf call failed");
//         return abi.decode(data, (address));
//     }
// }