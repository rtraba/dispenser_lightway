const { projectId, mnemonic } = require('./secrets.json');
const HDWalletProvider = require('@truffle/hdwallet-provider');

module.exports = {
  networks: {
    rinkeby: {
      provider: () => new HDWalletProvider(
        mnemonic, 'https://rinkeby.infura.io/v3/c26ca1b762ed43f2999d00a4f8a8958a'
      ),
     //gas: 100000000,
     // gasPrice: 5e9,
     // gasPrice: 100000000000000, LIMIT10000000
     // networkId: '4'
    },
    //https://ropsten.infura.io/v3/584084239d3e41bb9b4f3b8cb5f2a446
    ropsten: {
      provider: () => new HDWalletProvider(
        mnemonic, 'https://ropsten.infura.io/v3/584084239d3e41bb9b4f3b8cb5f2a446'
      ),
      gas: 800000000,
      //gasPrice: 5e9,
      gasPrice: 100000000000000,
      networkId: '*'
    },
    ganache: {
      host: "127.0.0.1",     // Localhost (default: none)
      port: 8545,            // Standard Ethereum port (default: none)
      network_id: "*",       // Any network (default: none)
    //  gas: 800000000
      //,
     }
  },
};
