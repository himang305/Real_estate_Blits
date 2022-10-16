// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./TeamTimeLock.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./BlitsToken.sol";

/**
 * @title Vesting Contract
 * @notice Used to assign and lock token for Internal Teams in TimeLock Contract
 * as per Vesting Schedule
 */
contract Vesting {
    using SafeMath for uint256;
    BlitsToken public blitzContract;
    TeamTimeLock public timelockContract;

    /// Token supply after the ICO assumed as 100% for token share of internal teams
    uint256 totalTokenSuppliedTillIco;
    /// Wallet Addresses of Internal teams of Voltreum
    address researchFund;
    address marketingFund;
    address legalTeamFund;
    address teamFund;

    address public owner;

    constructor(
        BlitsToken _blitzContract,
        TeamTimeLock _timelockContract
    ) {
        owner = msg.sender;
        researchFund = address(0x9995e2d09adBaB13c81Da69701Ac72CF31f91f7e);
        marketingFund = address(0x03D3155cD23BbC4801AfDBD4a234788B5D856A50);
        legalTeamFund = address(0x427bED7CA25675447148D9dF5bA639d353dba8bF);
        teamFund = address(0xa4BC154619c93f50268fcc3bA5d716c3B506d1d3);
        blitzContract = _blitzContract;
        timelockContract = _timelockContract;
    }

    /**
     * @dev Function to execute token vesting process to Internal Teams
     */
    function doVesting() public {
        require(msg.sender == owner, " Only Owner allowed");

        uint256 researchAmount = 50000000 * 10 ** 18;
        timelockContract.initiateTokenLock(
            researchFund,8,1,
            researchAmount
        );
        blitzContract.mint(address(timelockContract), researchAmount);

        uint256 marketAmount = 120000000 * 10 ** 18;
        timelockContract.initiateTokenLock(
            marketingFund,10,1,
            marketAmount
        );
        blitzContract.mint(address(timelockContract), marketAmount);

        uint256 legalAmount = 20000000 * 10 ** 18;
        timelockContract.initiateTokenLock(
            legalTeamFund,4,1,
            legalAmount
        );
        blitzContract.mint(address(timelockContract), legalAmount);

        uint256 securityAmount = 100000000 * 10 ** 18;
        timelockContract.initiateTokenLock(
            teamFund,12,12,
            securityAmount
        );
        blitzContract.mint(address(timelockContract), securityAmount);

    }
}
