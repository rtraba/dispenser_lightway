// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "./DispensedToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract Dispenser is Ownable{

    using SafeMath for uint256;
    // deployment time, used for calculate current period and clims which limits to apply
    uint public startTime;
    // threshold after which there is no monetary policy and all founds are going to be released to beneficiary
    uint public stopThresholdLimit;
    uint public maxMonthlyLimit;
    // beneficiary addresss is the onlyone who can be receipt of transfers from this contract
    address public beneficiary;
    // finalized flag, deactivates climingfunds after finilized DIspensingPeriod
    bool public finalized;
    // DispensedToken is an ERC20Capped token, which total supply is managed by this contract
    DispensedToken public dispensedToken;
    // each time beneficiare claimFunds, it updates lastClaimTime and allowanceDeacumulator
    uint public lastClaimTime;
    uint public allowanceDeacumulator;
    uint public lastLimit;

    // events
    event dispenserPeriodFinalized (address beneficiary, uint reamainingAmount);
    event dispenserPeriodFinalizedByOwner (uint remainingAmount);
    event fundsClaimed(uint amount);
    event newBeneficiary (address newBeneficiary);
    event allowanceDeacumulatorRestarted (uint currentTime);
    event toMuchCalimingFunds (uint _amount);

    constructor(uint _cap, uint _stopThresholdLimit, address _beneficiary, uint _maxMonthlyLimit) public{
        dispensedToken = new DispensedToken(_cap);
        startTime = now;
        stopThresholdLimit = _stopThresholdLimit;
        maxMonthlyLimit = _maxMonthlyLimit;
        finalized = false;
        lastClaimTime = startTime;
        beneficiary = _beneficiary;
        allowanceDeacumulator = 0;
        lastLimit = getMonthlyLimit(startTime);
    }
    // caluclates years of 360 days to be consistent when calculating months of 30 days
    function getMonthlyLimit(uint givenTime) public view returns (uint){
        uint transcurredYears = ((((givenTime.sub(startTime)).div(60)).div(60)).div(24)).div(360);
        uint period = transcurredYears.div(4);
        uint monthLimit = maxMonthlyLimit;
        if (period < 1) {
            // here transcurreYears could be 0,1,2 or 3
            if (transcurredYears < 2) {
                if (transcurredYears  < 1) {
                    monthLimit = maxMonthlyLimit.div(10);
                }
                else{
                    monthLimit = maxMonthlyLimit.div(4);
                }
            }
            else{
                if (transcurredYears < 3){
                    monthLimit = maxMonthlyLimit.div(2);
                }
            }
        }
        else {
            uint divideBy = 2 ** period;
            monthLimit = monthLimit.div(divideBy);
        }
       return monthLimit;
    }

    // asume months of 30 days, consistent with years of 360 days
     function getMonthsSinceStartTime (uint _givenTime) public view returns (uint) {
        uint passedSeconds = (_givenTime.sub(startTime));
        uint passedMonths = (((passedSeconds.div(60)).div(60)).div(24)).div(30);
        return passedMonths;
    }
    //calculates how much remains to be claimed for current month, taking in account previous claimFunds performed this month
    function getCurrentMonthUnclaimedFund() public view returns (uint){
         uint nowTime = now;
         uint currentLimit = getMonthlyLimit(nowTime);
         if (isSameMonthThanLastClaim(nowTime)){
            currentLimit = currentLimit.sub(allowanceDeacumulator);
        }
        return currentLimit;
    }
    // claimFunds assume than_amount is pased as interger, that's why it multiplies by 10 ** decimals after calling DSP transfer.
    function claimFunds (uint _amount) public notFinalized {
        require(beneficiary == msg.sender, 'Only accepted beneficiary addredss are allowed to claim founds');

        // first check if allowanceDeacumulator needs to be restarted before using it
        uint nowTime = now;
        if (!isSameMonthThanLastClaim(nowTime)){
            allowanceDeacumulator = 0;
            lastLimit = getMonthlyLimit(nowTime);
            emit allowanceDeacumulatorRestarted (nowTime);
        }
        // check if dispenser must be finilized
        if (getMonthlyLimit(nowTime) <= stopThresholdLimit) {
            finalize();
            return;
        }
        // check that ammount under limits allowed limits alowed to be
        require(_amount.add(allowanceDeacumulator) > lastLimit, 'out of limit');

        uint transferableAmount = _amount * ( uint(10) ** dispensedToken.decimals());
        dispensedToken.transfer(beneficiary,transferableAmount);
        allowanceDeacumulator += _amount;
        lastClaimTime = nowTime;
        emit fundsClaimed(transferableAmount);
    }
    // tells if current time is in the same monthly based range than the last claimFunds excuted
    function isSameMonthThanLastClaim(uint _givenTime) public view returns (bool) {
        return (getMonthsSinceStartTime(_givenTime) == getMonthsSinceStartTime(lastClaimTime) );
    }
    // When dispensed period is manually finilized all reamining funds in the contract will be transfered to the Owner of Dispenser.
    function finalizeDispensedPeriod () public onlyOwner notFinalized {
        uint remainingAmount = dispensedToken.balanceOf(address(this));
        dispensedToken.transfer(owner(),remainingAmount);
        finalized = true;
        emit dispenserPeriodFinalizedByOwner (remainingAmount);
    }
    // called when dispensed period is finalized by normal ending of dispensing period
    function finalize () private notFinalized {
        uint remainingAmount = dispensedToken.balanceOf(address(this));
        dispensedToken.transfer(msg.sender,remainingAmount);
        finalized = true;
        emit dispenserPeriodFinalized (msg.sender,remainingAmount);
    }
    modifier notFinalized() {
        require(!finalized,'This contract is not dispensing any more, dispensingPeriod has ended');
        _;
    }
    function setBeneficiary (address _newBeneficiary) public onlyOwner {
        require(_newBeneficiary != address(0), "Beneficiary can not be the zero address");
        beneficiary = _newBeneficiary;
        emit newBeneficiary(_newBeneficiary);
    }
}


