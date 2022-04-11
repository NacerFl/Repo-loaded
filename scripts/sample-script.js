// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  // const Greeter = await hre.ethers.getContractFactory("Greeter");
  // const greeter = await Greeter.deploy("Hello, Hardhat!");

  const IterableNode = await hre.ethers.getContractFactory("IterableNodeTypeMapping");
  const iterableNode = await IterableNode.deploy();

  // console.log("test", iterableNode);

  const Token = await hre.ethers.getContractFactory("CronosToken");
  const token = await Token.deploy("Loaded Nodes Token", "LDN", "1000000000000000000000000");

  const NODERewardManager = await hre.ethers.getContractFactory("Greeter");
  const nodereward = await NODERewardManager.deploy(token.address);
 
  await iterableNode.deployed();
  await token.deployed();
  await nodereward.deployed();

  console.log("iterableNode deployed to:", iterableNode.address);
  console.log("token deployed to:", token.address);
  console.log("nodereward  deployed to:",  nodereward.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
