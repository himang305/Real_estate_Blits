require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");
require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.7",
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
    },
    testnet: {
      url: "https://matic-testnet-archive-rpc.bwarelabs.com",
      chainId: 80001,
      accounts: ["86dff4ceb17c9e487a75826ece38e31ca9d42d40269662f0900f6392f6234401"]
    },
    mainnet: {
      url: "https://polygon-rpc.com",
      chainId: 137,
      accounts: ["86dff4ceb17c9e487a75826ece38e31ca9d42d40269662f0900f6392f6234401"]
    }
  },
  etherscan: {
    apiKey: "CT3YM4K58YF4URCWY8XX47WAFYXWRUQRUQ"
  }
};
