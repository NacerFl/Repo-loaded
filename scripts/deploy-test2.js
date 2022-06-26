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

  // console.log("test", iterableNode);

  const Token = await hre.ethers.getContractFactory("TimerrToken");
  const token = await Token.deploy();

  await token.deployed();


  const [owner, addr1, addr2, addr3, addr4, addr5] = await ethers.getSigners();

  const IterableNode = await hre.ethers.getContractFactory("IterableNodeTypeMapping");
  const iterableNode = await IterableNode.deploy();


  await iterableNode.deployed();
  console.log("iterableNode deployed to:", iterableNode.address);


  const NODERewardManager = await hre.ethers.getContractFactory("LoadedNodeV2", {
    libraries: {
      IterableNodeTypeMapping: iterableNode.address,
    },
  });

  

  const nodereward = await NODERewardManager.deploy(
    token.address,
    [addr1.address],
    [100],
    [addr2.address, addr3.address, addr4.address],
    [20,55,25,20],
    120
    );


    await nodereward.deployed();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
