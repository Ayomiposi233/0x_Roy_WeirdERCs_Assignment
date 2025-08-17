// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BaseERC20} from "./BaseERC-20.sol";
import {IERC20} from "lib/forge-std/src/interfaces/IERC20.sol";


//****************Weird Token A15: custom-fallback-bypass-ds-auth****************//

contract A15 is IERC20 {
    string public name = "A15 Token";
    string public symbol = "A15";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    
    address public owner;
    
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    
    

    constructor() {
        totalSupply = 1000000 * 10**decimals;
        balances[msg.sender] = totalSupply;
        owner = msg.sender;
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig), "Not authorized");
        _;
    }

    
    function isAuthorized(address src, bytes4 sig) public view returns (bool) {
        if (src == address(this)) {
            return true;  
        } else if (src == owner) {
            return true;
        }
        return false;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return balances[account];
    }

    function allowance(address owner_, address spender) public view override returns (uint256) {
        return allowances[owner_][spender];
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        return _transfer(msg.sender, to, amount);
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        require(allowances[from][msg.sender] >= amount, "Insufficient allowance");
        allowances[from][msg.sender] -= amount;
        return _transfer(from, to, amount);
    }

    function _transfer(address from, address to, uint256 amount) internal returns (bool) {
        require(to != address(0), "Transfer to zero address");
        require(balances[from] >= amount, "Insufficient balance");
        
        balances[from] -= amount;
        balances[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    
    function transferFrom(
        address _from, 
        address _to, 
        uint256 _amount, 
        bytes memory _data, 
        string memory _custom_fallback
    ) public returns (bool success) {
        require(_transfer(_from, _to, _amount), "Transfer failed");
        
        if (_to.code.length > 0) {
            
            (bool callSuccess,) = _to.call(
                abi.encodeWithSignature(
                    _custom_fallback, 
                    _from, 
                    _amount, 
                    _data
                )
            );
            
        }
        
        return true;
    }

    
    function emergencyStop() external auth {
        
        selfdestruct(payable(owner));
    }

    function setOwner(address newOwner) external auth {
        owner = newOwner;
    }
}

// MITIGATION: AVOID USING CUSTOM FALLBACKS.
