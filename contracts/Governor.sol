// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./Shares.sol";

/// @title StationX DAO Governor Proposal Contract
/// @dev Base Contract as a reference for DAO Governance contract proxies
contract Governor is Initializable, AccessControl {
    using SafeMath for uint256;

    address public governanceToken;
    uint256 shares;
    uint256 price;
    address public ownerAddress;
    uint256 public minDeposit;
    uint256 public maxDeposit;
    bool public saleStatus;
    bool public depositClosed;
    address public tresuryAddress;
    address public tokenAddress;
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");

    /// Proposal Parameters
    struct Proposal {
        string proposalHash;
        bool status;
        uint256 proposalId;
        bool[] options;
        uint256 quorum;
        uint256 threshold;
        uint256 day;
    }

    /// @dev array to store proposals
    Proposal[] public proposalArray;
    uint256 public proposalCounter = 0;

    /// @dev array to store members addresses
    address[] members;

    /* 
    Events Deposited,Start Deposit, Close Deposit, 
    Update Min and Max Deposit,Update Owner fee 
    */
    event Deposited(address indexed, uint256 value, uint256 amount);
    event StartDeposit(address indexed, uint256 timestamp);
    event CloseDeposit(address indexed, uint256 timestamp);
    event UpdateMinMaxDeposit(uint256, uint256);

    /// @dev onlyOwner modifier to allow only Owner access to functions
    modifier onlyOwner() {
        require(ownerAddress == msg.sender, "Only Owner");
        _;
    }

    /// @dev Initialize Function to initialize Governor contract
    /// @param _governanceToken Address of DAO Governance token
    /// @param _minDeposit Minimum deposit for DAO members
    /// @param _maxDeposit Maximum deposit for DAO members
    /// @param _ownerAddress Address of DAO owner
    /// @param _tresuryAddress address of launched Gnosis treasury contract
    /// @param _ownerAddress Address of DAO owner
    function initialize(
        address _governanceToken,
        uint256 _shares,
        uint256 _price,
        uint256 _minDeposit,
        uint256 _maxDeposit,
        address _tresuryAddress,
        address _tokenAddress,
        address _ownerAddress
    ) public initializer {
        governanceToken = _governanceToken;
        shares = _shares;
        price = _price;
        minDeposit = _minDeposit;
        maxDeposit = _maxDeposit;
        ownerAddress = _ownerAddress;
        tresuryAddress = _tresuryAddress;
        tokenAddress = _tokenAddress;
        _grantRole(EXECUTOR_ROLE, _ownerAddress);
        saleStatus = true;
    }

    /// @dev Function to update Token Address
    /// @param _tokenAddress New Token Address
    function updateTokenAddress(address _tokenAddress) external onlyOwner {
        tokenAddress = _tokenAddress;
    }

    /// @dev Function to update Minimum and Maximum deposits allowed by DAO members
    /// @param _minDeposit New minimum deposit requirement
    /// @param _maxDeposit New maximum deposit limit
    function updateminmaxdeposit(uint256 _minDeposit, uint256 _maxDeposit)
        external
        onlyOwner
    {
        if (_minDeposit > 0) {
            minDeposit = _minDeposit;
        }
        if (_maxDeposit > 0) {
            maxDeposit = _maxDeposit;
        }
        emit UpdateMinMaxDeposit(_minDeposit, _maxDeposit);
    }

    /// @dev Function to close deposit
    function closeDeposit() external onlyOwner {
        saleStatus = false;
        emit CloseDeposit(msg.sender, block.timestamp);
    }

    /// @dev Function to deposit USDC by DAO members and assign equivalent Governance token to members after owner fee
    /// @param _value USDC amount to deposit
    function buyShares(uint256 _value) external {
        require(saleStatus, "Sale Closed");
        require(_value >= minDeposit, "Amount less than minimum deposit");
        require(_value <= maxDeposit, "Amount greater than max deposit limit");

        members.push(msg.sender);        

            ERC20(tokenAddress).transferFrom(msg.sender, tresuryAddress, _value);
            uint256 _amount = calculateShares(_value);
            Shares(governanceToken).mintToken(msg.sender, _amount * 10**18);        

        emit Deposited(msg.sender, _value, _amount);
    }

    function calculateShares(uint256 _amount) internal returns(uint256){
        uint256 shareAmount = _amount / price;
        return shareAmount;
    }



    // Proposal Flow

    function createProposal(Proposal memory params)
        external
        onlyRole(EXECUTOR_ROLE)
    {
        proposalArray.push(params);
    }

    function submitProposal(uint256 _proposalId, bool[] calldata _results)
        external
        onlyRole(EXECUTOR_ROLE)
    {
        proposalArray[_proposalId].options = _results;
    }

    function getProposal(uint256 _proposalId)
        external
        view
        returns(Proposal memory _proposal)
    {
       return  proposalArray[_proposalId];
    }

    function assignExecutorRole(address _user)
        internal
        onlyRole(EXECUTOR_ROLE)
    {
            _grantRole(EXECUTOR_ROLE, _user);        
    }

    // /// @dev Function to give Governance details
    // /// @return  closeDate, minDeposit, maxDeposit, members count, quorum
    // function getGovernorDetails()
    //     external
    //     view
    //     returns (
    //         uint256,
    //         uint256,
    //         uint256,
    //         uint256
    //     )
    // {
    //     return (
    //         minDeposit,
    //         maxDeposit,
    //         quorum,
    //         members.length
    //     );
    // }

    // /// @dev Function to give Members details
    // /// @return  members addresses list
    function getMembers() external view returns (address[] memory) {
        return members;
    }
}
