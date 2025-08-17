// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "lib/forge-std/src/interfaces/IERC20.sol";

//***************Weird Token A13: approveProxy-keccak256***************//

contract A13 is IERC20 {
    string public name = "A13 Token";
    string public symbol = "A13";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowed;
    mapping(address => uint256) public nonces;

    // event Transfer(address indexed from, address indexed to, uint256 value);
    

    constructor() {
        totalSupply = 1000000 * 10**decimals;
        balances[msg.sender] = totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return allowed[owner][spender];
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        require(to != address(0), "Transfer to zero address");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        require(to != address(0), "Transfer to zero address");
        require(balances[from] >= amount, "Insufficient balance");
        require(allowed[from][msg.sender] >= amount, "Insufficient allowance");
        
        balances[from] -= amount;
        balances[to] += amount;
        allowed[from][msg.sender] -= amount;
        
        emit Transfer(from, to, amount);
        return true;
    }

    
    function approveProxy(
        address _from, 
        address _spender, 
        uint256 _value,
        uint8 _v,
        bytes32 _r, 
        bytes32 _s
    ) public returns (bool success) {
        uint256 nonce = nonces[_from];
        
        
        bytes32 hash = keccak256(abi.encodePacked(_from, _spender, _value, nonce, name));
        
        
        if(_from != ecrecover(hash, _v, _r, _s)) revert("Invalid signature");
        
        allowed[_from][_spender] = _value;
        emit Approval(_from, _spender, _value);
        nonces[_from] = nonce + 1;
        return true;
    }
}

// MITIGATION: HANDLE TRANSFERS FROM ZERO ADDRESS.