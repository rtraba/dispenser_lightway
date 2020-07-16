// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import './DispensedToken.sol';


contract Dispenser {
    // deployment time, used for calculate current period and clims which limits to apply
    uint public startTime;
    // threshold after which there is no monetary policy and all founds are going to be released to beneficiary
    uint public stopThresholdLimit;
    // beneficiary addresss is the onlyone who can be receipt of transfers from this contract
    address public beneficiary;
    // DispensedToken is an ERC20Capped token, which total supply is managed by this contract
    DispensedToken public dispensedToken;
    // Bidimentional array to store raimaing allowed withdrawals per months
    uint[29][12] public limits;

    constructor() public{
        beneficiary = msg.sender;
        dispensedToken = new DispensedToken();
        startTime = now;
        stopThresholdLimit = 100;
        populateLimits();
    }

    function populateLimits () private {
        // months dinamic limits are just hardcoded, as it doesn't change in original problem domain.
        populateSingleYear(1,1000);
        populateSingleYear(2,2500);
        populateSingleYear(3,5000);
        populateSingleYear(4,10000);
        // from year five we charge periods of 4 years dividin limits by 2on each period, like "bitcoin monetary policy"
        populateBySatoshiMonetaryPolicy(5,5000);
    }

    function populateBySatoshiMonetaryPolicy(uint _startpoint, uint _initialamount) private {
        uint allowed = _initialamount;
        
        uint period = 0;
        do {
            for (uint i = 0; i < 4; i++) {
                populateSingleYear((_startpoint-1)+period,allowed);
            }
            period ++;
            allowed = allowed/2;
        } while (allowed>this.stopThresholdLimit);
    }

    // here the convertion is just to fit number of decimals defined Dispensed token
    // it could be an option
    function populateSingleYear (uint _yearorder, uint _limit) private {
        uint limit = _limit * ( 10 ** 18 );

        for (uint i = 0; i < 12; i++) {
                //index year in year-1 because the first year is represented in 0 index array
                limits[(_yearorder-1)][i] = limit;
            }
    }

    function getYearAndMonths (uint _time) private returns (uint year,uint month){
        // this is the number of years between two timestamps in seconds, assuming years have 160 days for simplification
        uint yea = (((( _time - this.startTime ) / 60 ) / 60 ) / 24 ) / 360;
        // this is how many months
        uint mon = (((( _time - this.startTime ) / 60 ) / 60 ) / 24 ) / 30;
        return (yea,mon);
    }

    //this function is being created just for cheking array state
    function getCurrentMonthUnclaimedFund() public {
        (uint y, uint m) = getYearAndMonths(now);
        return this.limits[y][m];
    }

    function getMonthUnclaimedFund(uint y, uint m) public returns (uint remining_funds) {
        require (0 < m <= 12, 'month not allowed more than 12');
        require (0 < y <= 28, 'year should not be more than 28');
        return this.limits[y-1][m-1];
    }

    function claimFunds (uint _amount) public {
        require(msg.sender = this.beneficiary, 'Only Beneficiary addredss is allowed to claim founds');
        uint time = now;

        (uint y, uint m) = getYearAndMonths(time);
    //    assert (y>28 && m >12) emitir evento de finalización y liberar todos los fondos
        require(_amount <= this.limits[y][m], 'You are trying to withdraw more than allowed this month');

        this.dispensedToken.transfers(this.beneficiary, _amount);
        this.limits[y][m] = this.limits[y][m] - _amount;

    }
}