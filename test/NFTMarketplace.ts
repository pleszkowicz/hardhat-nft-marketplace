import { expect } from "chai";
import { ethers } from "hardhat";

describe("NFTMarketplace", function () {
  async function deployNFTMarketplaceFixture() {
    const [owner, seller, buyer] = await ethers.getSigners();

    const NFTMarketplace = await ethers.getContractFactory("NFTMarketplace");
    const nftMarketplace = await NFTMarketplace.deploy();

    return { nftMarketplace, owner, seller, buyer };
  }

  describe("Deployment", function () {
    it("Should deploy the contract successfully", async function () {
      const { nftMarketplace } = await deployNFTMarketplaceFixture();
      expect(await nftMarketplace.getAddress()).to.be.properAddress;
    });
  });

  describe("NFT Creation", function () {
    it("Should create an NFT successfully", async function () {
      const { nftMarketplace, seller } = await deployNFTMarketplaceFixture();
      const tokenURI = "https://example.com/nft";
      const price = ethers.parseEther("0.1");
      const listingPrice = await nftMarketplace.listingPrice(); // Fetch dynamically

      await nftMarketplace.connect(seller).createNFT(tokenURI, price, { value: listingPrice });

      const nft = await nftMarketplace.idToListedNFT(1);
      expect(nft.tokenId).to.equal(1);
      expect(nft.owner).to.equal(seller.address);
      expect(nft.price).to.equal(price);
    });

    it("Should fail if listing price is incorrect", async function () {
      const { nftMarketplace, seller } = await deployNFTMarketplaceFixture();
      const tokenURI = "https://example.com/nft";
      const price = ethers.parseEther("0.1");

      await expect(
        nftMarketplace.connect(seller).createNFT(tokenURI, price, { value: ethers.parseEther("0.01") })
      ).to.be.revertedWith("Listing price must be equal to the value sent");
    });
  });

  describe("Retrieve NFTs", function () {
    it("Should retrieve all NFTs", async function () {
      const { nftMarketplace, seller } = await deployNFTMarketplaceFixture();
      const tokenURI = "https://example.com/nft";
      const price = ethers.parseEther("0.1");
      const listingPrice = await nftMarketplace.listingPrice();

      await nftMarketplace.connect(seller).createNFT(tokenURI, price, { value: listingPrice });

      const nfts = await nftMarketplace.getAllNFTs();
      expect(nfts.length).to.equal(1);
      expect(nfts[0].tokenId).to.equal(1);
    });

    it("Should retrieve NFTs by owner", async function () {
      const { nftMarketplace, seller } = await deployNFTMarketplaceFixture();
      const tokenURI = "https://example.com/nft";
      const price = ethers.parseEther("0.1");
      const listingPrice = await nftMarketplace.listingPrice();

      await nftMarketplace.connect(seller).createNFT(tokenURI, price, { value: listingPrice });

      const nfts = await nftMarketplace.getNFTsByOwner(seller.address);
      expect(nfts.length).to.equal(1);
      expect(nfts[0].owner).to.equal(seller.address);
    });
  });

  describe("Execute Sale", function () {
    it("Should execute a sale successfully", async function () {
      const { nftMarketplace, seller, buyer } = await deployNFTMarketplaceFixture();
      const tokenURI = "https://example.com/nft";
      const price = ethers.parseEther("0.1");
      const listingPrice = await nftMarketplace.listingPrice();

      console.log("Listing price:", listingPrice.toString());

      await nftMarketplace.connect(seller).createNFT(tokenURI, price, { value: listingPrice });
      await nftMarketplace.connect(seller).setForSale(1, true);

      await nftMarketplace.connect(seller).approve(nftMarketplace.getAddress(), 1);
      await nftMarketplace.connect(buyer).executeSale(1, { value: ethers.parseEther("0.1") });

      const nfts = await nftMarketplace.getNFTsByOwner(buyer.address);
      expect(nfts[0].tokenId).to.equal(1);
      expect(nfts[0].owner).to.equal(buyer.address);
    });

    it("Should fail if price is incorrect", async function () {
      const { nftMarketplace, seller, buyer } = await deployNFTMarketplaceFixture();
      const tokenURI = "https://example.com/nft";
      const price = ethers.parseEther("0.1");
      const listingPrice = await nftMarketplace.listingPrice();

      await nftMarketplace.connect(seller).createNFT(tokenURI, price, { value: listingPrice });

      await nftMarketplace.connect(seller).setForSale(1, true);
      await nftMarketplace.connect(seller).approve(nftMarketplace.getAddress(), 1);

      await expect(
        nftMarketplace.connect(buyer).executeSale(1, { value: ethers.parseEther("0.05") })
      ).to.be.revertedWith("Price must be equal to the value sent");
    });

    it("Should fail if NFT is not for sale", async function () {
      const { nftMarketplace, seller, buyer } = await deployNFTMarketplaceFixture();
      const tokenURI = "https://example.com/nft";
      const price = ethers.parseEther("0.1");
      const listingPrice = await nftMarketplace.listingPrice();

      await nftMarketplace.connect(seller).createNFT(tokenURI, price, { value: listingPrice });

      await expect(
        nftMarketplace.connect(buyer).executeSale(1, { value: price })
      ).to.be.revertedWith("NFT is not for sale");
    });
  });
});
