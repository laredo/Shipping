var TestShippingDriver = artifacts.require("TestShippingDriver");

module.exports = function(deployer) {
  deployer.deploy(TestShippingDriver);
};
