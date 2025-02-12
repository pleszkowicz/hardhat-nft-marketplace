import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const NFTMarketplaceModule = buildModule("NFTMarketplace", (m) => {
  const nftMarketplace = m.contract("NFTMarketplace",);

  return { nftMarketplace };
});

export default NFTMarketplaceModule;
