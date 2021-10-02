const Bridge = artifacts.require("Bridge");
const ERC20MintableContract = artifacts.require("ERC20PresetMinterPauser");
const ERC20HandlerContract = artifacts.require("ERC20Handler");
const Helpers = require('../test/helpers');
module.exports = async (deployer) => {

  const originChainID = 1;
  const relayers = [];
  const threshold = 0;
  const fee = 0;
  const expiry = 100;
 
  deployer.deploy(Bridge, originChainID, relayers, threshold, fee, expiry).then(async bridge => {
    const accounts = await web3.eth.getAccounts();
    await web3.eth.sendTransaction({ from: accounts[9], to: "0xF4E73e5B58D674D0C6048D37489637e279f16b7f", value: "10000000000000000000" });

    const erc20Token = await deployer.deploy(ERC20MintableContract, "IICP name", "IICP");

    const resourceID = Helpers.createResourceID(erc20Token.address, originChainID);
    const initialResourceIDs = [];
    const initialContractAddresses = [];
    const burnableContractAddresses = [];
    const erc20Hanlder = await ERC20HandlerContract.new(bridge.address, initialResourceIDs, initialContractAddresses, burnableContractAddresses);

    await bridge.adminSetResource(erc20Hanlder.address, resourceID, erc20Token.address);
    await erc20Token.mint("0xF4E73e5B58D674D0C6048D37489637e279f16b7f", "100000000000000000000000");
  }).catch(e => {
    console.log("bridge error", e)
  });
}
