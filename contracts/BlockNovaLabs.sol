// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title BlockNova Labs
 * @dev A decentralized registry where users can store and retrieve their data securely on-chain.
 */
contract Project {
    address public owner;

    struct UserData {
        string name;
        string dataHash;
    }

    mapping(address => UserData) private userRegistry;

    event DataRegistered(address indexed user, string name, string dataHash);
    event DataUpdated(address indexed user, string newDataHash);

    constructor() {
        owner = msg.sender;
    }

    /// @notice Register user data (e.g., IPFS hash, encrypted data)
    function registerData(string calldata name, string calldata dataHash) external {
        require(bytes(userRegistry[msg.sender].dataHash).length == 0, "User already registered");
        userRegistry[msg.sender] = UserData(name, dataHash);
        emit DataRegistered(msg.sender, name, dataHash);
    }

    /// @notice Update stored data for a user
    function updateData(string calldata newDataHash) external {
        require(bytes(userRegistry[msg.sender].dataHash).length > 0, "User not registered");
        userRegistry[msg.sender].dataHash = newDataHash;
        emit DataUpdated(msg.sender, newDataHash);
    }

    /// @notice Retrieve stored user data
    function getUserData(address user) external view returns (string memory, string memory) {
        UserData memory data = userRegistry[user];
        return (data.name, data.dataHash);
    }
}
