import { useEffect } from 'react';
//onst fs = require('fs');

import {useState} from 'react';
import './App.css';
import contract from './contract/NODERewardManager.json';
const contractAddress = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0";
//const abi = contract.abi;

const abi = contract.abi;




function App() {

  const [currentAccount, setCurrentAccount] = useState(null);

  const checkWalletIsConnected = () => { }

  const connectWalletHandler = async () => { 

    const { ethereum } = window;

    if (!ethereum) {
      alert("error metamask");
    }

    try { 
      const accounts = await ethereum.request({ method:'eth_requestAccounts'});
      console.log("trouver", accounts[0]);
      setCurrentAccount(accounts[0]);
    }catch(error){
      console.log(error);
    }


  }
  
 
  const mintNftHandler  = () => { }
  const connectWalletButton  = () => { }
/*
  const mintNftHandler = async () => {
    try{
    const { ethereum } = window;

    if (ethereum){

      const that = this;
	// We set up values with our config file depending on production or not
	
	// => Web3 from a HTTP provider
	that.web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:8000"));

  const contract = new that.web3.eth.Contract(abi,contractAddress);

  const testNode = await contract.methods.getTotalCreatedNodes();

  await testNode.wait();

  console.log("ca marche");


    }
  }catch(error){
    console.log(error);
  }
  }
*/
  const mintNftButton = () => {
    return (
      <button onClick={mintNftHandler} className='cta-button mint-nft-button'>
        Mint NFT
      </button>
      
    )
  }

  useEffect(() => {
    checkWalletIsConnected();
  }, [])

  return (
    <div className='main-app'>
      <h1>Scrappy Squirrels Tutorial</h1>
      <div>
        {connectWalletButton()}
      </div>
    </div>
  )
}

export default App;