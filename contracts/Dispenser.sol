// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import './DispensedToken.sol';


contract Dispenser {

    // deployment time, used for calculate current period and clims which limits to apply 
    uint startTime;
    // threshold after which there is no monetary policy and all founds are going to be released to beneficiary
    uint thresholdLimit;
    // beneficiary addresss is the onlyone who can be receipt of transfers from this contract
    address beneficiary;
    // DispensedToken is an ERC20Capped token, which total supply is managed by this contract
    DispensedToken dispensedToken;
    // Bidimentional array to store raimaing allowed withdrawals per months
    unit[29][12] limits;

    constructor(){
        beneficiary = msg.sender;
        DispensedToken = new DispensedToken();
        StartTime=now;
        thresholdLimit=100;
        this.populateLimits();
    }
     
    function populateLimits () private {
        // months dinamic limits are just hardcoded, as it doesn't change in original problem domain.
        this.populateSingleYear(1,1000);
        this.populateSingleYear(2,2500);
        this.populateSingleYear(3,5000);
        this.populateSingleYear(4,10000);
        // from year five we charge periods of 4 years dividin limits by 2on each period, like "bitcoin monetary policy"
        this.populateBySatoshiMonetaryPolicy(5,5000);
    }

    function populateBySatoshiMonetaryPolicy(unit _startpoint, unit _initialamount) private {
        uint allowed = _initialamount;
        uint period = 0;
        do {
            for (uint i = 0; i < 4; i++) {
                this.populateSingleYear((_startpoint-1)+period,allowed);
            }
            period ++;
            allowed = allowed/2;
        } while (l>this.thresholdLimit);
    }

    // here the convertion is just to fit number of decimals defined Dispensed token
    // it could be an option 
    function populateSingleYear (uint8 _yearorder, uint _limit) private {
        uint limit = _limit * ( 10 ** 18 );

        for (uint i = 0; i < 12; i++) {
                //index year in year-1 because the first year is represented in 0 index array
                this.limit[_yearorder-1][i] = limit;
            }
    }

    function getYearAndMonths (uint _time) private returns (uint8 year,uint8 month){
         // this is the number of years between two timestamps in seconds, assuming years have 160 days for simplification
        uint y = (((( _time - this.startTime ) /60 ) / 60 ) / 24 ) / 360;
            /// this is how many months 
        uint m = (((( _time - this.startTime ) / 60 ) / 60 ) / 24 ) / 30;
        return (y,m);
    }

    //this function is being created just for cheking array state
    function getCurrentMonthUnclaimedFund() public {
        (uint8 y, uint8 m) = this.getYearAndMonth(now);
        return this.limits[y][m];
    }

    function getMonthUnclaimedFund(uint y, uint m) public retunrs unint{
        require (0 < m <= 12, 'month not allowed more than 12');
        require (0 < y <= 28, 'year should not be more than 28');
        return this.limits[y-1][m-1];
    }

    // 
    function claimFunds (uint _amount) public {
        require(msg.sender = this.beneficiary, 'Only Beneficiary addredss is allowed to claim founds' );
        uint time = now;

        (uint8 y, uint8 m) = this.getYearAndMonth(time);
    //    assert (y>28 && m >12) emitir evento de finalización y liberar todos los fondos
        require(_amount <= this.limits[y][m], 'You are trying to withdraw more than allowed this month');

        dispensedToken.transfers(this.beneficiary, _amount);
        this.limits[y][m] = this.limits[y][m] - _amount;

    }
}