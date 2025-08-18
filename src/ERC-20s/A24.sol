// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BaseERC20} from "./BaseERC-20.sol";

//***************Weird Token A24: getToken-anyone***************//

contract A24 is BaseERC20 {
    address public owner;
    mapping(address => uint256) public balances;

    constructor() BaseERC20("A21 Token", "A21", 18) {
        owner = msg.sender;
        _mint(owner, 10000000 * 10 ** decimals()); // Mint 10 million tokens
    }

    function getToken(uint256 _value) public returns (bool success){
    uint newTokens = _value;
    balances[msg.sender] = balances[msg.sender] + newTokens;
    return true;
    }
}
