import { ethers } from "hardhat";
require("dotenv").config(); // 加载环境变量

async function main() {
  let owner = await ethers.provider.getSigner(0);

  const MealToken = await ethers.getContractFactory("MealToken");
  const mealToken = await MealToken.deploy(owner.address, "LTLL", "LTLL");
  const MealNFT = await ethers.getContractFactory("MealNFT");
  const mealNFT = await MealNFT.deploy(owner.address, "LTLL", "LTLL", owner.address, 200n);

  console.log("Deploying MealManager contract...");
  const MealManager = await ethers.getContractFactory("MealManager");
  const mealManager = await MealManager.deploy(mealNFT.target, mealToken.target);
  await mealManager.waitForDeployment();
  console.log("MealManager contract deployed to:", mealManager.target);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
