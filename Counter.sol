// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Counter
 * @dev A simple counter contract to demonstrate state management
 * @notice This contract maintains a counter that can be incremented and decremented
 */
contract Counter {
    // State variable to store the count
    uint256 public count;
    
    // Events
    event Incremented(uint256 newCount, address incrementedBy);
    event Decremented(uint256 newCount, address decrementedBy);
    event Reset(address resetBy);
    event CountSet(uint256 newCount, address setBy);
    
    /**
     * @dev Constructor initializes counter to 0
     */
    constructor() {
        count = 0;
    }
    
    /**
     * @dev Returns the current count
     * @return uint256 The current counter value
     */
    function getCount() public view returns (uint256) {
        return count;
    }
    
    /**
     * @dev Increments the counter by 1
     */
    function increment() public {
        count += 1;
        emit Incremented(count, msg.sender);
    }
    
    /**
     * @dev Decrements the counter by 1
     * @notice Will revert if count is already 0
     */
    function decrement() public {
        require(count > 0, "Counter: cannot decrement below zero");
        count -= 1;
        emit Decremented(count, msg.sender);
    }
    
    /**
     * @dev Increments counter by a specific amount
     * @param amount The amount to increment by
     */
    function incrementBy(uint256 amount) public {
        count += amount;
        emit Incremented(count, msg.sender);
    }
    
    /**
     * @dev Decrements counter by a specific amount
     * @param amount The amount to decrement by
     */
    function decrementBy(uint256 amount) public {
        require(count >= amount, "Counter: insufficient count to decrement");
        count -= amount;
        emit Decremented(count, msg.sender);
    }
    
    /**
     * @dev Resets the counter to 0
     */
    function reset() public {
        count = 0;
        emit Reset(msg.sender);
    }
    
    /**
     * @dev Sets counter to a specific value
     * @param newCount The new counter value
     */
    function setCount(uint256 newCount) public {
        count = newCount;
        emit CountSet(newCount, msg.sender);
    }
}

/*
 * DEPLOYMENT INSTRUCTIONS:
 * 
 * 1. Compile with Solidity 0.8.x in Remix
 * 2. Deploy to Sepolia testnet
 * 3. Test functions:
 *    - getCount() - should return 0 initially
 *    - increment() - increases count by 1
 *    - incrementBy(5) - increases count by 5
 *    - decrement() - decreases count by 1
 *    - decrementBy(2) - decreases count by 2
 *    - reset() - sets count back to 0
 *    - setCount(100) - sets count to 100
 * 
 * LEARNING OBJECTIVES:
 * - State management
 * - require statements for validation
 * - uint256 data type
 * - Multiple function variations
 * - Event emissions
 * - Error handling
 */
