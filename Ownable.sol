// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Ownable
 * @dev Contract module which provides basic access control mechanism
 * @notice Only the contract owner can execute certain functions
 */
contract Ownable {
    // The owner of the contract
    address public owner;
    
    // Previous owner (for tracking ownership transfers)
    address public previousOwner;
    
    // Events
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OwnerActionExecuted(string action, address executor);
    
    // Modifier to restrict functions to owner only
    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }
    
    /**
     * @dev Constructor sets the deployer as the initial owner
     */
    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), owner);
    }
    
    /**
     * @dev Returns the address of the current owner
     * @return address The owner's address
     */
    function getOwner() public view returns (address) {
        return owner;
    }
    
    /**
     * @dev Transfers ownership to a new address
     * @param newOwner The address of the new owner
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        require(newOwner != owner, "Ownable: new owner is the same as current owner");
        
        previousOwner = owner;
        owner = newOwner;
        
        emit OwnershipTransferred(previousOwner, newOwner);
    }
    
    /**
     * @dev Renounces ownership, leaving the contract without an owner
     * @notice This will make owner-only functions permanently unusable
     */
    function renounceOwnership() public onlyOwner {
        previousOwner = owner;
        owner = address(0);
        emit OwnershipTransferred(previousOwner, address(0));
    }
    
    /**
     * @dev Example of an owner-only function
     * @param action Description of the action being performed
     */
    function executeOwnerAction(string memory action) public onlyOwner {
        emit OwnerActionExecuted(action, msg.sender);
    }
    
    /**
     * @dev Check if an address is the owner
     * @param account The address to check
     * @return bool True if the address is the owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }
}

/*
 * DEPLOYMENT INSTRUCTIONS:
 * 
 * 1. Compile and deploy to Sepolia
 * 2. Note: You (deployer) will be the initial owner
 * 3. Test functions:
 *    - getOwner() - should return your address
 *    - isOwner(your_address) - should return true
 *    - executeOwnerAction("Testing") - should succeed
 *    - Try from another account - should fail
 *    - transferOwnership(new_address) - transfers ownership
 * 
 * LEARNING OBJECTIVES:
 * - Access control patterns
 * - Modifiers (onlyOwner)
 * - require statements for authorization
 * - Ownership transfer patterns
 * - Event-driven architecture
 * - Security best practices
 * 
 * SECURITY NOTES:
 * - Always validate new owner address
 * - Use events to track ownership changes
 * - Be careful with renounceOwnership (irreversible)
 * - Test thoroughly before transferring ownership
 */
