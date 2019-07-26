var ShippingDriver = artifacts.require("ShippingDriver");

module.exports = function(deployer) {
  deployer.deploy(ShippingDriver);
};
