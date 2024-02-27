import { ethers } from "hardhat";
require("dotenv").config(); // 加载环境变量

async function main() {
  const tokenContract = "0x3e90F98cFc251F8e93fCc01EFD94742B7462805B";
  const nftContract = "0xa4Ec768ca47160Df1c4a645639A6b09cCF296064";

  console.log("Deploying MealManager contract...");
  const MealManager = await ethers.getContractFactory("MealManager");
  const mealManager = await MealManager.deploy(tokenContract, nftContract);

  await mealManager.waitForDeployment();
  console.log("MealManager contract deployed to:", mealManager.target);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
