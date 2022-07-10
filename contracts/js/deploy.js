
const HDWalletProvider = require('truffle-hdwallet-provider');
const Web3 = require('web3');
const { abi, bytecode } = require('./compile');

const mnemonic = 'truck wine lumber resist neck window member pupil tool hungry ancient forget';
const accountAddress = '0xEEd9658E67ed2F445355541f3FbdA769B4d6A50e';
const privateKey = '0x12d65454addde15ca8f5154bb236e16bc5bec11c2ff2cdba4dbab403343ae4c9';
const gasPrice = 20000000000;
const gasLimit = 6721975;

const provider = new HDWalletProvider(mnemonic, 'http://localhost:8545');

const web3 = new Web3(provider);

const deploy = async ()=>{
	const accounts = await web3.eth.getAccounts();
	const argumentsConstructor = [];

	const gasEstimate = await new web3.eth.Contract(abi)
					.deploy({
						data:bytecode,
						arguments:argumentsConstructor
					})
					.estimateGas({
						from:accounts[0]
					});

	const result = await new web3.eth.Contract(abi)
					.deploy({
						data:bytecode,
						arguments:argumentsConstructor
					})
					.send({
						gas: gasEstimate,
						from: accounts[0]
					});

	console.log(result);
	console.log("Contract deployed to : "+result.options.address);
};

deploy();