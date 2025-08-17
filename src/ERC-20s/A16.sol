// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "lib/forge-std/src/interfaces/IERC20.sol";

//****************Weird Token A16: custom-call-abuse****************//

contract A16 is IERC20 {
    string public name = "A16 Token";
    string public symbol = "A16";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    constructor() {
        totalSupply = 1000000 * 10 ** decimals;
        balances[msg.sender] = totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return allowances[owner][spender];
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
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        require(to != address(0), "Transfer to zero address");
        require(balances[from] >= amount, "Insufficient balance");
        require(allowances[from][msg.sender] >= amount, "Insufficient allowance");

        balances[from] -= amount;
        balances[to] += amount;
        allowances[from][msg.sender] -= amount;

        emit Transfer(from, to, amount);
        return true;
    }

    // VULNERABLE FUNCTION: Allows arbitrary calls with msg.value
    function transferWithCallback(address _to, uint256 _value, bytes memory _data) public payable returns (bool) {
        require(transfer(_to, _value), "Transfer failed");

        if (_to.code.length > 0) {
            (bool success,) = _to.call{value: msg.value}(_data);
            require(success, "Callback failed");
        }

        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes memory _data) public returns (bool) {
        require(approve(_spender, _value), "Approve failed");

        (bool success,) = _spender.call(_data);
        require(success, "Call failed");

        return true;
    }

    function transferAndCall(address _to, uint256 _value, bytes memory _data) public returns (bool) {
        require(transfer(_to, _value), "Transfer failed");

        (bool success,) = _to.call(_data);
        require(success, "Call failed");

        return true;
    }

    receive() external payable {}
}

// MITIGATION: DO NOT USE CUSTOM CALL IN RECEIVER NOTIFYING.