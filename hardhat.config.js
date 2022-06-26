require("@nomiclabs/hardhat-waffle");
require('hardhat-abi-exporter');
require('dotenv').config();
// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

const accounts = {
  mnemonic: process.env.PRIVATE_KEYFTM,
};

const getHDWallet = () => {
  const { MNEMONIC, PRIVATE_KEY } = process.env;
  //const MNEMONIC = process.env.MNEMONIC;
  //const PRIVATE_KEY = process.env.PRIVATE_KEY
  //console.log("teeest",MNEMONIC);
  if (MNEMONIC && MNEMONIC !== "") {
    return {
      mnemonic: MNEMONIC,
    }
  }
  if (PRIVATE_KEY && PRIVATE_KEY !== "") {
    return [PRIVATE_KEY]
  }
  throw Error("Private Key Not Set! Please set up .env");
}

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
 module.exports = {
  solidity: {
    compilers: [

      {
        version: "0.6.6"
      },
      {
        version: "0.8.9"

      }
    ]
  },
  networks: {
    hardhat: {
      allowUnlimitedContractSize: true
    },
    cronos: {
      url: "HTTP://127.0.0.1:8000",
      accounts: getHDWallet(),
      allowUnlimitedContractSize: true,
      gas: 6721975,
      gasPrice: 20000000
    },fantomtest: {
      url: "https://rpc.testnet.fantom.network",
      accounts,
      chainId: 10012,
      live: false,
      saveDeployments: true,
      gasMultiplier: 2
    },
  },
  abiExporter: [
    {
      path: './abi',
      pretty: true,
    },
    {
      path: './abi',
      pretty: false,
    },
  ]
};