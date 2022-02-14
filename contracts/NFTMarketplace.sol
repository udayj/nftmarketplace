//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "hardhat/console.sol";

contract NFTMarketplace {

    uint public itemCounter;
    uint public numSold; //tracks number of times anything is sold on the marketplace
    struct Item {
        address payable creator;
        address payable seller;
        uint lastPrice;
        address tokenAddress;
        uint tokenId;
        uint itemId;
        bool isRoyaltyEnabled;
        uint royaltyAmount;
    }
    
    Item[] items;
    mapping(address => uint) addressToNumOwned;

    modifier itemExists(uint _itemId) {
        require(_itemId < itemCounter, "Item does not exist");
        _;
    }
    function listItemForSale(address _tokenAddress, 
    uint _price, 
    uint _tokenId, 
    bool _isRoyaltyEnabled, 
    uint _royaltyAmount) public returns(uint){

        require(_price >0, "Must have positive price");

        uint currentId = itemCounter;
        itemCounter++;

        Item memory item = Item(
            payable(msg.sender),
            payable(msg.sender),
            _price,
            _tokenAddress,
            _tokenId,
            currentId,
            _isRoyaltyEnabled,
            _royaltyAmount
            );

        items.push(item);
        IERC721(_tokenAddress).safeTransferFrom(msg.sender, address(this), _tokenId);
        addressToNumOwned[msg.sender]++;
        return currentId;
        

    }

    function buyItem(uint _itemId, uint _newPrice) public payable itemExists(_itemId) {

        
        uint totalPaymentRequired = items[_itemId].lastPrice;
        uint royalty = items[_itemId].isRoyaltyEnabled ? items[_itemId].royaltyAmount : 0;
        totalPaymentRequired += royalty;

        require(msg.value >= totalPaymentRequired,"Insufficient Payment");
        require(_newPrice >0 ,"Must have positive price");
        numSold++;

        address payable seller = items[_itemId].seller;

        addressToNumOwned[seller]++;
        seller.transfer(items[_itemId].lastPrice);

        if(items[_itemId].isRoyaltyEnabled) {
            items[_itemId].creator.transfer(royalty);
        }

        items[_itemId].seller = payable(msg.sender);
        addressToNumOwned[msg.sender]++;
        
        items[_itemId].lastPrice = _newPrice;



    }

    function setPrice(uint _itemId, uint _newPrice) public itemExists(_itemId) {

        require(_newPrice >0 ,"Must have positive price");
        

        items[_itemId].lastPrice = _newPrice;

    }

    function getOwner(uint _itemId) public view itemExists(_itemId) returns(address)  {

        return items[_itemId].seller;
    }

    function itemOwnedBy (address seller) public view returns(Item[] memory) {

        require(addressToNumOwned[seller]>0,"Not owning any NFT");
        Item[] memory itemsOwned = new Item[](addressToNumOwned[seller]);
        uint counter=0;
        for(uint i=0;i< items.length; i++) {

            if(items[i].seller==seller) {

                itemsOwned[counter]=items[i];
                counter+=1;
            }
        }

        return itemsOwned;
        
    }

    function getItem(uint _itemId) public view itemExists(_itemId) returns(Item memory) {

        return items[_itemId];
    }

    function delistItem(uint _itemId) public itemExists(_itemId) {

        require(msg.sender == items[_itemId].seller, "Not the owner of NFT");

        IERC721(items[_itemId].tokenAddress).safeTransferFrom(address(this),msg.sender,items[_itemId].tokenId);

        items[_itemId].seller=payable(address(0));
    }

    
}