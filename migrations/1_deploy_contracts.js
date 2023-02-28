const SmartContract = artifacts.require("ContactsContract");
module.exports = function (deployer) {
  deployer.deploy(SmartContract);
};