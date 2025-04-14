// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import 'hardhat/console.sol';
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';
import '@openzeppelin/contracts/utils/Address.sol';

contract NftMarketplace is ERC721URIStorage {
    using Address for address payable;

    address payable owner;
    uint256 private _tokenId;
    uint256 public listingPrice = 0.001 ether;

    mapping(uint256 => ListedNft) public idToListedNft;

    event NftCreated(uint256 tokenId, address owner, uint256 price, string tokenURI);
    event NftSold(uint256 tokenId, address seller, address buyer, uint256 price);
    event NftListingChanged(uint256 tokenId, uint256 price);

    struct ListedNft {
        uint256 tokenId;
        address owner;
        uint256 price;
    }

    constructor() ERC721('Nifty Pit Marketplace', 'PIT') {
        owner = payable(msg.sender);
    }

    function createNft(string memory tokenURI, uint256 price) public payable returns (uint256) {
        require(price > 0, 'Price must be at least 0.01 ether');
        require(msg.value == listingPrice, 'Listing price must be equal to the value sent');

        payable(owner).transfer(msg.value);

        _tokenId++;
        _mint(msg.sender, _tokenId);

        _setTokenURI(_tokenId, tokenURI);

        idToListedNft[_tokenId] = ListedNft({tokenId: _tokenId, owner: msg.sender, price: price});

        emit NftCreated(_tokenId, msg.sender, price, tokenURI);

        return _tokenId;
    }

    function getAllNfts() public view returns (ListedNft[] memory) {
        uint nftCount = _tokenId;
        ListedNft[] memory nfts = new ListedNft[](nftCount);

        for (uint i = 1; i <= nftCount; i++) {
            nfts[i - 1] = idToListedNft[i];
        }

        return nfts;
    }

    function getNftById(uint256 tokenId) public view returns (ListedNft memory) {
        require(idToListedNft[tokenId].tokenId != 0, 'NFT not listed or does not exist');
        return idToListedNft[tokenId];
    }

    function getNftsByOwner(address _owner) public view returns (ListedNft[] memory) {
        uint ownerNftCount = 0;
        uint currentIndex = 0;

        for (uint i = 1; i <= _tokenId; i++) {
            if (ownerOf(i) == _owner) {
                ownerNftCount++;
            }
        }

        ListedNft[] memory nfts = new ListedNft[](ownerNftCount);
        for (uint i = 1; i <= _tokenId; i++) {
            if (ownerOf(i) == _owner) {
                nfts[currentIndex] = idToListedNft[i];
                currentIndex++;
            }
        }

        return nfts;
    }

    function updatePrice(uint256 tokenId, uint256 newPrice) public {
        ListedNft storage nft = idToListedNft[tokenId];
        require(nft.owner == msg.sender, 'Only the owner can update the price');
        require(newPrice > 0, 'Price must be at least 0.01 ether');

        nft.price = newPrice;

        emit NftListingChanged(tokenId, nft.price);
    }

    function executeSale(uint256 tokenId) public payable {
        ListedNft storage nft = idToListedNft[tokenId];
        require(msg.sender != nft.owner, 'You cannot buy your own Nft');
        require(msg.value == nft.price, 'Price must be equal to the value sent');
        require(_isApprovedOrOwner(address(this), tokenId), 'Contract not approved to transfer this token');

        address seller = nft.owner;
        address buyer = msg.sender;

        _transfer(seller, buyer, tokenId);

        nft.owner = buyer;

        emit NftSold(tokenId, seller, buyer, nft.price);
        emit NftListingChanged(tokenId, nft.price);

        payable(seller).sendValue(nft.price);
        console.log('Funds successfully transferred to seller.');
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
