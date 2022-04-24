/* Blockchain requirements */
const Web3 = require('web3')
const ini = require('ini');
const fs = require('fs');
const path = require('path');
const { parse } = require('path');

const file = fs.readFileSync('./config.ini', 'utf-8');
const config = ini.parse(file);




function APPLOAD(_abi_versioning, _address_versioning, _userAddress) {

	// Sets up web3
	this.web3 = null;
	this.config = config;


	// Config parsed as a class variable
}



/**
 * Initialize the APPETH class with needed variables
 */
 APPLOAD.prototype.init = function () {
	const that = this;
	// We set up values with our config file depending on production or not
	
	// => Web3 from a HTTP provider
	that.web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:8000"));
	// => MongoDB URI with username and password
	//url = 'mongodb://'+that.config.MONGO.ip+':'+that.config.MONGO.port+"/";
	//url = that.config.MONGO.database;

    var jsonFile = "./files/NodeRewardABI.js";
    var parsed= JSON.parse(fs.readFileSync(jsonFile));
    
	//console.log("teesst parseeed",parsed);


	// Connect the versioning contract with the ABI stored above, and the address which is supposed 
	// to always be the same
	that.contractVersioning = new this.web3.eth.Contract(parsed,that.config.contractaddress_nodeManage);
}


APPLOAD.prototype.onReady = function () {
	this.init();
}


APPLOAD.prototype.createNode = function () {

	
	return new Promise( async (resolve, reject) => {
	
		const that = this;

		try {

			var acount1 = "0xE008F902319bD079E8ce6b28b01C8c7dA2985d1e";
			var acount2 = "0x3AA56B5A0019D9867945FF456a64010D37ba06bB";
			var acount3 = "0x63e881DD7d36D50A7899A6a44c1B82c3D126B640";
			var acount4 = "0x6bA6ff472F6F10817e6735aaA906838cA583872a";

			const tokenContractAddr = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";

			var jsonFile = "./files/NodeRewardABI.js";
			//console.log("alooooooo",jsonFile);
			var abi1= JSON.parse(fs.readFileSync(jsonFile));
			//console.log("teesst parseeed",parsed);

			//var abi1 = parsed.abi;
		
			contractAddress = that.config.contractaddress_nodeManage;
			const contract = new that.web3.eth.Contract(abi1,contractAddress);

			

			const testNode = await contract.methods.addNodeType(tokenContractAddr,[acount1],[100],[acount2,acount3,acount4],[20,55,25,20],20);
	
			resolve(testNode);
		}catch(err) {
			console.error(err)
		}
	
	});
}

APPLOAD.prototype.addNodeType = function (name,value) {

	
	return new Promise( async (resolve, reject) => {
	
		const that = this;

		try {

			var acount1 = "0xE008F902319bD079E8ce6b28b01C8c7dA2985d1e";
			var acount2 = "0x3AA56B5A0019D9867945FF456a64010D37ba06bB";
			var acount3 = "0x63e881DD7d36D50A7899A6a44c1B82c3D126B640";
			var acount4 = "0x6bA6ff472F6F10817e6735aaA906838cA583872a";

			const tokenContractAddr = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";

			var jsonFile = "./files/NodeRewardABI.js";
			//console.log("alooooooo",jsonFile);
			var abi1= JSON.parse(fs.readFileSync(jsonFile));
			//console.log("teesst parseeed",parsed);

			//var abi1 = parsed.abi;
		
			
			contractAddress = that.config.contractaddress_nodeManage;
			const contract = new that.web3.eth.Contract(abi1,contractAddress);

			

			const testNode = await contract.methods.addNodeType(name,value);
	
			resolve(testNode);
		}catch(err) {
			console.error(err)
		}
	
	});
}


APPLOAD.prototype.getTotalCreatedNodes = function () {

	
	return new Promise( async (resolve, reject) => {
	
		const that = this;

		try {
			var jsonFile = "./files/NodeRewardABI.js";

			var abi1= JSON.parse(fs.readFileSync(jsonFile));

		
			contractAddress = that.config.contractaddress_nodeManage;
			const contract = new that.web3.eth.Contract(abi1,contractAddress);

			

			const testNode = await contract.methods.getTotalCreatedNodes();
	
			resolve(testNode);
		}catch(err) {
			console.error(err)
		}
	
	});
}

APPLOAD.prototype.getNodeTypeAll = function (name) {

	
	return new Promise( async (resolve, reject) => {
	
		const that = this;

		try {
			var jsonFile = "./files/NodeRewardABI.js";

			var abi1= JSON.parse(fs.readFileSync(jsonFile));


			contractAddress = that.config.contractaddress_nodeManage;

		
			const contract = new that.web3.eth.Contract(abi1,contractAddress);

			

			const testNode = await contract.methods.getNodeTypeAll(name);
	
			resolve(testNode);
		}catch(err) {
			console.error(err)
		}
	
	});
}





APPLOAD.prototype.calculateAllClaimableRewards = function (address) {

	
	return new Promise( async (resolve, reject) => {
	
		const that = this;

		try {
			var jsonFile = "./files/NodeRewardABI.js";

			var abi1= JSON.parse(fs.readFileSync(jsonFile));

			
			contractAddress = that.config.contractaddress_nodeManage;

			const contract = new that.web3.eth.Contract(abi1,contractAddress);

			

			const testNode = await contract.methods.calculateAllClaimableRewards(address);
	
			resolve(testNode);
		}catch(err) {
			console.error(err)
		}
	
	});
}


APPLOAD.prototype.getdistributionPool = function () {

	
	return new Promise( async (resolve, reject) => {
	
		const that = this;

		try {
			var jsonFile = "./files/NodeRewardABI.js";

			var abi1= JSON.parse(fs.readFileSync(jsonFile));

		
			contractAddress = that.config.contractaddress_nodeManage;
			const contract = new that.web3.eth.Contract(abi1,contractAddress);

			

			const testNode = await contract.methods.getdistributionPool();
	
			resolve(testNode);
		}catch(err) {
			console.error(err)
		}
	
	});
}


APPLOAD.prototype.calculateAllClaimableRewards = function (address) {

	
	return new Promise( async (resolve, reject) => {
	
		const that = this;

		try {
			var jsonFile = "./files/NodeRewardABI.js";

			var abi1= JSON.parse(fs.readFileSync(jsonFile));

		
	
			contractAddress = that.config.contractaddress_nodeManage;
			const contract = new that.web3.eth.Contract(abi1,contractAddress);

			

			const testNode = await contract.methods.calculateAllClaimableRewards(address);
	
			resolve(testNode);
		}catch(err) {
			console.error(err)
		}
	
	});
}


APPLOAD.prototype.createNodeFree = function (nodeTypeName,count) {

	
	return new Promise( async (resolve, reject) => {
	
		const that = this;

		try {
			var jsonFile = "./files/NodeRewardABI.js";

			var abi1= JSON.parse(fs.readFileSync(jsonFile));

		
			
			contractAddress = that.config.contractaddress_nodeManage;
			const contract = new that.web3.eth.Contract(abi1,contractAddress);

			

			const testNode = await contract.methods.createNodeFree(nodeTypeName,count);
	
			resolve(testNode);
		}catch(err) {
			console.error(err)
		}
	
	});
}





module.exports = APPLOAD;