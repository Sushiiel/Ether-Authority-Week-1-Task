// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title AccountOwnership
 * @dev Manages accounts with ownership validation
 * @notice Demonstrates multi-level ownership and account management
 */
contract AccountOwnership {
    // Account structure
    struct Account {
        uint256 id;
        address owner;
        string accountName;
        uint256 balance;
        uint256 createdAt;
        bool isActive;
    }
    
    // Mapping from account ID to Account
    mapping(uint256 => Account) public accounts;
    
    // Mapping from address to their account IDs
    mapping(address => uint256[]) public userAccounts;
    
    // Total number of accounts created
    uint256 public accountCount;
    
    // Contract owner
    address public contractOwner;
    
    // Events
    event AccountCreated(uint256 indexed accountId, address indexed owner, string accountName);
    event AccountUpdated(uint256 indexed accountId, string newName);
    event BalanceUpdated(uint256 indexed accountId, uint256 newBalance);
    event OwnershipTransferred(uint256 indexed accountId, address indexed previousOwner, address indexed newOwner);
    event AccountDeactivated(uint256 indexed accountId);
    event AccountReactivated(uint256 indexed accountId);
    
    // Modifiers
    modifier onlyContractOwner() {
        require(msg.sender == contractOwner, "Only contract owner can call this");
        _;
    }
    
    modifier onlyAccountOwner(uint256 accountId) {
        require(accounts[accountId].owner == msg.sender, "Not the account owner");
        _;
    }
    
    modifier accountExists(uint256 accountId) {
        require(accountId < accountCount, "Account does not exist");
        _;
    }
    
    modifier accountActive(uint256 accountId) {
        require(accounts[accountId].isActive, "Account is not active");
        _;
    }
    
    /**
     * @dev Constructor sets contract deployer as owner
     */
    constructor() {
        contractOwner = msg.sender;
    }
    
    /**
     * @dev Create a new account
     * @param accountName Name for the account
     * @return uint256 The ID of the created account
     */
    function createAccount(string memory accountName) public returns (uint256) {
        require(bytes(accountName).length > 0, "Account name cannot be empty");
        
        uint256 newAccountId = accountCount;
        
        accounts[newAccountId] = Account({
            id: newAccountId,
            owner: msg.sender,
            accountName: accountName,
            balance: 0,
            createdAt: block.timestamp,
            isActive: true
        });
        
        userAccounts[msg.sender].push(newAccountId);
        accountCount++;
        
        emit AccountCreated(newAccountId, msg.sender, accountName);
        
        return newAccountId;
    }
    
    /**
     * @dev Update account name
     * @param accountId The account ID
     * @param newName The new name
     */
    function updateAccountName(uint256 accountId, string memory newName) 
        public 
        accountExists(accountId)
        onlyAccountOwner(accountId)
        accountActive(accountId)
    {
        require(bytes(newName).length > 0, "Name cannot be empty");
        accounts[accountId].accountName = newName;
        emit AccountUpdated(accountId, newName);
    }
    
    /**
     * @dev Update account balance (simulated)
     * @param accountId The account ID
     * @param newBalance The new balance
     */
    function updateBalance(uint256 accountId, uint256 newBalance)
        public
        accountExists(accountId)
        onlyAccountOwner(accountId)
        accountActive(accountId)
    {
        accounts[accountId].balance = newBalance;
        emit BalanceUpdated(accountId, newBalance);
    }
    
    /**
     * @dev Transfer account ownership
     * @param accountId The account ID
     * @param newOwner The new owner's address
     */
    function transferAccountOwnership(uint256 accountId, address newOwner)
        public
        accountExists(accountId)
        onlyAccountOwner(accountId)
        accountActive(accountId)
    {
        require(newOwner != address(0), "Invalid new owner address");
        require(newOwner != accounts[accountId].owner, "Already the owner");
        
        address previousOwner = accounts[accountId].owner;
        accounts[accountId].owner = newOwner;
        
        // Add to new owner's list
        userAccounts[newOwner].push(accountId);
        
        emit OwnershipTransferred(accountId, previousOwner, newOwner);
    }
    
    /**
     * @dev Deactivate an account
     * @param accountId The account ID
     */
    function deactivateAccount(uint256 accountId)
        public
        accountExists(accountId)
        onlyAccountOwner(accountId)
    {
        require(accounts[accountId].isActive, "Account already inactive");
        accounts[accountId].isActive = false;
        emit AccountDeactivated(accountId);
    }
    
    /**
     * @dev Reactivate an account
     * @param accountId The account ID
     */
    function reactivateAccount(uint256 accountId)
        public
        accountExists(accountId)
        onlyAccountOwner(accountId)
    {
        require(!accounts[accountId].isActive, "Account already active");
        accounts[accountId].isActive = true;
        emit AccountReactivated(accountId);
    }
    

    function getAccount(uint256 accountId)
        public
        view
        accountExists(accountId)
        returns (
            uint256 id,
            address owner,
            string memory accountName,
            uint256 balance,
            uint256 createdAt,
            bool isActive
        )
    {
        Account memory account = accounts[accountId];
        return (
            account.id,
            account.owner,
            account.accountName,
            account.balance,
            account.createdAt,
            account.isActive
        );
    }
    
    /**
     * @dev Get all account IDs owned by an address
     * @param owner The owner's address
     * @return uint256[] Array of account IDs
     */
    function getAccountsByOwner(address owner) public view returns (uint256[] memory) {
        return userAccounts[owner];
    }
    
    /**
     * @dev Check if address owns a specific account
     * @param accountId The account ID
     * @param owner The address to check
     * @return bool True if owner owns the account
     */
    function isAccountOwner(uint256 accountId, address owner)
        public
        view
        accountExists(accountId)
        returns (bool)
    {
        return accounts[accountId].owner == owner;
    }
    
    /**
     * @dev Get total number of accounts
     * @return uint256 Total account count
     */
    function getTotalAccounts() public view returns (uint256) {
        return accountCount;
    }
}

/*
 * DEPLOYMENT INSTRUCTIONS:
 * 
 * 1. Compile and deploy to Sepolia
 * 2. Test account management:
 *    a) createAccount("My First Account")
 *    b) getAccount(0) - view account details
 *    c) updateAccountName(0, "Updated Name")
 *    d) updateBalance(0, 1000)
 *    e) getAccountsByOwner(your_address)
 *    f) transferAccountOwnership(0, another_address)
 *    g) deactivateAccount(0)
 *    h) reactivateAccount(0)
 * 
 * LEARNING OBJECTIVES:
 * - Complex data structures (structs)
 * - Multiple modifiers on functions
 * - Ownership patterns
 * - Access control at multiple levels
 * - Array and mapping relationships
 * - Account/user management patterns
 * 
 * USE CASES:
 * - Multi-account systems
 * - User profile management
 * - Ownership tracking
 * - Account lifecycle management
 * - Permission systems
 */
