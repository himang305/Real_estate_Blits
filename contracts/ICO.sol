// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./BlitsToken.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./TimeLock.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title ICO Contract for Blits Token
 * @dev For ICO round
 */
contract ICO is ReentrancyGuard{
    using SafeMath for uint256;

    BlitsToken public tokenContract;
    TimeLock public timelockContract;

    /// @dev Address where the ICO and Presales funds are collected
    address public reserveWallet;
    /// @dev Address of ICO admin to start different phases of ICOs and Presale
    address public icoAdmin;

    /// @dev Status of the ICO / Presale phase
    bool public saleActive;
    /// @dev Token Price in native token
    uint256 public tokenPrice;
    /// @dev Minimum purchase amount for investors during ICO / Presale of Volt token
    uint256 public investorMinCap;
    /// @dev Amount of wei raised till time
    uint256 public weiRaised;
    /// @dev Max token to be sold
    uint256 public targetAmount;

    /// @dev Mapping of contribution of investors
    mapping(address => uint256) public contributions;

    event TokenPurchase(address purchaser, uint256 amount, uint256 value);
    event ChangeAdmin(address);
    /**
     * @dev Constructor Function
     */
    constructor(BlitsToken _tokenContract, TimeLock _timelockContract) {
        investorMinCap = 10 ** 18;
        reserveWallet = address(0);
        timelockContract = _timelockContract;
        tokenContract = _tokenContract;
        icoAdmin = msg.sender;
        tokenPrice = 10**18;
        targetAmount = 50000000 * 10 ** 18;
    }

    /// @dev Modifier to allow access to ICO Admin only
    modifier onlyIcoAdmin() {
        require(msg.sender == icoAdmin, "Only Admin Allowed");
        _;
    }

    /// @dev Modifier to allow Token access in ICO active phases only
    modifier onlyWhileOpen() {
        require(saleActive, "Sale Closed");
        _;
    }

    /// @dev Receive function to receive funds send to contract directly
    receive() external payable {
        buyblitzFromNative(msg.sender);
    }

    /// @dev Fallback function to directly initiate token sale on BNB payment
    fallback() external payable {
        buyblitzFromNative(msg.sender);
    }

    /**
     * @dev Function to change sale status
     * @param status New sale status
     */
    function changeSaleStatus(bool status) external onlyIcoAdmin {
        saleActive = status;
    }

    /**
     * @dev Function to change target
     * @param _target New target
     */
    function changeTarget(uint256 _target) external onlyIcoAdmin {
        targetAmount = _target;
    }

    /**
     * @dev Function to change token price
     * @param _price New price of token
     */
    function changePrice(uint256 _price) external onlyIcoAdmin {
        tokenPrice = _price;
    }

    /**
     * @dev Function to change ICO admin
     * @param _newAdmin Address of new ICO Admin
     */
    function changeIcoAdmin(address _newAdmin) external onlyIcoAdmin {
        require(_newAdmin != address(0),"Invalid address");
        icoAdmin = _newAdmin;
        emit ChangeAdmin (_newAdmin);
    }

    /**
     * @dev Function to buy Volt token through BNB token
     * @param _beneficiary Address of investor
     */
    function buyblitzFromNative(address _beneficiary) public payable onlyWhileOpen nonReentrant{
        uint256 weiAmount = msg.value;
        require(weiAmount >= tokenPrice,"Invalid Value");
        payable(reserveWallet).transfer(weiAmount);
        _preValidatePurchase(_beneficiary);

        // calculate token amount to be created
        uint256 tokens = weiAmount.mul(10 ** 18).div(tokenPrice);

        _processPurchase(_beneficiary, tokens);
        _updatePurchasingState(_beneficiary, tokens);
        emit TokenPurchase(msg.sender, weiAmount, tokens);

    }

    /**
     * @dev Function to check benficiary address
     * @param _beneficiary Address of investor
     */
    function _preValidatePurchase(address _beneficiary) internal pure {
        require(_beneficiary != address(0));
    }

    /**
     * @dev Function to mint and send token to vesting contract in name of investor
     * @param _beneficiary Address performing the token purchase
     * @param _tokenAmount Number of tokens to be emitted
     */
    function _deliverTokens(address _beneficiary, uint256 _tokenAmount)
        internal
    {
        tokenContract.mint(address(timelockContract), _tokenAmount);
        timelockContract.initiateTokenLock(
            _beneficiary,
            _tokenAmount
        );
    }

    /**
     * @dev Executed when a purchase has been validated and is ready to be executed.
     * @param _beneficiary Address receiving the tokens
     * @param _tokenAmount Number of tokens to be purchased
     */
    function _processPurchase(address _beneficiary, uint256 _tokenAmount)
        internal
    {
        require(_tokenAmount >= investorMinCap, "Fail minimum investment");
        require(weiRaised.add(_tokenAmount) <= targetAmount, "Exceeded Target");
        weiRaised = weiRaised.add(_tokenAmount);
        _deliverTokens(_beneficiary, _tokenAmount);
    }

    /**
     * @dev Function to update investor contributions
     * @param _beneficiary Address receiving the tokens
     * @param _weiAmount Value in wei involved in the purchase
     */
    function _updatePurchasingState(address _beneficiary, uint256 _weiAmount)
        internal
    {
        contributions[_beneficiary] = contributions[_beneficiary].add(
            _weiAmount
        );
    }
}
