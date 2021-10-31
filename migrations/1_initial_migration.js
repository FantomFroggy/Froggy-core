const Migrations = artifacts.require("FROGGY");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
};
