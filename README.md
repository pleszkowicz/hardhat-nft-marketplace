# 🧾 NFT Marketplace

This project demonstrates a fully functional **NFT Marketplace smart contract**, built with [Hardhat](https://hardhat.org/) and OpenZeppelin ERC-721.
It includes minting, listing, buying NFTs, and price updates.

---

## ✨ Features

- ✅ Mint NFTs with metadata (tokenURI)
- 💰 List NFTs for sale with custom pricing
- 🛒 Buy listed NFTs securely (requires owner approval)
- 🔐 Owner-only listing price management
- 📦 Retrieve NFTs by ID, owner, or all listings
- ⚠️ Safe ETH transfers using `Address.sendValue` (OpenZeppelin)
- 🧪 Ready for local testing and frontend integration

---

## 🛠 Stack

- Solidity `^0.8.28`
- [Hardhat](https://hardhat.org/)
- [OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts)
- TypeScript + Prettier
- Hardhat Toolbox, Tracer, dotenv

---

## 🚀 Getting Started

### Install dependencies

```shell
npm install

npx hardhat compile 

npx hardhat help

npx hardhat test

REPORT_GAS=true npx hardhat test
```

### Run local node

```shell
npx hardhat node
```

### Deploy Nft smart contract

```shell
npx hardhat ignition deploy ./ignition/modules/NftMarketplace.ts --network localhost
```

Wait for successful deployment, example response:

```plaintext
Deployed Addresses

NftMarketplace#NftMarketplace - 0x***abc
```

Optionally, you can add `--reset` param to redeploy everything without clearing the deployment state manually.

**Done!** Now, you can use the above `0x***abc` smart-contract address to interact with the deployed NFT Marketplace. This address can be used in the following ways:

1. **Web3 Integration**: Use the contract address in your frontend application to interact with the NFT Marketplace using libraries like `ethers.js` or `web3.js`.
2. **Smart Contract Interaction**: Reference this address in other smart contracts to call functions or interact with the deployed Nft Marketplace.
3. **Testing**: Use the address in your test scripts to verify the functionality of the deployed contract.

Make sure to update your environment variables or configuration files with the deployed contract address to properly integrate.
