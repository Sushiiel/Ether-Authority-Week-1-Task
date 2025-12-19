// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title StudentRegistration
 * @dev A decentralized student registration system
 * @notice Register students and manage their academic records on blockchain
 */
contract StudentRegistration {
    // Student structure
    struct Student {
        uint256 studentId;
        string name;
        string email;
        uint256 age;
        string course;
        address wallet;
        uint256 enrollmentDate;
        bool isEnrolled;
        uint256[] grades;
    }
    
    // Mappings
    mapping(uint256 => Student) public students;
    mapping(address => uint256) public walletToStudentId;
    mapping(string => bool) public emailUsed;
    
    // State variables
    uint256 public totalStudents;
    address public admin;
    
    // Events
    event StudentRegistered(uint256 indexed studentId, string name, string email, address wallet);
    event StudentUpdated(uint256 indexed studentId, string name);
    event GradeAdded(uint256 indexed studentId, uint256 grade);
    event StudentUnenrolled(uint256 indexed studentId);
    event StudentReenrolled(uint256 indexed studentId);
    
    // Modifiers
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }
    
    modifier studentExists(uint256 studentId) {
        require(studentId < totalStudents, "Student does not exist");
        _;
    }
    
    modifier onlyStudentOrAdmin(uint256 studentId) {
        require(
            msg.sender == admin || students[studentId].wallet == msg.sender,
            "Not authorized"
        );
        _;
    }
    
    /**
     * @dev Constructor sets deployer as admin
     */
    constructor() {
        admin = msg.sender;
    }
    
    /**
     * @dev Register a new student
     * @param _name Student's name
     * @param _email Student's email
     * @param _age Student's age
     * @param _course Course enrolled in
     * @return uint256 The student ID
     */
    function registerStudent(
        string memory _name,
        string memory _email,
        uint256 _age,
        string memory _course
    ) public returns (uint256) {
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(bytes(_email).length > 0, "Email cannot be empty");
        require(_age >= 16 && _age <= 100, "Invalid age");
        require(bytes(_course).length > 0, "Course cannot be empty");
        require(!emailUsed[_email], "Email already registered");
        require(walletToStudentId[msg.sender] == 0 || msg.sender == admin, "Wallet already registered");
        
        uint256 newStudentId = totalStudents;
        
        Student storage newStudent = students[newStudentId];
        newStudent.studentId = newStudentId;
        newStudent.name = _name;
        newStudent.email = _email;
        newStudent.age = _age;
        newStudent.course = _course;
        newStudent.wallet = msg.sender;
        newStudent.enrollmentDate = block.timestamp;
        newStudent.isEnrolled = true;
        
        walletToStudentId[msg.sender] = newStudentId;
        emailUsed[_email] = true;
        totalStudents++;
        
        emit StudentRegistered(newStudentId, _name, _email, msg.sender);
        
        return newStudentId;
    }
    
    /**
     * @dev Update student information
     * @param _studentId The student's ID
     * @param _name New name
     * @param _course New course
     */
    function updateStudent(
        uint256 _studentId,
        string memory _name,
        string memory _course
    ) public studentExists(_studentId) onlyStudentOrAdmin(_studentId) {
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(bytes(_course).length > 0, "Course cannot be empty");
        
        students[_studentId].name = _name;
        students[_studentId].course = _course;
        
        emit StudentUpdated(_studentId, _name);
    }
    
    /**
     * @dev Add a grade for a student
     * @param _studentId The student's ID
     * @param _grade The grade to add (0-100)
     */
    function addGrade(uint256 _studentId, uint256 _grade)
        public
        onlyAdmin
        studentExists(_studentId)
    {
        require(_grade <= 100, "Grade must be between 0 and 100");
        require(students[_studentId].isEnrolled, "Student not enrolled");
        
        students[_studentId].grades.push(_grade);
        
        emit GradeAdded(_studentId, _grade);
    }
    

    function getStudent(uint256 _studentId)
        public
        view
        studentExists(_studentId)
        returns (
            uint256 studentId,
            string memory name,
            string memory email,
            uint256 age,
            string memory course,
            address wallet,
            uint256 enrollmentDate,
            bool isEnrolled
        )
    {
        Student memory s = students[_studentId];
        return (
            s.studentId,
            s.name,
            s.email,
            s.age,
            s.course,
            s.wallet,
            s.enrollmentDate,
            s.isEnrolled
        );
    }
    
    /**
     * @dev Get all grades for a student
     * @param _studentId The student's ID
     * @return uint256[] Array of grades
     */
    function getGrades(uint256 _studentId)
        public
        view
        studentExists(_studentId)
        returns (uint256[] memory)
    {
        return students[_studentId].grades;
    }
    
    /**
     * @dev Calculate average grade for a student
     * @param _studentId The student's ID
     * @return uint256 Average grade
     */
    function getAverageGrade(uint256 _studentId)
        public
        view
        studentExists(_studentId)
        returns (uint256)
    {
        uint256[] memory grades = students[_studentId].grades;
        require(grades.length > 0, "No grades available");
        
        uint256 sum = 0;
        for (uint256 i = 0; i < grades.length; i++) {
            sum += grades[i];
        }
        
        return sum / grades.length;
    }
    
    /**
     * @dev Get student ID by wallet address
     * @param _wallet The wallet address
     * @return uint256 The student ID
     */
    function getStudentIdByWallet(address _wallet) public view returns (uint256) {
        return walletToStudentId[_wallet];
    }
    
    /**
     * @dev Unenroll a student
     * @param _studentId The student's ID
     */
    function unenrollStudent(uint256 _studentId)
        public
        onlyAdmin
        studentExists(_studentId)
    {
        require(students[_studentId].isEnrolled, "Student already unenrolled");
        students[_studentId].isEnrolled = false;
        emit StudentUnenrolled(_studentId);
    }
    
    /**
     * @dev Re-enroll a student
     * @param _studentId The student's ID
     */
    function reenrollStudent(uint256 _studentId)
        public
        onlyAdmin
        studentExists(_studentId)
    {
        require(!students[_studentId].isEnrolled, "Student already enrolled");
        students[_studentId].isEnrolled = true;
        emit StudentReenrolled(_studentId);
    }
    
    /**
     * @dev Get total number of enrolled students
     * @return uint256 Count of enrolled students
     */
    function getEnrolledCount() public view returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 0; i < totalStudents; i++) {
            if (students[i].isEnrolled) {
                count++;
            }
        }
        return count;
    }
}

/*
 * DEPLOYMENT INSTRUCTIONS:
 * 
 * 1. Deploy to Sepolia testnet
 * 2. You will be the admin
 * 3. Test workflow:
 *    a) registerStudent("Alice", "alice@email.com", 20, "Computer Science")
 *    b) registerStudent("Bob", "bob@email.com", 22, "Mathematics")
 *    c) getStudent(0) - view Alice's details
 *    d) addGrade(0, 85) - add grade for Alice (as admin)
 *    e) addGrade(0, 90)
 *    f) getGrades(0) - view all grades
 *    g) getAverageGrade(0) - calculate average
 *    h) updateStudent(0, "Alice Smith", "Computer Science")
 *    i) getEnrolledCount()
 * 
 * LEARNING OBJECTIVES:
 * - Real-world application design
 * - CRUD operations on blockchain
 * - Role-based access (admin vs student)
 * - Data validation
 * - Calculations on-chain
 * - Array operations
 * - Complex data structures
 * 
 * USE CASES:
 * - University/school registration systems
 * - Academic credential verification
 * - Transparent grade management
 * - Immutable academic records
 * - Decentralized education platforms
 */
