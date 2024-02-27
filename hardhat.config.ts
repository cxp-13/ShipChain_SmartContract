const PRIVATE_KEY = vars.get("PRIVATE_KEY");
const SEPOLIA_URL = vars.get("SEPOLIA_URL");


import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";


const config: HardhatUserConfig = {
  solidity: "0.8.24",
  networks: {
    sepolia: {
      url: SEPOLIA_URL || "",
      accounts: [PRIVATE_KEY || ""]
    },
  },
};

export default config;
