// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BaseERC20} from "./BaseERC-20.sol";

//***************Weird Token A19: approve-with-balance-verify***************//

contract A19 is BaseERC20 {
    address public owner;
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowed;

    constructor() BaseERC20("A19 Token", "A19", 18) {
        owner = msg.sender;
        _mint(owner, 10000000 * 10 ** decimals()); // Mint 10 million tokens
    }

    function approve(address _spender, uint256 _amount) public override returns (bool success) {
        // approval amount cannot exceed the balance
        require(balances[msg.sender] >= _amount); // BUG:
        // update allowed amount
        allowed[msg.sender][_spender] = _amount;
        return true;
    }
}
