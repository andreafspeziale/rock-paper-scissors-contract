var RPS = artifacts.require("./RockPaperScissors.sol");

module.exports = deployer => {
    deployer.deploy(RPS);
  };