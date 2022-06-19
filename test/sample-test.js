const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Greeter", function () {
  it("Should return contract adress", async function () {
  // const Greeter = await ethers.getContractFactory("Greeter");
  // const greeter = await Greeter.deploy("Hello, world!");
  // await greeter.deployed();
  //deployment
  const [owner, addr1, addr2, addr3, addr4, addr5] = await ethers.getSigners();

  const IterableNode = await hre.ethers.getContractFactory("IterableNodeTypeMapping");
  const iterableNode = await IterableNode.deploy();

  const Token = await hre.ethers.getContractFactory("CronosToken");
  const token = await Token.deploy("Loaded Nodes Token", "LDN", "1000000000000000000000000");

  const NODERewardManager = await hre.ethers.getContractFactory("NODERewardManager", {
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

    //test
 
  await iterableNode.deployed();
  await token.deployed();
  await nodereward.deployed();

  console.log("iterableNode deployed to:", iterableNode.address);
  console.log("token deployed to:", token.address);
  console.log("nodereward deployed to:",  nodereward.address);

  //token test
  expect(await token.totalSupply()).to.equal("1000000000000000000000000");
  
  //Check la balance du owner = total supply
  const ownerBalance = await token.balanceOf(owner.address);
  expect(await token.totalSupply()).to.equal(ownerBalance);
  
  const res1 = await token.totalSupply();

    // transfer owner to addr1 et check apres
  await token.transfer(addr1.address, 50000000);
  expect(await token.balanceOf(addr1.address)).to.equal(50000000);
    
  // transfer owner to addr3 ( distribution pool test) et check apres
  await token.transfer(addr3.address, 50000000000);
  expect(await token.balanceOf(addr3.address)).to.equal(50000000000);

  const res2 = await nodereward.getTotalCreatedNodes();
  //update bool creation de node free
  await nodereward.updateOpenCreateFree(true);
    // creation nouveau ttype de node (tier 1) a check 0.4 reward 
  await nodereward.addNodeType(
    "Tier 1",
    [40,3600,1,0,50,0,0,0,0,0]
  );
    //check node bien creer
  const res3 = await nodereward.getNodeTypeAll("Tier 1");
    //creation d'un node (free) avec addr5
  await nodereward.connect(addr5).createNodeFree("Tier 1", 1);
  //check total node created
  const res4 = await nodereward.getTotalCreatedNodes();

  const Day = 24 * 60 * 60;
  const Hour = 60 * 60;
    //avancer dans le temp d'un jour
  await ethers.provider.send('evm_increaseTime', [Day]);
  await ethers.provider.send('evm_mine');

  const res5 = await nodereward.calculateAllClaimableRewards(addr5.address);

  // test getdistributionPool()
  const res6 = await nodereward.getdistributionPool();

  const res7 = await token.balanceOf(addr3.address)

  //increase allowance
   const res8 = await token.connect(addr3).increaseAllowance(nodereward.address, "99999999999");

  //cashcout reward addr5
  await nodereward.connect(addr5).cashoutAll();

  const res9 = await nodereward.calculateAllClaimableRewards(addr5.address);

  console.log('Adress ::', owner.address, '\n',addr1.address, '\n',addr2.address,'\n', addr3.address,nodereward.address, '\n',addr4.address,'\n', addr5.address)
  console.log("token total supply:", res1);
  console.log("token owner balance:", owner.address,ownerBalance);
  console.log("addr1 balance:", addr1.address, await token.balanceOf(addr1.address));
  console.log("addr5 balance avant claim:", await token.balanceOf(addr5.address));
  console.log("total nodes 1:", res2);
  console.log("node type:", res3);
  console.log("total nodes 2:", res4);
  console.log("rewards:", res5);
  console.log("distributionPool :", res6);
  console.log("claimable reward after cashout all call :", res9);
  console.log("addr5 balance apres claim:", await token.balanceOf(addr5.address));
  
  

  // // wait until the transaction is mined
  // await setGreetingTx.wait();
  // expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
});
