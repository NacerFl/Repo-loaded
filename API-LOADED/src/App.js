import { useEffect } from 'react';
//onst fs = require('fs');

import {useState} from 'react';

import { ethers } from 'ethers';

import './App.css';
import contract from './contract/NODERewardManager.json';
const contractAddress = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0";
//const abi = contract.abi;

const abi = contract.abi;




function App() {
  const [currentAccount, setCurrentAccount] = useState(null);


  const checkWalletIsConnected = async () => {
    const { ethereum } = window;

    if (!ethereum) {
      console.log("Make sure u haze Metamask installed");
      return;
    } else {
      console.log("Wallet exists!")
    }

    const accounts = await ethereum.request({ method: 'eth_accounts' });

    if (accounts.length !== 0) {
      const account = accounts[0];
      console.log("Found an authorize account: ", account);
      setCurrentAccount(account);
    } else {
      console.log("no authorized");

    }
  }

  const connectWalletHandler = async() => {
    const { ethereum } = window;
    if (!ethereum) {
      alert("Please install Metamask !");
    } 
    try {
      const accounts = await ethereum.request({ method: 'eth_requestAccounts' });
      console.log("Found an account! Address", accounts[0]);
      console.log("tetst");
      setCurrentAccount(accounts[0]);
    } catch (err) {
      console.log(err)
    }
  }

  const getNodeTypeAll = async () => { 

    try{
      const {ethereum} = window;

      if(ethereum){


        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();
        
        
        const Contract = new ethers.Contract(contractAddress,abi,signer)

        let mintage = await Contract.getNodeTypeAll("Tier 1");

        await mintage.wait(); 
      }else{
        console.log("error in METAMASK");
      }
    }catch(error){
      console.log(error);
    }

  }

  const createNodeFree = async () => { 

    try{
      const {ethereum} = window;

      if(ethereum){


        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();
        
        
        const Contract = new ethers.Contract(contractAddress,abi,signer)

        let mintage = await Contract.createNodeFree("Tier 1", 1);

        await mintage.wait(); 
      }else{
        console.log("error in METAMASK");
      }
    }catch(error){
      console.log(error);
    }

  }


  const getTotalCreatedNodes = async () => { 

    try{
      const {ethereum} = window;

      if(ethereum){


        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();
        
        
        const Contract = new ethers.Contract(contractAddress,abi,signer)

        let mintage = await Contract.getTotalCreatedNodes();

        await mintage.wait(); 
      }else{
        console.log("error in METAMASK");
      }
    }catch(error){
      console.log(error);
    }

  }

  const cashoutAll = async () => { 

    try{
      const {ethereum} = window;

      if(ethereum){


        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();
        
        
        const Contract = new ethers.Contract(contractAddress,abi,signer)

        let mintage = await Contract.cashoutAll();

        await mintage.wait(); 
      }else{
        console.log("error in METAMASK");
      }
    }catch(error){
      console.log(error);
    }

  }
  
  const calculateAllClaimableRewards = async () => { 

    try{
      const {ethereum} = window;

      if(ethereum){


        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();
        
        
        const Contract = new ethers.Contract(contractAddress,abi,signer)

        let mintage = await Contract.calculateAllClaimableRewards(signer);;

        await mintage.wait(); 
      }else{
        console.log("error in METAMASK");
      }
    }catch(error){
      console.log(error);
    }

  }
  
  const getBalance = async () => { 

    try{
      const {ethereum} = window;

      if(ethereum){


        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();
        
        
        const Contract = new ethers.Contract(contractAddress,abi,signer)

        let mintage = await Contract.balanceOf(signer);;

        await mintage.wait(); 
      }else{
        console.log("error in METAMASK");
      }
    }catch(error){
      console.log(error);
    }

  }


  const connectWalletButton = () => {
    return (
      <button onClick={connectWalletHandler} className='cta-button connect-wallet-button'>
        Connect Wallet
      </button>
    )
  }

  const getNodeType = () => {
    return (
      <button onClick={getNodeTypeAll} className='cta-button mint-nft-button'>
        getNodeTypeAll
      </button>
    )
  }

  const getAllNode = () => {
    return (
      <button onClick={getTotalCreatedNodes} className='cta-button mint-nft-button'>
        get total node
      </button>
    )
  }

  const createFreeNode = () => {
    return (
      <button onClick={createNodeFree} className='cta-button mint-nft-button'>
        createFreeNode
      </button>
    )
  }


  const calculReward = () => {
    return (
      <button onClick={calculateAllClaimableRewards} className='cta-button mint-nft-button'>
        calculateAllClaimableRewards
      </button>
    )
  }

  const getLDNBalance = () => {
    return (
      <button onClick={getBalance} className='cta-button mint-nft-button'>
        getLDNBalance
      </button>
    )
  }


  const cashout = () => {
    return (
      <button onClick={cashoutAll} className='cta-button mint-nft-button'>
        cashoutALL
      </button>
    )
  }


  useEffect(() => {
    checkWalletIsConnected();
  }, [])

  return (
    <div className='main-app'>
      <h1>Liste Boutton DAPP</h1>
      <div>
      {currentAccount ? getNodeType() : connectWalletButton()}
      </div>
      <div>
      {currentAccount ? createFreeNode() : connectWalletButton()}
      </div>
      <div>
      {currentAccount ? getAllNode() : connectWalletButton()}
      </div>
      <div>
      {currentAccount ? calculReward() : connectWalletButton()}
      </div>
      <div>
      {currentAccount ? getLDNBalance() : connectWalletButton()}
      </div>
      <div>
      {currentAccount ? cashout() : connectWalletButton()}
      </div>

    </div>
  )
}

export default App;