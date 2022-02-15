//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NFTContract is ERC721URIStorage {

    uint private tokenCounter;


    constructor() ERC721("Image NFT", "INFT") {


    }

    function _baseURI () internal pure override returns(string memory) {

        return "";
    }

    function createNewToken(string calldata tokenURI) public returns(uint){

        uint currentId = tokenCounter;
        _safeMint(msg.sender, currentId);
        _setTokenURI(currentId,tokenURI);
        tokenCounter++;
        return tokenCounter;
    }

}