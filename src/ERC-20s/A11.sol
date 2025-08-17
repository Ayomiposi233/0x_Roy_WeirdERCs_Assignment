// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BaseERC20} from "./BaseERC-20.sol";


//***************Weird Token A11: pauseTransfer-anyone***************//

contract A11 is BaseERC20 {
    address private immutable owner;

    constructor(address _owner) BaseERC20("A11 Token", "A11", 18) {
        owner = _owner;
        _mint(owner, 10000000 * 10 ** decimals()); // Mint 10 million tokens
    }

    modifier onlyOwner() {
        require(msg.sender != owner, "Not the owner"); // BUG: should be "== i.e Is the owner" to allow owner actions
        _;
    }

    bool public tokenTransfer;

    function enableTokenTransfer() external onlyOwner {
        tokenTransfer = true;
    }

    function disableTokenTransfer() external onlyOwner {
        tokenTransfer = false;
    }
}

// MITIGATION: ALWAYS ENSURE THAT PRIVILEGES ARE PROPERLY CHECKED.


