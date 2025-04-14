import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import * as dotenv from "dotenv";

require("hardhat-tracer");

dotenv.config();
console.log(process.env.SEPOLIA_RPC_URL);

const config: HardhatUserConfig = {
  solidity: "0.8.28",
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
  sourcify: {
    enabled: true
  },
  networks: {
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL || "",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
    },
    localhost: {
      url: "http://localhost:8545",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
    }
  },
};

export default config;
