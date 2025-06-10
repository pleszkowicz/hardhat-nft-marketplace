# 🧾 NFT Marketplace Smart Contract

This project demonstrates a fully functional **NFT Marketplace smart contract**, built with [Hardhat](https://hardhat.org/) and [OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts).
It includes NFT minting, listing, buying, price updates, and safe ETH transfers — ready for frontend integration and local testing.

---

## ✨ Features

- ✅ Mint NFTs with metadata (tokenURI)
- 💰 List NFTs for sale with custom pricing
- 🛒 Buy listed NFTs securely (requires owner approval)
- 🔐 Update listing prices (owner-only)
- 📦 Retrieve NFTs by ID, owner, or all listings
- ⚡ Safe ETH transfers using `Address.sendValue` (OpenZeppelin)
- 🧪 Ready for local testing and frontend integration

---

## 🛠 Stack

- Solidity `^0.8.28`
- [Hardhat](https://hardhat.org/)
- [OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts)
- TypeScript + Prettier
- Hardhat Toolbox, Tracer

---

## 🚀 Getting Started

### Environment variables

```bash
cp .env.example .env
```

Update `.env` by obtaining required API keys as instructed in the file.

### Install dependencies

```shell
pnpm install

npx hardhat compile
npx hardhat help
npx hardhat test
```

To view gas usage:

```bash
REPORT_GAS=true npx hardhat test
```

### Run local node

```shell
npx hardhat node
```

### Deploy smart contract

```shell
npx hardhat ignition deploy ./ignition/modules/NftMarketplace.ts --network localhost
```

or

```shell
npx hardhat ignition deploy ./ignition/modules/NftMarketplace.ts --network sepolia
```

#### Deployment output example

```plaintext
Deployed Addresses

NftMarketplace#NftMarketplace - 0xYourContractAddress
```

Optional: add `--reset` param to redeploy everything without clearing the deployment state manually.

## 🧩 After Deployment

Make sure you integrate with dApp — copy above `0xYourContractAddress` and paste it as environment variable in the [web3-wallet-connect](https://github.com/pleszkowicz/web3-wallet-connect) project.

Make sure to update your environment variables or configuration files with the deployed contract address to properly integrate.

## 🙌 Contributing

Contributions are welcome! Feel free to fork this repository and submit pull requests to improve the project.
