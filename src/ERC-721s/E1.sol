// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//***************Weird Token E1:Simultaneous ERC721 and ERC1155 Standards***************//

// Simplified ERC721 interface
interface IERC721 {
    function transferFrom(address from, address to, uint256 tokenId) external;
}

// Simplified ERC1155 interface
interface IERC1155 {
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
}

// A token that implements both ERC721 and ERC1155 interfaces
contract E1 {
    mapping(uint256 => address) private _owners; // ERC721-style ownership
    mapping(uint256 => mapping(address => uint256)) private _balances; // ERC1155-style balances

    constructor() {
        // Mint token ID 1 as both ERC721 and ERC1155
        _owners[1] = msg.sender;
        _balances[1][msg.sender] = 1;
    }

    // ERC721 transfer
    function transferFrom(address from, address to, uint256 tokenId) external {
        require(_owners[tokenId] == from, "Not owner");
        _owners[tokenId] = to;
    }

    // ERC1155 transfer
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata) external {
        require(_balances[id][from] >= amount, "Insufficient balance");
        _balances[id][from] -= amount;
        _balances[id][to] += amount;
    }

    // Check if supports interface (would return true for both in real implementation)
    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return interfaceId == type(IERC721).interfaceId || interfaceId == type(IERC1155).interfaceId;
    }
}

// Vulnerable transfer automation contract
contract E1Helper {
    function transferAsset(address token, address from, address to, uint256 id, uint256 amount) external {
        // Try to detect if it's ERC721 or ERC1155
        try IERC721(token).transferFrom(from, to, id) {
            // If ERC721 call succeeds, we assume it's ERC721
            return;
        } catch {
            // If ERC721 fails, try ERC1155
            IERC1155(token).safeTransferFrom(from, to, id, amount, "");
        }
    }
}
