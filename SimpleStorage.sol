// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SimpleStorage
 * @dev Store and retrieve various types of data on the blockchain
 * @notice Demonstrates data storage patterns in Solidity
 */
contract SimpleStorage {
    // Different data types
    uint256 public storedNumber;
    string public storedString;
    bool public storedBoolean;
    address public storedAddress;
    
    // Mapping for key-value storage
    mapping(uint256 => string) public dataMapping;
    
    // Array to store multiple numbers
    uint256[] public numberArray;
    
    // Struct for complex data
    struct Person {
        string name;
        uint256 age;
        address wallet;
    }
    
    // Mapping to store Person structs
    mapping(uint256 => Person) public people;
    uint256 public peopleCount;
    
    // Events
    event NumberStored(uint256 number, address storedBy);
    event StringStored(string text, address storedBy);
    event BooleanStored(bool value, address storedBy);
    event AddressStored(address addr, address storedBy);
    event PersonAdded(uint256 id, string name, uint256 age);
    
    /**
     * @dev Store a number
     * @param _number The number to store
     */
    function storeNumber(uint256 _number) public {
        storedNumber = _number;
        emit NumberStored(_number, msg.sender);
    }
    
    /**
     * @dev Retrieve the stored number
     * @return uint256 The stored number
     */
    function getNumber() public view returns (uint256) {
        return storedNumber;
    }
    
    /**
     * @dev Store a string
     * @param _text The string to store
     */
    function storeString(string memory _text) public {
        storedString = _text;
        emit StringStored(_text, msg.sender);
    }
    
    /**
     * @dev Retrieve the stored string
     * @return string The stored string
     */
    function getString() public view returns (string memory) {
        return storedString;
    }
    
    /**
     * @dev Store a boolean
     * @param _value The boolean value to store
     */
    function storeBoolean(bool _value) public {
        storedBoolean = _value;
        emit BooleanStored(_value, msg.sender);
    }
    
    /**
     * @dev Store an address
     * @param _address The address to store
     */
    function storeAddress(address _address) public {
        storedAddress = _address;
        emit AddressStored(_address, msg.sender);
    }
    
    /**
     * @dev Store data in mapping
     * @param _key The key for the mapping
     * @param _value The value to store
     */
    function storeInMapping(uint256 _key, string memory _value) public {
        dataMapping[_key] = _value;
    }
    
    /**
     * @dev Get data from mapping
     * @param _key The key to look up
     * @return string The value associated with the key
     */
    function getFromMapping(uint256 _key) public view returns (string memory) {
        return dataMapping[_key];
    }
    
    /**
     * @dev Add a number to array
     * @param _number The number to add
     */
    function addToArray(uint256 _number) public {
        numberArray.push(_number);
    }
    
    /**
     * @dev Get entire array
     * @return uint256[] The complete array
     */
    function getArray() public view returns (uint256[] memory) {
        return numberArray;
    }
    
    /**
     * @dev Get array length
     * @return uint256 The number of elements in array
     */
    function getArrayLength() public view returns (uint256) {
        return numberArray.length;
    }
    
    /**
     * @dev Add a person
     * @param _name Person's name
     * @param _age Person's age
     */
    function addPerson(string memory _name, uint256 _age) public {
        people[peopleCount] = Person(_name, _age, msg.sender);
        emit PersonAdded(peopleCount, _name, _age);
        peopleCount++;
    }
    
    /**
     * @dev Get person details
     * @param _id The person's ID
     * @return name The person's name
     * @return age The person's age
     * @return wallet The person's wallet address
     */
    function getPerson(uint256 _id) public view returns (
        string memory name,
        uint256 age,
        address wallet
    ) {
        Person memory p = people[_id];
        return (p.name, p.age, p.wallet);
    }
}

/*
 * DEPLOYMENT INSTRUCTIONS:
 * 
 * 1. Compile with Solidity 0.8.x
 * 2. Deploy to Sepolia testnet
 * 3. Test different storage functions:
 *    - storeNumber(42)
 *    - storeString("Blockchain")
 *    - storeBoolean(true)
 *    - storeAddress(your_address)
 *    - storeInMapping(1, "First Entry")
 *    - addToArray(100)
 *    - addPerson("Alice", 25)
 * 
 * LEARNING OBJECTIVES:
 * - Different data types (uint, string, bool, address)
 * - Mappings (key-value storage)
 * - Arrays (dynamic lists)
 * - Structs (complex data structures)
 * - Memory vs storage
 * - Getter functions
 * - Data retrieval patterns
 */
