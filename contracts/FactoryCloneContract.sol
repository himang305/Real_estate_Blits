// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./Shares.sol";
import "./Governor.sol";

/// @title Blitz Cloning Contract
/// @dev Contract create proxies of DAO Token and Governor contract
contract FactoryCloneContract {
    address public GovernorAddress;
    address public SharesAddress;
    address public owner;
    address[] public governorArray;
    address[] public clientArray;
    mapping(address => mapping(uint256 => bool)) public ApprovedDAO;

    event CreatedGovernor(address indexed, address indexed);
    event ChangeOrganiser(address newOrganiser);
    event ChangeGovernorAddress(address newDao);
    event ChangeTokenAddress(address newToken);

    /// @dev Initial Deployment of Token and Governor contract and storing their addresses for proxies creation
    constructor() {
        SharesAddress = address(new Shares());
        GovernorAddress = address(new Governor());
        owner = msg.sender;
    }

    /// @dev Modifier to check for Owner of contract
    modifier isOrganiser() {
        require(msg.sender == owner, "Only Owner Allowed");
        _;
    }

    /// @dev Function to assign new Owner
    /// @param _newOrganiser address of new owner
    function changeOrganiser(address _newOrganiser) external isOrganiser {
        if (_newOrganiser != address(0)) {
            owner = _newOrganiser;
            emit ChangeOrganiser(_newOrganiser);
        }
    }

    function approveDAO(address _client, uint256 _requestId) external isOrganiser{
        ApprovedDAO[_client][_requestId] = true;
    }

    // /// @dev Function to change base token contract address
    // /// @param _newToken address of new token contract
    // function changeTokenImplementation(address _newToken) external isOrganiser{
    //     if(_newToken != address(0))
    //     {
    //         erc20NonTransferable = _newToken;
    //         emit ChangeTokenAddress(_newToken);
    //     }
    // }

    // /// @dev Function to change base Governor contract address
    // /// @param _newDAO address of new Governor contract
    // function changeDAOImplementation(address _newDAO) external isOrganiser{
    //     if(_newDAO != address(0))
    //     {
    //         GovernorAddress = _newDAO;
    //         emit ChangeGovernorAddress(_newDAO);
    //     }
    // }

    /// @dev Function to create proxies and initialisation of Token and Governor contract
    /// @param tokenName Name of DAO Governance token
    /// @param _minDeposit Minimum deposit for DAO members
    /// @param _maxDeposit Maximum deposit for DAO members
    /// @param _tresuryAddress address of launched Gnosis treasury contract
    function createDAO(
        uint256 _reqId,
        string memory tokenName,
        string memory tokenSymbol,
        uint256 _shares,
        uint256 _price,
        uint256 _minDeposit,
        uint256 _maxDeposit,
        address _tresuryAddress,
        address _tokenAddress
    ) external {
        require(ApprovedDAO[msg.sender][_reqId], "Request Not Approved");
        address tokenAddress;
        tokenAddress = Clones.clone(SharesAddress);
        Shares(tokenAddress).initialize(tokenName, tokenSymbol, _shares);

        address GovernorAddresss = Clones.clone(GovernorAddress);
        Governor(payable(GovernorAddresss)).initialize(
            tokenAddress,
            _shares,
            _price,
            _minDeposit,
            _maxDeposit,
            _tresuryAddress,
            _tokenAddress,
            msg.sender
        );

        Shares(tokenAddress).initializerole(GovernorAddresss);

        governorArray.push(GovernorAddresss);
        clientArray.push(msg.sender);

        emit CreatedGovernor(tokenAddress, GovernorAddress);
    }
}
