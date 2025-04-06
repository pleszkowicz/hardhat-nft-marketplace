import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const NftMarketplaceModule = buildModule("NftMarketplace", (m) => {
  const nftMarketplace = m.contract("NftMarketplace",);

  return { nftMarketplace };
});

export default NftMarketplaceModule;
