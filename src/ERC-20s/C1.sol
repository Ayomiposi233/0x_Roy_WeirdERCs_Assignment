// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "lib/forge-std/src/interfaces/IERC20.sol";

//****************Weird Token C1: Central Account Transfer***************//

contract C1 is IERC20 {
    string public name = "C1 Token";
    string public symbol = "C1";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    address public centralAccount;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    // event Transfer(address indexed from, address indexed to, uint256 value);

    constructor() {
        totalSupply = 1000000 * 10 ** decimals;
        balances[msg.sender] = totalSupply;
        centralAccount = msg.sender;
    }

    modifier onlycentralAccount() {
        require(msg.sender == centralAccount, "Only central account");
        _;
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

    // EXCESSIVE AUTHORITY: Central account can transfer anyone's tokens
    function zero_fee_transaction(address _from, address _to, uint256 _amount)
        public
        onlycentralAccount
        returns (bool success)
    {
        if (balances[_from] >= _amount && _amount > 0 && balances[_to] + _amount > balances[_to]) {
            balances[_from] -= _amount;
            balances[_to] += _amount;
            emit Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    function setCentralAccount(address newCentralAccount) public onlycentralAccount {
        centralAccount = newCentralAccount;
    }
}
