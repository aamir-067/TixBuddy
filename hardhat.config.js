require("@nomicfoundation/hardhat-toolbox");
const privateData = require('./PrivateKeyAndUrl.json')

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.19",
  networks: {
    sepolia: {
      url: privateData.url,
      accounts: privateData.accounts
    }
  }
};
