# Multi-Signature Wallet

## Overview

This Solidity contract implements a Multi-Signature Wallet, a type of smart contract that requires multiple owners to approve a transaction before it can be executed. This ensures that no single person can unilaterally control the funds, adding an additional layer of security.

## Table of Contents

- [Features](#features)
- [Contract Details](#contract-details)
- [Usage](#usage)
- [Functions](#functions)
- [Events](#events)
- [Requirements](#requirements)
- [Deployment](#deployment)
- [Integration with an ERC20 Token](#Integration)
- [License](#license)

## Features

- **Multi-Signature Authorization**: Transactions require confirmation from multiple owners before execution.
- **Transaction Management**: Create, confirm, and execute transactions.
- **Transaction History**: Retrieve details of individual transactions and view all transactions.

## Contract Details

- **Contract Name**: `Wallet`
- **Author**: Rahul Kacha
- **License**: GPL-3.0

## Usage

To use this contract, deploy it on an Ethereum-compatible network with a list of initial owners. Owners can then generate and confirm transactions.

### Example Workflow

1. **Deploy the Contract**: Provide a list of owner addresses during deployment.
2. **Generate a Transaction**: Use the `generateTransaction` function to create a new transaction.
3. **Confirm a Transaction**: Each owner confirms the transaction using the `confirmTransaction` function.
4. **Execute the Transaction**: Once the required number of confirmations is met, the transaction is executed automatically.

## Functions

### `constructor(address[] memory _owners)`

Initializes the wallet with a list of owners.

- `_owners`: An array of addresses to be set as owners.

### `function getOwners() public view returns (address[] memory)`

Returns the list of current owners.

### `function generateTransaction(address _to, uint256 _value) public`

Generates a new transaction.

- `_to`: The recipient address.
- `_value`: The amount of funds to be sent.

### `function confirmTransaction(uint256 _txIndex) public`

Confirms a transaction.

- `_txIndex`: The index of the transaction to confirm.

### `function getTransaction(uint256 _txIndex) public view returns (address to, uint256 value, bool executed, uint256 numConfirmations)`

Returns the details of a transaction.

- `_txIndex`: The index of the transaction to retrieve.

### `function getAllTransactions() public view returns (uint256 length, Transaction[] memory)`

Returns all transactions.

## Events

### `event GenerateTransaction(address indexed owner, uint256 indexed txIndex, address indexed to, uint256 value)`

Emitted when a new transaction is generated.

### `event ConfirmTransaction(address indexed owner, uint256 indexed txIndex)`

Emitted when a transaction is confirmed.

### `event ExecuteTransaction(address indexed owner, uint256 indexed txIndex)`

Emitted when a transaction is executed.

## Requirements

- **Solidity Version**: ^0.8.2
- **OpenZeppelin Contracts**: ^4.0.0 (for `Ownable`)

## Deployment

To deploy the contract, use a tool like Truffle or Hardhat with a suitable Ethereum testnet or mainnet. Ensure that you provide the initial list of owners during deployment.

## Integration with an ERC20 Token

### Overview

The Multi-Signature Wallet contract can be integrated with an ERC20 token contract to manage token transactions securely. This integration enables the Multi-Signature Wallet to handle both ETH and ERC20 token transfers, enhancing its functionality and flexibility.

### Integration Possibility

To integrate the Multi-Signature Wallet with an ERC20 token contract, follow these general steps:

1. **Deploy the ERC20 Token Contract**: Ensure that the ERC20 token contract (e.g., [`StandardToken`](https://github.com/rahulkacha/standard-token/)) is deployed on the Ethereum network.

2. **Update the Multi-Signature Wallet Contract**:
   - **Reference ERC20 Token**: Import and reference the ERC20 token contract in the Multi-Signature Wallet.
   - **Modify Transaction Handling**: Update the `Transaction` struct and related functions to support both ETH and ERC20 token transactions.
   - **Handle Token Transfers**: Implement logic to transfer tokens using the ERC20 contract's functions.

### Example Implementation

Here is a conceptual example of how the Multi-Signature Wallet contract can be updated to support ERC20 token transactions:

```solidity
// Import the ERC20 token contract
import "./StandardToken.sol";

// Modify the Multi-Signature Wallet contract to include ERC20 token interactions
contract Wallet {
    struct Transaction {
        address to;
        uint256 value;
        address token; // Address of the ERC20 token contract
        bool executed;
        uint256 numConfirmations;
    }

    // Additional code...

    function generateTransaction(address _to, uint256 _value, address _token) public {
        // Add support for ERC20 token transactions
    }

    function executeTransaction(uint256 _txIndex) private {
        Transaction storage transaction = transactions[_txIndex];

        if (transaction.token == address(0)) {
            // ETH transfer
            payable(transaction.to).transfer(transaction.value);
        } else {
            // ERC20 token transfer
            StandardToken token = StandardToken(transaction.token);
            token.transfer(transaction.to, transaction.value);
        }
    }

    // Additional code...
}
```

## License

This contract is licensed under the [GPL-3.0 License](https://opensource.org/licenses/GPL-3.0).
