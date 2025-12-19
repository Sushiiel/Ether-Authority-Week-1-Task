// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title InternshipTaskStatus
 * @dev Track and manage internship tasks and progress on blockchain
 * @notice A real-world application to track your internship progress!
 */
contract InternshipTaskStatus {
    // Task status enum
    enum TaskStatus {
        NotStarted,
        InProgress,
        Completed,
        Verified,
        NeedsRevision
    }
    
    // Task structure
    struct Task {
        uint256 id;
        string title;
        string description;
        uint256 weekNumber;
        address assignedTo;
        TaskStatus status;
        uint256 createdAt;
        uint256 completedAt;
        uint256 verifiedAt;
        string submissionLink;
        string feedback;
        uint256 points;
    }
    
    // Intern profile
    struct Intern {
        address wallet;
        string name;
        string email;
        uint256 startDate;
        bool isActive;
        uint256 totalPoints;
        uint256 completedTasks;
    }
    
    // Mappings
    mapping(uint256 => Task) public tasks;
    mapping(address => Intern) public interns;
    mapping(address => uint256[]) public internTasks;
    mapping(uint256 => mapping(uint256 => uint256[])) public weekTasks; // week => intern => tasks
    
    // State variables
    uint256 public taskCount;
    address public mentor;
    address[] public internAddresses;
    
    // Events
    event InternRegistered(address indexed intern, string name);
    event TaskCreated(uint256 indexed taskId, string title, address indexed assignedTo, uint256 weekNumber);
    event TaskStatusUpdated(uint256 indexed taskId, TaskStatus newStatus);
    event TaskSubmitted(uint256 indexed taskId, string submissionLink);
    event TaskVerified(uint256 indexed taskId, uint256 points, string feedback);
    event PointsAwarded(address indexed intern, uint256 points);
    
    // Modifiers
    modifier onlyMentor() {
        require(msg.sender == mentor, "Only mentor can perform this");
        _;
    }
    
    modifier onlyIntern() {
        require(interns[msg.sender].isActive, "Not an active intern");
        _;
    }
    
    modifier taskExists(uint256 taskId) {
        require(taskId < taskCount, "Task does not exist");
        _;
    }
    
    modifier onlyTaskOwner(uint256 taskId) {
        require(tasks[taskId].assignedTo == msg.sender, "Not your task");
        _;
    }
    
    /**
     * @dev Constructor sets deployer as mentor
     */
    constructor() {
        mentor = msg.sender;
    }
    
    /**
     * @dev Register a new intern
     * @param _name Intern's name
     * @param _email Intern's email
     */
    function registerIntern(string memory _name, string memory _email) public {
        require(!interns[msg.sender].isActive, "Already registered");
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(bytes(_email).length > 0, "Email cannot be empty");
        
        interns[msg.sender] = Intern({
            wallet: msg.sender,
            name: _name,
            email: _email,
            startDate: block.timestamp,
            isActive: true,
            totalPoints: 0,
            completedTasks: 0
        });
        
        internAddresses.push(msg.sender);
        
        emit InternRegistered(msg.sender, _name);
    }
    
    /**
     * @dev Create a new task (mentor only)
     * @param _title Task title
     * @param _description Task description
     * @param _weekNumber Week number (1-12)
     * @param _assignedTo Intern's address
     * @param _points Points for completion
     */
    function createTask(
        string memory _title,
        string memory _description,
        uint256 _weekNumber,
        address _assignedTo,
        uint256 _points
    ) public onlyMentor returns (uint256) {
        require(interns[_assignedTo].isActive, "Not an active intern");
        require(bytes(_title).length > 0, "Title cannot be empty");
        require(_weekNumber >= 1 && _weekNumber <= 12, "Invalid week number");
        
        uint256 newTaskId = taskCount;
        
        tasks[newTaskId] = Task({
            id: newTaskId,
            title: _title,
            description: _description,
            weekNumber: _weekNumber,
            assignedTo: _assignedTo,
            status: TaskStatus.NotStarted,
            createdAt: block.timestamp,
            completedAt: 0,
            verifiedAt: 0,
            submissionLink: "",
            feedback: "",
            points: _points
        });
        
        internTasks[_assignedTo].push(newTaskId);
        weekTasks[_weekNumber][uint256(uint160(_assignedTo))].push(newTaskId);
        taskCount++;
        
        emit TaskCreated(newTaskId, _title, _assignedTo, _weekNumber);
        
        return newTaskId;
    }
    
    /**
     * @dev Start working on a task
     * @param _taskId The task ID
     */
    function startTask(uint256 _taskId)
        public
        onlyIntern
        taskExists(_taskId)
        onlyTaskOwner(_taskId)
    {
        require(tasks[_taskId].status == TaskStatus.NotStarted, "Task already started");
        tasks[_taskId].status = TaskStatus.InProgress;
        emit TaskStatusUpdated(_taskId, TaskStatus.InProgress);
    }
    
    /**
     * @dev Submit a completed task
     * @param _taskId The task ID
     * @param _submissionLink Link to submission (GitHub, etc.)
     */
    function submitTask(uint256 _taskId, string memory _submissionLink)
        public
        onlyIntern
        taskExists(_taskId)
        onlyTaskOwner(_taskId)
    {
        require(
            tasks[_taskId].status == TaskStatus.InProgress || 
            tasks[_taskId].status == TaskStatus.NeedsRevision,
            "Task not in progress"
        );
        require(bytes(_submissionLink).length > 0, "Submission link cannot be empty");
        
        tasks[_taskId].status = TaskStatus.Completed;
        tasks[_taskId].submissionLink = _submissionLink;
        tasks[_taskId].completedAt = block.timestamp;
        
        emit TaskSubmitted(_taskId, _submissionLink);
        emit TaskStatusUpdated(_taskId, TaskStatus.Completed);
    }
    
    /**
     * @dev Verify a submitted task (mentor only)
     * @param _taskId The task ID
     * @param _approved True to approve, false to request revision
     * @param _feedback Feedback from mentor
     */
    function verifyTask(uint256 _taskId, bool _approved, string memory _feedback)
        public
        onlyMentor
        taskExists(_taskId)
    {
        require(tasks[_taskId].status == TaskStatus.Completed, "Task not submitted");
        
        if (_approved) {
            tasks[_taskId].status = TaskStatus.Verified;
            tasks[_taskId].verifiedAt = block.timestamp;
            tasks[_taskId].feedback = _feedback;
            
            // Award points
            address intern = tasks[_taskId].assignedTo;
            uint256 points = tasks[_taskId].points;
            interns[intern].totalPoints += points;
            interns[intern].completedTasks++;
            
            emit TaskVerified(_taskId, points, _feedback);
            emit TaskStatusUpdated(_taskId, TaskStatus.Verified);
            emit PointsAwarded(intern, points);
        } else {
            tasks[_taskId].status = TaskStatus.NeedsRevision;
            tasks[_taskId].feedback = _feedback;
            emit TaskStatusUpdated(_taskId, TaskStatus.NeedsRevision);
        }
    }
    

    function getTask(uint256 _taskId)
        public
        view
        taskExists(_taskId)
        returns (
            uint256 id,
            string memory title,
            string memory description,
            uint256 weekNumber,
            address assignedTo,
            TaskStatus status,
            string memory submissionLink,
            string memory feedback,
            uint256 points
        )
    {
        Task memory t = tasks[_taskId];
        return (
            t.id,
            t.title,
            t.description,
            t.weekNumber,
            t.assignedTo,
            t.status,
            t.submissionLink,
            t.feedback,
            t.points
        );
    }
    
    /**
     * @dev Get all tasks for an intern
     * @param _intern The intern's address
     * @return uint256[] Array of task IDs
     */
    function getInternTasks(address _intern) public view returns (uint256[] memory) {
        return internTasks[_intern];
    }
    
 
    function getInternProgress(address _intern)
        public
        view
        returns (
            string memory name,
            uint256 totalPoints,
            uint256 completedTasks,
            uint256 totalTasks,
            bool isActive
        )
    {
        Intern memory intern = interns[_intern];
        return (
            intern.name,
            intern.totalPoints,
            intern.completedTasks,
            internTasks[_intern].length,
            intern.isActive
        );
    }
    
    /**
     * @dev Get completion percentage
     * @param _intern The intern's address
     * @return uint256 Percentage (0-100)
     */
    function getCompletionPercentage(address _intern) public view returns (uint256) {
        uint256 total = internTasks[_intern].length;
        if (total == 0) return 0;
        
        return (interns[_intern].completedTasks * 100) / total;
    }
    
    /**
     * @dev Get leaderboard (top 10 interns by points)
     * @return addresses Array of intern addresses
     * @return points Array of points
     */
    function getLeaderboard()
        public
        view
        returns (address[] memory addresses, uint256[] memory points)
    {
        uint256 length = internAddresses.length;
        addresses = new address[](length);
        points = new uint256[](length);
        
        for (uint256 i = 0; i < length; i++) {
            addresses[i] = internAddresses[i];
            points[i] = interns[internAddresses[i]].totalPoints;
        }
        
        // Simple bubble sort (not gas-efficient for large arrays, but ok for demo)
        for (uint256 i = 0; i < length; i++) {
            for (uint256 j = i + 1; j < length; j++) {
                if (points[j] > points[i]) {
                    (points[i], points[j]) = (points[j], points[i]);
                    (addresses[i], addresses[j]) = (addresses[j], addresses[i]);
                }
            }
        }
        
        return (addresses, points);
    }
}

