// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title BlockNovaLabs
 * @notice A platform for registering projects, linking them, and tracking approvals for lab experiments or initiatives.
 */
contract BlockNovaLabs {

    address public admin;
    uint256 public projectCount;

    struct Project {
        uint256 id;
        address creator;
        string projectHash;
        string metadataURI;
        uint256 timestamp;
        bool approved;
        bool rejected;
        uint256[] linkedProjects;
    }

    mapping(uint256 => Project) public projects;
    mapping(address => uint256[]) public userProjects;

    event ProjectCreated(uint256 indexed id, address indexed creator, string projectHash, string metadataURI);
    event ProjectLinked(uint256 indexed fromId, uint256 indexed toId);
    event ProjectApproved(uint256 indexed id);
    event ProjectRejected(uint256 indexed id, string reason);
    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);

    modifier onlyAdmin() {
        require(msg.sender == admin, "BlockNovaLabs: NOT_ADMIN");
        _;
    }

    modifier projectExists(uint256 id) {
        require(id > 0 && id <= projectCount, "BlockNovaLabs: PROJECT_NOT_FOUND");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function createProject(string calldata projectHash, string calldata metadataURI) external returns (uint256) {
        require(bytes(projectHash).length > 0, "BlockNovaLabs: EMPTY_HASH");

        projectCount++;
        projects[projectCount] = Project({
            id: projectCount,
            creator: msg.sender,
            projectHash: projectHash,
            metadataURI: metadataURI,
            timestamp: block.timestamp,
            approved: false,
            rejected: false,
            linkedProjects: new uint256 
        });

        userProjects[msg.sender].push(projectCount);

        emit ProjectCreated(projectCount, msg.sender, projectHash, metadataURI);
        return projectCount;
    }

    function linkProjects(uint256 fromId, uint256 toId) external projectExists(fromId) projectExists(toId) {
        require(fromId != toId, "BlockNovaLabs: SELF_LINK");
        require(projects[fromId].creator == msg.sender || msg.sender == admin, "BlockNovaLabs: UNAUTHORIZED");

        projects[fromId].linkedProjects.push(toId);
        projects[toId].linkedProjects.push(fromId);

        emit ProjectLinked(fromId, toId);
    }

    function approveProject(uint256 id) external onlyAdmin projectExists(id) {
        Project storage p = projects[id];
        require(!p.approved && !p.rejected, "BlockNovaLabs: FINALIZED");
        p.approved = true;
        emit ProjectApproved(id);
    }

    function rejectProject(uint256 id, string calldata reason) external onlyAdmin projectExists(id) {
        Project storage p = projects[id];
        require(!p.approved && !p.rejected, "BlockNovaLabs: FINALIZED");
        p.rejected = true;
        emit ProjectRejected(id, reason);
    }

    function getProject(uint256 id) external view projectExists(id) returns (Project memory) {
        return projects[id];
    }

    function getUserProjects(address user) external view returns (uint256[] memory) {
        return userProjects[user];
    }

    function changeAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "BlockNovaLabs: ZERO_ADMIN");
        emit AdminChanged(admin, newAdmin);
        admin = newAdmin;
    }
}
