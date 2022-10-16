// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./BlitsToken.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
 * @title TokenTimelock
 * @dev TokenTimelock is a token holder contract that will allow a
 * beneficiaries to extract the tokens after a given release schedule
 * 13 months vesting schedule: After 1 month lock, release 1/12 amount after each 30 days
 */
contract TeamTimeLock {
    using SafeMath for uint256;

    BlitsToken public blitsContract;

    address public admin;
    /// @dev Address of contract who can lock token: ICO and Vesting
    address public lockers;

    /// @dev Mapping to track release time of each month
    mapping(address => uint256) public releaseTime;
    /// @dev Mapping to track locked amount of each investor
    mapping(address => uint256) public lockAmount;
    /// @dev Mapping to track locked amount to be released each month
    mapping(address => uint256) public lockAmountPerPhase;

    event InitiateLock(address user, uint256 value, uint256, uint256);
    event ReleaseLock(address user, uint256 value);

    /**
     * @dev Constructor Function to add Volt Token Address
     */
    constructor(BlitsToken _token) {
        blitsContract = _token;
        admin = msg.sender;
    }

    /// @dev Modifier to allow access to Lockers only
    modifier onlyLockers() {
        require(msg.sender == lockers, "Only Lockers Allowed");
        _;
    }

    /**
     * @dev Function to set Lockers
     * @param  _lockers Address of lockers
     */
    function changeLockers(address _lockers) external {
        require(msg.sender == admin, "Only Admin allowed");
        lockers = _lockers;
    }

    /**
     * @dev Function to set new admin
     * @param  _admin Address of lockers
     */
    function changeAdmin(address _admin) external {
        require(msg.sender == admin, "Only Admin allowed");
        admin = _admin;
    }

    /**
     * @dev Function to initiate token lock process
     * @param _beneficiary Owner of the locked tokens
     * @param _amount The amount of tokens to lock
     */
    function initiateTokenLock(address _beneficiary, uint256 _months,uint256 _cliff, uint256 _amount)
        public
        onlyLockers
    {
        lockAmount[_beneficiary] = lockAmount[_beneficiary] + _amount;
        lockAmountPerPhase[_beneficiary] = lockAmount[_beneficiary].div(_months);
        releaseTime[_beneficiary] = block.timestamp + 86400 * 30 * _cliff;
        emit InitiateLock(_beneficiary, _months, _cliff, _amount);
    }

    /**
     * @dev Function to release lock token according to vesting schedule
     */
    function releaseTokens() public {
        require(
            block.timestamp >= releaseTime[msg.sender],
            "Check Release Time"
        );
        releaseTime[msg.sender] = releaseTime[msg.sender] + 86400 * 30;

        if (lockAmountPerPhase[msg.sender] <= lockAmount[msg.sender]) {
            lockAmount[msg.sender] =
                lockAmount[msg.sender] -
                lockAmountPerPhase[msg.sender];

            blitsContract.transfer(msg.sender, lockAmountPerPhase[msg.sender]);
            emit ReleaseLock(msg.sender, lockAmountPerPhase[msg.sender]);
        }
    }
    
}
