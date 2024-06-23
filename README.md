# EthFund

EthFund is a decentralized funding platform built on the Ethereum blockchain that allows users to contribute Ether (ETH) to projects or individuals. The smart contract leverages Chainlink price feeds to ensure contributions meet a minimum USD threshold. It is built using Solidity and utilizes OpenZeppelin's libraries for secure and efficient smart contract development.

## Contract Details

- **Sepolia Etherscan Link:** [View Contract on Etherscan](https://sepolia.etherscan.io/address/0xEf31cb7a45499e26ab6FFcD6eF14A020C24e087F)
- **Contract Address:** `0xEf31cb7a45499e26ab6FFcD6eF14A020C24e087F`

## Features

- Contribute Ether (ETH) to projects or individuals.
- Minimum contribution amount enforced via Chainlink price feeds.
- Only the contract owner can withdraw funds.
- Pausable contract functionality.
- Secure smart contract development with OpenZeppelin libraries.

## Table of Contents

- [EthFund](#ethfund)
  - [Features](#features)
  - [Getting Started](#getting-started)
    - [Requirements](#requirements)
    - [Installation](#installation)
    - [Deployment](#deployment)
  - [Usage](#usage)
    - [Funding a Project](#funding-a-project)
    - [Withdrawing Funds](#withdrawing-funds)
  - [Testing](#testing)
  - [Contributing](#contributing)

## Getting Started

### Requirements

- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  - Ensure Git is installed by running `git --version`.
- [Foundry](https://getfoundry.sh/)
  - Ensure Foundry is installed by running `forge --version`.
- [Make](https://www.gnu.org/software/make/)
  - Ensure Make is installed by running `make --version`.

### Installation

Clone the repository and remove dependencies:

```bash
git clone https://github.com/obinnafranklinduru/ethfund
cd ethfund
make remove
```

install dependencies:

```bash
make install
```

Update dependencies to the latest versions:

```bash
make update
```

### Deployment

Ensure you have the necessary environment variables set in a `.env` file:

```env
SEPOLIA_RPC_URL=<your_sepolia_rpc_url>
PRIVATE_KEY=<your_private_key>
ETHERSCAN_API_KEY=<your_etherscan_api_key>
```

Deploy the contract using the Makefile:

```bash
make deploy ARGS="--network sepolia"
```

## Usage

### Funding a Project

Users can fund a project by sending Ether (ETH) to the contract. The contract ensures the minimum contribution amount is met.

```solidity
function fund() public payable whenNotPaused {
    require(msg.value >= MINIMUM_USD, "You need to spend more ETH!");
    // Function logic...
}
```

### Withdrawing Funds

Only the contract owner can withdraw funds from the contract.

```solidity
function withdraw() public payable onlyOwner nonReentrant whenNotPaused {
    // Function logic...
}
```

## Testing

Run tests to ensure the contract functions as expected.

```bash
make test
```

## Limitations

- The contract only supports contributions in ETH. It does not allow for contributions in other cryptocurrencies or tokens, limiting its flexibility.

## Contributing

PRs are welcome!

```bash
git clone https://github.com/obinnafranklinduru/ethfund
cd ethfund
make help
```
