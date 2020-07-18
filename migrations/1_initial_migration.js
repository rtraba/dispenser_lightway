const Migrations = artifacts.require("Migrations");
const Dispenser = artifacts.require("Dispenser");
const DispensedToken = artifacts.require("DispensedToken")

module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(Dispenser);
};

