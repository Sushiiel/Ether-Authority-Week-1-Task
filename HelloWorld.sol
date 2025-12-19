// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title HelloWorld
 * @dev The simplest smart contract - your first step into blockchain development
 * @notice This contract stores and returns a greeting message
 */
contract HelloWorld {
    // State variable to store the greeting message
    string public message;
    
    // Event emitted when message is updated
    event MessageUpdated(string oldMessage, string newMessage, address updatedBy);
    
    /**
     * @dev Constructor sets the initial greeting message
     */
    constructor() {
        message = "Hello, Web3 World!";
    }
    
    /**
     * @dev Returns the greeting message
     * @return string The current greeting message
     */
    function getMessage() public view returns (string memory) {
        return message;
    }
    
    /**
     * @dev Updates the greeting message
     * @param newMessage The new greeting to set
     */
    function setMessage(string memory newMessage) public {
        string memory oldMessage = message;
        message = newMessage;
        emit MessageUpdated(oldMessage, newMessage, msg.sender);
    }
    
    /**
     * @dev Returns a personalized greeting
     * @param name The name to include in greeting
     * @return string A personalized greeting message
     */
    function greet(string memory name) public pure returns (string memory) {
        return string(abi.encodePacked("Hello, ", name, "! Welcome to blockchain development!"));
    }
}

/*
 * DEPLOYMENT INSTRUCTIONS:
 * 
 * 1. Open Remix IDE (https://remix.ethereum.org)
 * 2. Create new file: HelloWorld.sol
 * 3. Paste this code
 * 4. Compile with Solidity 0.8.x
 * 5. Deploy to Sepolia testnet
 * 6. Test functions:
 *    - getMessage() - should return "Hello, Web3 World!"
 *    - setMessage("New message") - update the greeting
 *    - greet("Your Name") - get personalized greeting
 * 
 * LEARNING OBJECTIVES:
 * - Understanding contract structure
 * - State variables
 * - View vs pure functions
 * - Events
 * - Constructor
 * - Basic data types (string)
 */
