// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  const CronosToken = await hre.ethers.getContractFactory("CronosToken");
  const cronosToken = await CronosToken.deploy("Cronos Token", "LDN", "1000000000000000000000000");

  await cronosToken.deployed();

  console.log("CronosToken deployed to:", cronosToken.address);

  //const owner = "0x25Ffb1c9C7e6552853EDF6c8316E07C863a6aCE8"
  const [owner, addr1, addr2, addr3, addr4, addr5] = await ethers.getSigners();

  const IterableNode = await hre.ethers.getContractFactory("IterableNodeTypeMapping");
  const iterableNode = await IterableNode.deploy();


  await iterableNode.deployed();
  console.log("iterableNode deployed to:", iterableNode.address);


  const NODERewardManager = await hre.ethers.getContractFactory("NODERewardManager", {
    libraries: {
      IterableNodeTypeMapping: iterableNode.address,
    },
  });

  

  const nodereward = await NODERewardManager.deploy(
    cronosToken.address,
    [addr1.address],
    [100],
    [addr2.address, addr3.address, addr4.address],
    [20,55,25,20],
    120
    );


    await nodereward.deployed();


    console.log("NODERewardManager deployed to:", nodereward.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });