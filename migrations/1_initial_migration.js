const Migrations = artifacts.require("Migrations");
const Dispenser = artifacts.require("Dispenser");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deplorer.deploy(Dispenser);
};
