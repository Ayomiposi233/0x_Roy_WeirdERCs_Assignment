// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LegacyNFT {
    mapping(uint256 => address) public owners;

    function mint() external returns (uint256 id) {
        id = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender)));
        owners[id] = msg.sender;
        return id;
    }

    function transfer(address to, uint256 id) external {
        require(owners[id] == msg.sender, "Not owner");
        owners[id] = to;
    }
}

contract VulnerableWrapper {
    LegacyNFT public legacyNFT;
    mapping(uint256 => address) public owners;

    constructor(address _legacyNFT) {
        legacyNFT = LegacyNFT(_legacyNFT);
    }

    function wrap(uint256 legacyId) external {
        legacyNFT.transfer(address(this), legacyId);
        owners[legacyId] = msg.sender;
    }

    function unwrap(uint256 legacyId) external {
        require(owners[legacyId] == msg.sender, "Not owner");
        legacyNFT.transfer(msg.sender, legacyId);
        delete owners[legacyId];
    }

    // Vulnerable - missing access control
    function transferFrom(address, address to, uint256 tokenId) external {
        owners[tokenId] = to;
    }
}
