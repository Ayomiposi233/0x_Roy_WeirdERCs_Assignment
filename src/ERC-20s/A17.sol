// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BaseERC20} from "./BaseERC-20.sol";

//***************Weird Token A17: setowner-anyone***************//

contract A17 is BaseERC20 {
    address public owner;

    constructor() BaseERC20("A17 Token", "A17", 18) {
        owner = msg.sender;
        _mint(owner, 10000000 * 10 ** decimals()); // Mint 10 million tokens
    }

    function setOwner(address _owner) public returns (bool success) { // BUG: anyone can set owner
        owner = _owner; 
        return true;
    }
}

// MITIGATION: THIS IS A BUG. THE SETOWNER FUNCTION SHOULD ONLY BE ACCESSIBLE BY THE CURRENT OWNER.
