const { projectId, mnemonic } = require('./secrets.json');
const HDWalletProvider = require('@truffle/hdwallet-provider');

module.exports = {
  networks: {
    rinkeby: {
      provider: () => new HDWalletProvider(
        mnemonic, 'https://rinkeby.infura.io/v3/584084239d3e41bb9b4f3b8cb5f2a446'
      ),
      //gasPrice: 5e9,
      //networkId: '3',
    },
    ganache: {
      host: "127.0.0.1",     // Localhost (default: none)
      port: 8545,            // Standard Ethereum port (default: none)
      network_id: "*",       // Any network (default: none)
      gas: 80000000
      ,
     }
  },
};
