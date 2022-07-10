const path = require('path');
const fs = require('fs');
const solc = require('solc');

const TopacioSubscriptionsPath = path.join(__dirname,'../TopacioSubscription.sol');
const code = fs.readFileSync(TopacioSubscriptionsPath,'utf8');

const inputConfig = {
	language: 'Solidity',
	sources:{
		'TopacioSubscription.sol':{
			content: code
		}
	},
	settings:{
		outputSelection:{
			'*':{
				'*':['*']
			}
		}
	}
};

const output = JSON.parse(solc.compile(JSON.stringify(inputConfig)));

module.exports = {
	abi: output.contracts["TopacioSubscription.sol"].TopacioSubscription.abi,
	bytecode: output.contracts["TopacioSubscription.sol"].TopacioSubscription.evm.bytecode.object
}