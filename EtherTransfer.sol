// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title EtherTransfer
 * @dev Contract to demonstrate sending and receiving Ether
 * @notice Learn how to handle ETH transactions in smart contracts
 */
contract EtherTransfer {
    // Contract owner
    address public owner;
    
    // Track total deposits and withdrawals
    uint256 public totalDeposits;
    uint256 public totalWithdrawals;
    
    // Mapping to track individual user balances
    mapping(address => uint256) public balances;
    
    // Events
    event Deposit(address indexed from, uint256 amount);
    event Withdrawal(address indexed to, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    
    /**
     * @dev Constructor sets the contract deployer as owner
     */
    constructor() {
        owner = msg.sender;
    }
    
    /**
     * @dev Fallback function to receive Ether
     * @notice Automatically called when ETH is sent to contract
     */
    receive() external payable {
        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
    
    /**
     * @dev Explicit deposit function
     * @notice Send ETH along with this transaction
     */
    function deposit() public payable {
        require(msg.value > 0, "Must send some Ether");
        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
    
    /**
     * @dev Get contract's total balance
     * @return uint256 The contract's ETH balance
     */
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
    
    /**
     * @dev Get user's balance in the contract
     * @param user The user's address
     * @return uint256 The user's balance
     */
    function getUserBalance(address user) public view returns (uint256) {
        return balances[user];
    }
    
    /**
     * @dev Withdraw user's balance
     * @param amount The amount to withdraw
     */
    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        require(address(this).balance >= amount, "Contract has insufficient funds");
        
        balances[msg.sender] -= amount;
        totalWithdrawals += amount;
        
        // Transfer ETH to user
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        
        emit Withdrawal(msg.sender, amount);
    }
    
    /**
     * @dev Withdraw all of user's balance
     */
    function withdrawAll() public {
        uint256 balance = balances[msg.sender];
        require(balance > 0, "No balance to withdraw");
        
        withdraw(balance);
    }
    
    /**
     * @dev Transfer ETH from sender to another address
     * @param to The recipient's address
     * @param amount The amount to transfer
     */
    function transferTo(address payable to, uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        require(to != address(0), "Cannot transfer to zero address");
        
        balances[msg.sender] -= amount;
        balances[to] += amount;
        
        emit Transfer(msg.sender, to, amount);
    }
    
    /**
     * @dev Owner can withdraw contract balance (for emergencies)
     * @param amount The amount to withdraw
     */
    function ownerWithdraw(uint256 amount) public {
        require(msg.sender == owner, "Only owner can call this");
        require(address(this).balance >= amount, "Insufficient contract balance");
        
        totalWithdrawals += amount;
        
        (bool success, ) = owner.call{value: amount}("");
        require(success, "Transfer failed");
        
        emit Withdrawal(owner, amount);
    }
    
    /**
     * @dev Send ETH directly to an address (owner only)
     * @param to The recipient's address
     * @param amount The amount to send
     */
    function sendEther(address payable to, uint256 amount) public {
        require(msg.sender == owner, "Only owner can send");
        require(address(this).balance >= amount, "Insufficient balance");
        
        (bool success, ) = to.call{value: amount}("");
        require(success, "Send failed");
        
        emit Transfer(address(this), to, amount);
    }
}

/*
 * DEPLOYMENT INSTRUCTIONS:
 * 
 * 1. Compile and deploy to Sepolia
 * 2. Test ETH handling:
 *    a) Send ETH to contract address (receive function)
 *    b) Call deposit() with ETH value
 *    c) Check getContractBalance()
 *    d) Check getUserBalance(your_address)
 *    e) withdraw(amount) to get ETH back
 *    f) transferTo(another_address, amount)
 * 
 * LEARNING OBJECTIVES:
 * - receive() and fallback functions
 * - payable keyword
 * - msg.value usage
 * - ETH transfers (.call method)
 * - Balance tracking
 * - Security: checks-effects-interactions pattern
 * 
 * IMPORTANT NOTES:
 * - Use .call{value: amount}("") for ETH transfers (most secure)
 * - Always check balances before transfers
 * - Emit events for all money movements
 * - Test with small amounts first!
 * 
 * SEPOLIA TESTNET:
 * - Use test ETH only
 * - Verify on Sepolia Etherscan
 * - Check transaction logs
 */
