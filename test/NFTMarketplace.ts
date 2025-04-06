import { expect } from "chai";
import { ethers } from "hardhat";

describe("NftMarketplace", function () {
  async function deployNftMarketplaceFixture() {
    const [owner, seller, buyer] = await ethers.getSigners();

    const NftMarketplace = await ethers.getContractFactory("NftMarketplace");
    const nftMarketplace = await NftMarketplace.deploy();

    return { nftMarketplace, owner, seller, buyer };
  }

  describe("Deployment", function () {
    it("Should deploy the contract successfully", async function () {
      const { nftMarketplace } = await deployNftMarketplaceFixture();
      expect(await nftMarketplace.getAddress()).to.be.properAddress;
    });
  });

  describe("Nft Creation", function () {
    it("Should create an Nft successfully", async function () {
      const { nftMarketplace, seller } = await deployNftMarketplaceFixture();
      const tokenURI = "https://example.com/nft";
      const price = ethers.parseEther("0.1");
      const listingPrice = await nftMarketplace.listingPrice(); // Fetch dynamically

      await nftMarketplace.connect(seller).createNft(tokenURI, price, { value: listingPrice });

      const nft = await nftMarketplace.idToListedNft(1);
      expect(nft.tokenId).to.equal(1);
      expect(nft.owner).to.equal(seller.address);
      expect(nft.price).to.equal(price);
    });

    it("Should fail if listing price is incorrect", async function () {
      const { nftMarketplace, seller } = await deployNftMarketplaceFixture();
      const tokenURI = "https://example.com/nft";
      const price = ethers.parseEther("0.1");

      await expect(
        nftMarketplace.connect(seller).createNft(tokenURI, price, { value: ethers.parseEther("0.01") })
      ).to.be.revertedWith("Listing price must be equal to the value sent");
    });
  });

  describe("Retrieve Nfts", function () {
    it("Should retrieve all Nfts", async function () {
      const { nftMarketplace, seller } = await deployNftMarketplaceFixture();
      const tokenURI = "https://example.com/nft";
      const price = ethers.parseEther("0.1");
      const listingPrice = await nftMarketplace.listingPrice();

      await nftMarketplace.connect(seller).createNft(tokenURI, price, { value: listingPrice });

      const nfts = await nftMarketplace.getAllNfts();
      expect(nfts.length).to.equal(1);
      expect(nfts[0].tokenId).to.equal(1);
    });

    it("Should retrieve Nfts by owner", async function () {
      const { nftMarketplace, seller } = await deployNftMarketplaceFixture();
      const tokenURI = "https://example.com/nft";
      const price = ethers.parseEther("0.1");
      const listingPrice = await nftMarketplace.listingPrice();

      await nftMarketplace.connect(seller).createNft(tokenURI, price, { value: listingPrice });

      const nfts = await nftMarketplace.getNftsByOwner(seller.address);
      expect(nfts.length).to.equal(1);
      expect(nfts[0].owner).to.equal(seller.address);
    });
  });

  describe("Execute Sale", function () {
    it("Should execute a sale successfully", async function () {
      const { nftMarketplace, seller, buyer } = await deployNftMarketplaceFixture();
      const tokenURI = "https://example.com/nft";
      const price = ethers.parseEther("0.1");
      const listingPrice = await nftMarketplace.listingPrice();

      console.log("Listing price:", listingPrice.toString());

      await nftMarketplace.connect(seller).createNft(tokenURI, price, { value: listingPrice });
      await nftMarketplace.connect(seller).setForSale(1, true);

      await nftMarketplace.connect(seller).approve(nftMarketplace.getAddress(), 1);
      await nftMarketplace.connect(buyer).executeSale(1, { value: ethers.parseEther("0.1") });

      const nfts = await nftMarketplace.getNftsByOwner(buyer.address);
      expect(nfts[0].tokenId).to.equal(1);
      expect(nfts[0].owner).to.equal(buyer.address);
    });

    it("Should fail if price is incorrect", async function () {
      const { nftMarketplace, seller, buyer } = await deployNftMarketplaceFixture();
      const tokenURI = "https://example.com/nft";
      const price = ethers.parseEther("0.1");
      const listingPrice = await nftMarketplace.listingPrice();

      await nftMarketplace.connect(seller).createNft(tokenURI, price, { value: listingPrice });

      await nftMarketplace.connect(seller).setForSale(1, true);
      await nftMarketplace.connect(seller).approve(nftMarketplace.getAddress(), 1);

      await expect(
        nftMarketplace.connect(buyer).executeSale(1, { value: ethers.parseEther("0.05") })
      ).to.be.revertedWith("Price must be equal to the value sent");
    });

    it("Should fail if Nft is not for sale", async function () {
      const { nftMarketplace, seller, buyer } = await deployNftMarketplaceFixture();
      const tokenURI = "https://example.com/nft";
      const price = ethers.parseEther("0.1");
      const listingPrice = await nftMarketplace.listingPrice();

      await nftMarketplace.connect(seller).createNft(tokenURI, price, { value: listingPrice });

      await expect(
        nftMarketplace.connect(buyer).executeSale(1, { value: price })
      ).to.be.revertedWith("Nft is not for sale");
    });
  });
});
