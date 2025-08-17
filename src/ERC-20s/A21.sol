// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BaseERC20} from "./BaseERC-20.sol";

//***************Weird Token A21: check-effect-inconsistency***************//

contract A21 is BaseERC20 {
    address public owner;
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

     constructor() BaseERC20("A21 Token", "A21", 18) {
        owner = msg.sender;
        _mint(owner, 10000000 * 10 ** decimals()); // Mint 10 million tokens
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success) {
    require(_value <= allowances[_from][msg.sender]);    // Check the allowance of msg.sender
    allowances[_from][_to] -= _value;    // BUG: update the allowance of _to
    return true;
}
}