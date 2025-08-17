// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BaseERC20} from "./BaseERC-20.sol";


//****************Weird Token A14: constructor-case-insensitive****************//

contract A14 is BaseERC20 {
    address public owner;

    constructor() BaseERC20("A14 Token", "A14", 18) { 
    }

    function Owned() public {
        owner = msg.sender; // BUG: constructor name is not correct, should be 'constructor' not 'Owned'
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

// MITIGATION: ENSURE THAT CONSTRUCTOR NAMES ARE CORRECTLY DEFINED AND FOLLOW THE CONVENTION.