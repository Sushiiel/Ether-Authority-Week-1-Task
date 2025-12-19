// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SimpleVoting
 * @dev A decentralized voting system for proposals
 * @notice Create proposals, vote, and view results transparently on blockchain
 */
contract SimpleVoting {
    // Proposal structure
    struct Proposal {
        uint256 id;
        string title;
        string description;
        address proposer;
        uint256 yesVotes;
        uint256 noVotes;
        uint256 createdAt;
        uint256 votingDeadline;
        bool isActive;
        mapping(address => bool) hasVoted;
    }
    
    // State variables
    mapping(uint256 => Proposal) public proposals;
    uint256 public proposalCount;
    address public admin;
    uint256 public defaultVotingPeriod = 7 days;
    
    // Events
    event ProposalCreated(
        uint256 indexed proposalId,
        string title,
        address indexed proposer,
        uint256 deadline
    );
    event VoteCast(
        uint256 indexed proposalId,
        address indexed voter,
        bool vote
    );
    event ProposalClosed(uint256 indexed proposalId);
    
    // Modifiers
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this");
        _;
    }
    
    modifier proposalExists(uint256 proposalId) {
        require(proposalId < proposalCount, "Proposal does not exist");
        _;
    }
    
    modifier votingOpen(uint256 proposalId) {
        require(proposals[proposalId].isActive, "Voting is closed");
        require(block.timestamp < proposals[proposalId].votingDeadline, "Voting period ended");
        _;
    }
    
    /**
     * @dev Constructor sets deployer as admin
     */
    constructor() {
        admin = msg.sender;
    }
    
    /**
     * @dev Create a new proposal
     * @param _title Proposal title
     * @param _description Proposal description
     * @param _votingPeriodDays Voting period in days (0 = use default)
     * @return uint256 The proposal ID
     */
    function createProposal(
        string memory _title,
        string memory _description,
        uint256 _votingPeriodDays
    ) public returns (uint256) {
        require(bytes(_title).length > 0, "Title cannot be empty");
        require(bytes(_description).length > 0, "Description cannot be empty");
        
        uint256 votingPeriod = _votingPeriodDays > 0 
            ? _votingPeriodDays * 1 days 
            : defaultVotingPeriod;
        
        uint256 newProposalId = proposalCount;
        Proposal storage newProposal = proposals[newProposalId];
        
        newProposal.id = newProposalId;
        newProposal.title = _title;
        newProposal.description = _description;
        newProposal.proposer = msg.sender;
        newProposal.yesVotes = 0;
        newProposal.noVotes = 0;
        newProposal.createdAt = block.timestamp;
        newProposal.votingDeadline = block.timestamp + votingPeriod;
        newProposal.isActive = true;
        
        proposalCount++;
        
        emit ProposalCreated(
            newProposalId,
            _title,
            msg.sender,
            newProposal.votingDeadline
        );
        
        return newProposalId;
    }
    
    /**
     * @dev Cast a vote on a proposal
     * @param _proposalId The proposal ID
     * @param _vote True for yes, false for no
     */
    function vote(uint256 _proposalId, bool _vote)
        public
        proposalExists(_proposalId)
        votingOpen(_proposalId)
    {
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.hasVoted[msg.sender], "Already voted");
        
        proposal.hasVoted[msg.sender] = true;
        
        if (_vote) {
            proposal.yesVotes++;
        } else {
            proposal.noVotes++;
        }
        
        emit VoteCast(_proposalId, msg.sender, _vote);
    }
    
    /**
     * @dev Close a proposal manually (admin only)
     * @param _proposalId The proposal ID
     */
    function closeProposal(uint256 _proposalId)
        public
        onlyAdmin
        proposalExists(_proposalId)
    {
        require(proposals[_proposalId].isActive, "Proposal already closed");
        proposals[_proposalId].isActive = false;
        emit ProposalClosed(_proposalId);
    }
    

    function getProposal(uint256 _proposalId)
        public
        view
        proposalExists(_proposalId)
        returns (
            uint256 id,
            string memory title,
            string memory description,
            address proposer,
            uint256 yesVotes,
            uint256 noVotes,
            uint256 createdAt,
            uint256 votingDeadline,
            bool isActive
        )
    {
        Proposal storage p = proposals[_proposalId];
        return (
            p.id,
            p.title,
            p.description,
            p.proposer,
            p.yesVotes,
            p.noVotes,
            p.createdAt,
            p.votingDeadline,
            p.isActive
        );
    }
    
    /**
     * @dev Check if an address has voted on a proposal
     * @param _proposalId The proposal ID
     * @param _voter The voter's address
     * @return bool True if voted
     */
    function hasVoted(uint256 _proposalId, address _voter)
        public
        view
        proposalExists(_proposalId)
        returns (bool)
    {
        return proposals[_proposalId].hasVoted[_voter];
    }
    
    /**
     * @dev Get voting results
     * @param _proposalId The proposal ID
     * @return yesVotes Number of yes votes
     * @return noVotes Number of no votes
     * @return totalVotes Total number of votes
     */
    function getResults(uint256 _proposalId)
        public
        view
        proposalExists(_proposalId)
        returns (uint256 yesVotes, uint256 noVotes, uint256 totalVotes)
    {
        Proposal storage p = proposals[_proposalId];
        return (p.yesVotes, p.noVotes, p.yesVotes + p.noVotes);
    }
    
    /**
     * @dev Get proposal status
     * @param _proposalId The proposal ID
     * @return status "Passed", "Rejected", "Active", or "Ended"
     */
    function getProposalStatus(uint256 _proposalId)
        public
        view
        proposalExists(_proposalId)
        returns (string memory status)
    {
        Proposal storage p = proposals[_proposalId];
        
        if (p.isActive && block.timestamp < p.votingDeadline) {
            return "Active";
        }
        
        if (p.yesVotes > p.noVotes) {
            return "Passed";
        } else if (p.noVotes > p.yesVotes) {
            return "Rejected";
        } else {
            return "Tied";
        }
    }
    
    /**
     * @dev Get time remaining for voting
     * @param _proposalId The proposal ID
     * @return uint256 Seconds remaining (0 if ended)
     */
    function getTimeRemaining(uint256 _proposalId)
        public
        view
        proposalExists(_proposalId)
        returns (uint256)
    {
        Proposal storage p = proposals[_proposalId];
        if (block.timestamp >= p.votingDeadline) {
            return 0;
        }
        return p.votingDeadline - block.timestamp;
    }
    
    /**
     * @dev Set default voting period (admin only)
     * @param _days Number of days
     */
    function setDefaultVotingPeriod(uint256 _days) public onlyAdmin {
        require(_days > 0, "Period must be greater than 0");
        defaultVotingPeriod = _days * 1 days;
    }
    
    /**
     * @dev Get all active proposals count
     * @return uint256 Number of active proposals
     */
    function getActiveProposalsCount() public view returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 0; i < proposalCount; i++) {
            if (proposals[i].isActive && block.timestamp < proposals[i].votingDeadline) {
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
 *    a) createProposal("Budget Increase", "Increase project budget by 20%", 3)
 *    b) createProposal("New Feature", "Add social media integration", 0)
 *    c) getProposal(0) - view proposal details
 *    d) vote(0, true) - vote yes on proposal 0
 *    e) Switch to different account and vote(0, false)
 *    f) getResults(0) - check vote counts
 *    g) getProposalStatus(0) - check if passed/rejected
 *    h) hasVoted(0, your_address) - check if you voted
 *    i) getTimeRemaining(0) - check time left
 * 
 * LEARNING OBJECTIVES:
 * - DAO (Decentralized Autonomous Organization) basics
 * - Voting mechanisms on blockchain
 * - Time-based logic (deadlines)
 * - Status management
 * - Preventing double voting
 * - Transparent voting systems
 * 
 * USE CASES:
 * - DAO governance
 * - Community decision making
 * - Transparent elections
 * - Project funding decisions
 * - Protocol upgrades voting
 * - Token holder voting
 * 
 * SECURITY NOTES:
 * - One address = one vote (can be extended to token-weighted)
 * - Cannot vote twice
 * - Results are transparent
 * - Voting period is enforced
 */
