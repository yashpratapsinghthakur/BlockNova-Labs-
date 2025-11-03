// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title BlockNova Labs
 * @notice A decentralized R&D collaboration contract where researchers can submit projects,
 *         get community funding, and mark them as completed upon success.
 */
contract Project {
    address public admin;
    uint256 public projectCount;

    struct ResearchProject {
        uint256 id;
        address creator;
        string title;
        string description;
        uint256 fundsRaised;
        uint256 goalAmount;
        bool completed;
    }

    mapping(uint256 => ResearchProject) public researchProjects;
    mapping(uint256 => mapping(address => uint256)) public contributions;

    event ProjectCreated(uint256 indexed id, address indexed creator, string title, uint256 goalAmount);
    event Funded(uint256 indexed id, address indexed contributor, uint256 amount);
    event ProjectCompleted(uint256 indexed id, address indexed creator);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    /**
     * @notice Create a new research project for funding
     * @param _title Title of the project
     * @param _description Short description
     * @param _goalAmount Funding goal in wei
     */
    function createResearchProject(string memory _title, string memory _description, uint256 _goalAmount) external {
        require(bytes(_title).length > 0, "Title required");
        require(bytes(_description).length > 0, "Description required");
        require(_goalAmount > 0, "Goal amount must be greater than zero");

        projectCount++;
        researchProjects[projectCount] = ResearchProject(
            projectCount,
            msg.sender,
            _title,
            _description,
            0,
            _goalAmount,
            false
        );

        emit ProjectCreated(projectCount, msg.sender, _title, _goalAmount);
    }

    /**
     * @notice Fund a research project
     * @param _id Project ID
     */
    function fundProject(uint256 _id) external payable {
        ResearchProject storage rp = researchProjects[_id];
        require(_id > 0 && _id <= projectCount, "Invalid project ID");
        require(!rp.completed, "Project already completed");
        require(msg.value > 0, "Funding amount must be greater than zero");

        rp.fundsRaised += msg.value;
        contributions[_id][msg.sender] += msg.value;

        emit Funded(_id, msg.sender, msg.value);
    }

    /**
     * @notice Mark a research project as completed (only admin)
     * @param _id Project ID
     */
    function markProjectCompleted(uint256 _id) external onlyAdmin {
        ResearchProject storage rp = researchProjects[_id];
        require(_id > 0 && _id <= projectCount, "Invalid project ID");
        require(!rp.completed, "Already marked as completed");

        rp.completed = true;
        payable(rp.creator).transfer(rp.fundsRaised);

        emit ProjectCompleted(_id, rp.creator);
    }

    /**
     * @notice Get research project details
     * @param _id Project ID
     */
    function getResearchProject(uint256 _id) external view returns (ResearchProject memory) {
        requi
