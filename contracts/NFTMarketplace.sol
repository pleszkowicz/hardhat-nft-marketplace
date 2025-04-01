// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.28;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NFTMarketplace is ERC721URIStorage {

    address payable owner;
    uint256 private _tokenId;
    uint256 listingPrice = 0.025 ether;

    mapping (uint256 => ListedNFT) public idToListedNFT;

    event NFTCreated(uint256 tokenId, address owner, uint256 price, string tokenURI);

    struct ListedNFT {
        uint256 tokenId;
        address owner;
        uint256 price;
    }

    constructor() ERC721('NFTMarketplace', 'NFTM') {
        owner = payable(msg.sender);
    }

    function createNFT(string memory tokenURI, uint256 price) public payable returns (uint256) {
        require(price > 0, "Price must be at least 0.01 ether");
        require(msg.value == listingPrice, "Listing price must be equal to the value sent");

        payable(owner).transfer(msg.value);

        _tokenId++;
        _mint(msg.sender, _tokenId);

        _setTokenURI(_tokenId, tokenURI);

        idToListedNFT[_tokenId] = ListedNFT({
            tokenId: _tokenId,
            owner: msg.sender,
            price: price
        });
        

        emit NFTCreated(_tokenId, msg.sender, price, tokenURI);

        return _tokenId;
    }

    function getAllNFTs() public view returns (ListedNFT[] memory) {
        uint nftCount = _tokenId;
        ListedNFT[] memory nfts = new ListedNFT[](nftCount);

        for (uint i = 1; i <= nftCount; i++) {
            nfts[i - 1] = idToListedNFT[i];
        }
        
        return nfts;
    }

    function getNFTsByOwner(address _owner) public view returns (ListedNFT[] memory) {
        uint totalNFTCount = _tokenId;
        uint ownerNFTCount = 0;
        uint currentIndex = 0;

        for (uint i = 1; i <= totalNFTCount; i++) {
            if (idToListedNFT[i].owner == _owner) {
                ownerNFTCount++;
            }
        }

        ListedNFT[] memory nfts = new ListedNFT[](ownerNFTCount);
        for (uint i = 1; i <= totalNFTCount; i++) {
            if (idToListedNFT[i].owner == _owner) {
                nfts[currentIndex] = idToListedNFT[i];
                currentIndex++;
            }
        }

        return nfts;
    }

    function executeSale(uint256 tokenId) public payable {
        ListedNFT memory nft = idToListedNFT[tokenId];
        require(msg.value == nft.price, "Price must be equal to the value sent");

        address seller = nft.owner;
        address buyer = msg.sender;

        _transfer(seller, buyer, tokenId);

        delete idToListedNFT[tokenId];

        payable(seller).transfer(msg.value);
    }
}