/*
 * DEPLOYMENT INSTRUCTIONS:
 * 
 * 1. Deploy to Sepolia testnet (you become the mentor)
 * 2. Test workflow:
 *    a) FROM INTERN ACCOUNT:
 *       - registerIntern("Your Name", "your@email.com")
 *    b) FROM MENTOR ACCOUNT:
 *       - createTask("Setup Development Environment", "Install all tools", 1, intern_address, 10)
 *       - createTask("Deploy Hello World", "Deploy first contract", 1, intern_address, 15)
 *    c) FROM INTERN ACCOUNT:
 *       - startTask(0)
 *       - submitTask(0, "https://github.com/yourrepo")
 *    d) FROM MENTOR ACCOUNT:
 *       - verifyTask(0, true, "Great work!")
 *    e) CHECK PROGRESS:
 *       - getInternProgress(intern_address)
 *       - getCompletionPercentage(intern_address)
 *       - getLeaderboard()
 * 
 * LEARNING OBJECTIVES:
 * - Complete workflow management on blockchain
 * - Multi-role system (mentor/intern)
 * - State machine (task statuses)
 * - Progress tracking
 * - Point/reward system
 * - Leaderboard logic
 * 
 * PERFECT FOR:
 * - Tracking YOUR actual internship progress!
 * - Building a transparent portfolio
 * - Gamifying learning
 * - Proving completion on blockchain
 * - Creating immutable achievement records
 */
