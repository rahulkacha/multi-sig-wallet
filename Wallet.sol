// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Multi-Signature Wallet
/// @author Rahul Kacha
/// @notice This contract implements a multi-signature wallet, where transactions must be confirmed by multiple owners before being executed.
/// @dev The contract inherits from Ownable to have ownership control. It uses a confirmation-based mechanism to execute transactions.

contract Wallet is Ownable {
    /// @dev Struct representing a transaction in the wallet.
    /// @param to The address to which the funds will be sent.
    /// @param value The amount of funds to be sent.
    /// @param executed Boolean indicating whether the transaction has been executed.
    /// @param numConfirmations Number of confirmations received for the transaction.
    struct Transaction {
        address to;
        uint256 value;
        bool executed;
        uint256 numConfirmations;
    }

    address[] private owners; // List of wallet owners.
    mapping(address => bool) private isOwner; // Mapping to check if an address is an owner.
    uint256 private numConfirmationsRequired; // Number of confirmations required to execute a transaction.
    Transaction[] private transactions; // List of all transactions.
    mapping(uint256 => mapping(address => bool)) public isConfirmed; // Mapping to check if a transaction has been confirmed by an owner.

    // Events
    /// @notice Emitted when a new transaction is generated.
    /// @param owner The address of the owner who generated the transaction.
    /// @param txIndex The index of the generated transaction.
    /// @param to The recipient address of the transaction.
    /// @param value The amount of the transaction.
    event GenerateTransaction(
        address indexed owner,
        uint256 indexed txIndex,
        address indexed to,
        uint256 value
    );

    /// @notice Emitted when a transaction is confirmed.
    /// @param owner The address of the owner who confirmed the transaction.
    /// @param txIndex The index of the confirmed transaction.
    event ConfirmTransaction(address indexed owner, uint256 indexed txIndex);

    /// @notice Emitted when a transaction is executed.
    /// @param owner The address of the owner who executed the transaction.
    /// @param txIndex The index of the executed transaction.
    event ExecuteTransaction(address indexed owner, uint256 indexed txIndex);

    // Modifiers
    /// @dev Ensures that the transaction exists.
    /// @param _txIndex The index of the transaction.
    modifier txExists(uint256 _txIndex) {
        require(_txIndex < transactions.length, "Transaction does not exist");
        _;
    }

    /// @dev Ensures that the transaction has not been executed yet.
    /// @param _txIndex The index of the transaction.
    modifier notExecuted(uint256 _txIndex) {
        require(
            !transactions[_txIndex].executed,
            "Transaction already executed"
        );
        _;
    }

    /// @dev Ensures that the transaction has not been confirmed by the sender.
    /// @param _txIndex The index of the transaction.
    modifier notConfirmed(uint256 _txIndex) {
        require(
            !isConfirmed[_txIndex][msg.sender],
            "Transaction already confirmed"
        );
        _;
    }

    /// @dev Ensures that the sender is an authorized owner.
    /// @param _address The address to check.
    modifier isAuthorized(address _address) {
        bool found = false;
        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] == _address) {
                found = true;
                break;
            }
        }
        require(found, "Unauthorized operation.");
        _;
    }

    /// @notice Initializes the wallet with a list of owners.
    /// @param _owners The list of addresses to be set as owners.
    constructor(address[] memory _owners) Ownable(msg.sender) {
        require(_owners.length > 0, "At least one owner required");

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            require(owner != address(0), "Invalid owner address");
            require(!isOwner[owner], "Duplicate owner");

            isOwner[owner] = true;
            owners.push(owner);
        }

        numConfirmationsRequired = _owners.length;
    }

    /// @notice Returns the list of owners.
    /// @return An array of owner addresses.
    function getOwners() public view returns (address[] memory) {
        return owners;
    }

    /// @notice Generates a new transaction and adds it to the list of transactions.
    /// @param _to The recipient address of the transaction.
    /// @param _value The amount of funds to be sent.
    function generateTransaction(address _to, uint256 _value) public {
        uint256 txIndex = transactions.length;

        transactions.push(
            Transaction({
                to: _to,
                value: _value,
                executed: false,
                numConfirmations: 0
            })
        );

        emit GenerateTransaction(msg.sender, txIndex, _to, _value);
    }

    /// @notice Confirms a transaction, increasing its number of confirmations.
    /// @param _txIndex The index of the transaction to confirm.
    function confirmTransaction(uint256 _txIndex)
        public
        isAuthorized(msg.sender)
        txExists(_txIndex)
        notExecuted(_txIndex)
        notConfirmed(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations += 1;
        isConfirmed[_txIndex][msg.sender] = true;

        emit ConfirmTransaction(msg.sender, _txIndex);
        if (transaction.numConfirmations >= numConfirmationsRequired) {
            executeTransaction(_txIndex);
        }
    }

    /// @dev Executes a transaction if the required number of confirmations is met.
    /// @param _txIndex The index of the transaction to execute.
    function executeTransaction(uint256 _txIndex)
        private
        notExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        transaction.executed = true;

        emit ExecuteTransaction(msg.sender, _txIndex);
    }

    /// @notice Returns the details of a transaction.
    /// @param _txIndex The index of the transaction to retrieve.
    /// @return to The recipient address of the transaction.
    /// @return value The amount of funds to be sent.
    /// @return executed Whether the transaction has been executed.
    /// @return numConfirmations The number of confirmations received.
    function getTransaction(uint256 _txIndex)
        public
        view
        returns (
            address to,
            uint256 value,
            bool executed,
            uint256 numConfirmations
        )
    {
        Transaction storage transaction = transactions[_txIndex];

        return (
            transaction.to,
            transaction.value,
            transaction.executed,
            transaction.numConfirmations
        );
    }

    /// @notice Returns the list of all transactions.
    /// @return length The total number of transactions.
    /// @return The array of transactions.
    function getAllTransactions()
        public
        view
        returns (uint256 length, Transaction[] memory)
    {
        return (transactions.length, transactions);
    }
}
