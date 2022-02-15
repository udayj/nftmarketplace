//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "hardhat/console.sol";

contract NFTMarketplace {

    uint public itemCounter;
    uint public numSold; //tracks number of times anything is sold on the marketplace

    uint fee;
    address owner;
    /**
    @dev - the seller attribute here also denotes the current owner of the NFT
           the creator stores a reference to the address which listed the NFT for the first time on the platform
           this is the address which will receive the royalty, if enabled
     */
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
    /**
    @dev - this mapping keeps a count of the number of items owned by an address
            it helps us return a dynamic array of items for a given address function itemsOwnedBy
     */
    mapping(address => uint) addressToNumOwned;


    constructor(uint _fee) {

        owner=msg.sender;
        fee=_fee;
    }

    
    receive() external payable {

    }


    modifier itemExists(uint _itemId) {
        require(_itemId < itemCounter, "Item does not exist");
        _;
    }

    modifier notDelisted(uint _itemId) {

        require(items[_itemId].seller!=address(0),"Item Delisted");
        _;
    }
    /**
    @dev - list an item for sale - need the NFT contract address, price to be set, token Id & whether royalty is enabled for
         this NFT
     */

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
        // the NFT is transferred from the lister to the marketplace for efficiency purpose
        // it remains with the marketplace till the NFT is listed
        IERC721(_tokenAddress).safeTransferFrom(msg.sender, address(this), _tokenId);
        addressToNumOwned[msg.sender]++;
        return currentId;
        

    }

    /**

    @dev - any address can buy the NFT provided the pay sufficient payment - price + royalty + marketplace fees
           the function does a basic check for whether the item exists on the marketplace and isnt delisted
    */

    function buyItem(uint _itemId, uint _newPrice) public payable itemExists(_itemId) notDelisted(_itemId){

        
        uint totalPaymentRequired = items[_itemId].lastPrice;
        uint royalty = items[_itemId].isRoyaltyEnabled ? items[_itemId].royaltyAmount : 0;
        totalPaymentRequired += royalty;
        totalPaymentRequired +=fee;
        require(msg.value >= totalPaymentRequired,"Insufficient Payment");
        require(_newPrice >0 ,"Must have positive price");
        numSold++;

        address payable seller = items[_itemId].seller;

        addressToNumOwned[seller]--;
        //transfer price to seller
        seller.transfer(items[_itemId].lastPrice);

        //transfer royalty amount if enabled
        if(items[_itemId].isRoyaltyEnabled) {
            items[_itemId].creator.transfer(royalty);
        }

        items[_itemId].seller = payable(msg.sender);
        addressToNumOwned[msg.sender]++;
        
        items[_itemId].lastPrice = _newPrice;



    }

    function setPrice(uint _itemId, uint _newPrice) public itemExists(_itemId) notDelisted(_itemId){

        require(_newPrice >0 ,"Must have positive price");
        

        items[_itemId].lastPrice = _newPrice;

    }

    /**
    @dev - this function delists the item from the marketplace by setting the seller to the 0 address
           and also transfers the NFT from the marketplace to the owner (seller on the item struct)
     */

    function delistItem(uint _itemId) public itemExists(_itemId) notDelisted(_itemId) {

        require(msg.sender == items[_itemId].seller, "Not the owner of NFT");

        IERC721(items[_itemId].tokenAddress).safeTransferFrom(address(this),msg.sender,items[_itemId].tokenId);

        items[_itemId].seller=payable(address(0));
    }

    function transferFee() public {

        require(msg.sender==owner,"Only owner can transfer fee");

        payable(owner).transfer(address(this).balance);
    }

    function getOwner(uint _itemId) public view itemExists(_itemId) notDelisted(_itemId) returns(address)  {

        return items[_itemId].seller;
    }

    function itemsOwnedBy (address seller) public view returns(Item[] memory) {

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

    
    function ownerOfItem(uint _itemId) public view itemExists(_itemId) notDelisted(_itemId) returns(address){

        return items[_itemId].seller;
    }

}