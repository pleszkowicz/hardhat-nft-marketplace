# NFT Sample Hardhat Project

This project demonstrates a basic NFT Marketplace smart contract use case:

## CLI

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
```

### Run local node

```shell
npx hardhat node
```

### Deploy NFT smart contract

```shell
npx hardhat ignition deploy ./ignition/modules/NFTMarketplace.ts --network localhost
```

Wait for successful deplyment:

```plaintext
Deployed Addresses

NFTMarketplace#NFTMarketplace - 0x5FbDB2315678afecb367f032d93F642f64180aa3
```

Done! Now, you can use above `0x***` smart-contract address and integrate it with web3 app or another smart-contract.
