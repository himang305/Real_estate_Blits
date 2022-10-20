// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
const { expect } = require("chai");
const { ethers, BigNumber } = require("hardhat");

async function main() {
  
  const token = await ethers.getContractFactory("BlitsToken");
  factoryContract = await token.deploy("0xf922e3223567AeB66e6986cb09068B1B879B6ccc");
  await factoryContract.deployed();

  console.log(factoryContract.address, " Token address");

  const tokenlock = await ethers.getContractFactory("TimeLock");
  tokenlockfactoryContract = await tokenlock.deploy(factoryContract.address);
  await tokenlockfactoryContract.deployed();

  console.log(tokenlockfactoryContract.address, " Lock address");


  const ico = await ethers.getContractFactory("ICO");
  icofactoryContract = await ico.deploy(factoryContract.address,tokenlockfactoryContract.address,"0xf922e3223567AeB66e6986cb09068B1B879B6ccc");
  await icofactoryContract.deployed();

  console.log(icofactoryContract.address, " ICO address");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
