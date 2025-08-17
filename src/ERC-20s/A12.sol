// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;
import {IERC20} from "lib/forge-std/src/interfaces/IERC20.sol";

//***************Weird Token A12: transferProxy-keccak256***************//

contract A12 is IERC20 {
    string public name = "A12 Token";
    string public symbol = "A12";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;
    mapping(address => bool) public transferAllowed;
    mapping(address => uint256) public nonces;

    
    

    constructor() {
        totalSupply = 1000000 * 10**decimals;
        balances[msg.sender] = totalSupply;
        transferAllowed[msg.sender] = true;
    }

    modifier transferAllowedModifier(address _from) {
        require(transferAllowed[_from], "Transfer not allowed");
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

    
    function transferProxy(
        address _from, 
        address _to, 
        uint256 _value, 
        uint256 _feeMesh,
        uint8 _v,
        bytes32 _r, 
        bytes32 _s
    ) public transferAllowedModifier(_from) returns (bool) {
        require(_to != address(0), "Transfer to zero address");
        require(balances[_from] >= _value, "Insufficient balance");
        
        
        bytes32 h = keccak256(abi.encodePacked(_from, _to, _value, _feeMesh, nonces[_from], name));
        
        
        if(_from != ecrecover(h, _v, _r, _s)) revert("Invalid signature");
        
        balances[_from] -= _value;
        balances[_to] += _value;
        nonces[_from]++;
        
        emit Transfer(_from, _to, _value);
        return true;
    }

    function setTransferAllowed(address _addr, bool _allowed) external {
        require(msg.sender == _addr || balances[msg.sender] > 0, "Not authorized");
        transferAllowed[_addr] = _allowed;
    }
}

// MITIGATION: HANDLE TRANSFERS FROM ZERO ADDRESS.