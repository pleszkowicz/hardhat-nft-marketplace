// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

import 'hardhat/console.sol';
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';

contract NFTMarketplace is ERC721URIStorage {
    address payable owner;
    uint256 private _tokenId;
    uint256 public listingPrice = 0.025 ether;

    mapping(uint256 => ListedNFT) public idToListedNFT;

    event NFTCreated(uint256 tokenId, address owner, uint256 price, string tokenURI);
    event NFTSold(uint256 tokenId, address seller, address buyer, uint256 price);
    event NFTListingChanged(uint256 tokenId, bool isForSale, uint256 price);

    struct ListedNFT {
        uint256 tokenId;
        address owner;
        uint256 price;
        bool isForSale;
    }

    constructor() ERC721('NFTPitMarketplace', 'NFTPM') {
        owner = payable(msg.sender);
    }

    function createNFT(string memory tokenURI, uint256 price) public payable returns (uint256) {
        require(price > 0, 'Price must be at least 0.01 ether');
        require(msg.value == listingPrice, 'Listing price must be equal to the value sent');

        payable(owner).transfer(msg.value);

        _tokenId++;
        _mint(msg.sender, _tokenId);

        _setTokenURI(_tokenId, tokenURI);

        idToListedNFT[_tokenId] = ListedNFT({tokenId: _tokenId, owner: msg.sender, price: price, isForSale: false});

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
        uint ownerNFTCount = 0;
        uint currentIndex = 0;

        for (uint i = 1; i <= _tokenId; i++) {
            if (idToListedNFT[i].owner == _owner) {
                ownerNFTCount++;
            }
        }

        ListedNFT[] memory nfts = new ListedNFT[](ownerNFTCount);
        for (uint i = 1; i <= _tokenId; i++) {
            if (idToListedNFT[i].owner == _owner) {
                nfts[currentIndex] = idToListedNFT[i];
                currentIndex++;
            }
        }

        return nfts;
    }

    function setForSale(uint256 tokenId, bool _isForSale) public {
        ListedNFT storage nft = idToListedNFT[tokenId];
        require(nft.owner == msg.sender, 'Only the owner can set the NFT for sale');
        nft.isForSale = _isForSale;

        emit NFTListingChanged(tokenId, _isForSale, nft.price);
    }

    function updatePrice(uint256 tokenId, uint256 newPrice) public {
        ListedNFT storage nft = idToListedNFT[tokenId];
        require(nft.owner == msg.sender, 'Only the owner can update the price');
        require(newPrice > 0, 'Price must be at least 0.01 ether');

        nft.price = newPrice;

        emit NFTListingChanged(tokenId, nft.isForSale, nft.price);
    }

    function executeSale(uint256 tokenId) public payable {
        ListedNFT storage nft = idToListedNFT[tokenId];
        require(nft.isForSale, 'NFT is not for sale');
        require(msg.sender != nft.owner, 'You cannot buy your own NFT');
        require(msg.value == nft.price, 'Price must be equal to the value sent');
        require(_isApprovedOrOwner(address(this), tokenId), 'Contract not approved to transfer this token');

        address seller = nft.owner;
        address buyer = msg.sender;

        nft.owner = buyer;
        nft.isForSale = false;

        _transfer(seller, buyer, tokenId);

        emit NFTSold(tokenId, nft.owner, msg.sender, nft.price);
        emit NFTListingChanged(tokenId, nft.isForSale, nft.price);

        (bool success, ) = payable(seller).call{value: nft.price}('');
        require(success, 'Transfer failed');
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address tokenOwner = ownerOf(tokenId);
        return (spender == tokenOwner || isApprovedForAll(tokenOwner, spender) || getApproved(tokenId) == spender);
    }

    function updateListingPrice(uint _newPrice) public onlyOwner {
        listingPrice = _newPrice;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'Caller is not the owner');
        _;
    }
}
