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
    // beneficiary addresss is the onlyone who can be receipt of transfers from this contract
    bool public finalized;
    // beneficiaries are addresss that can claimfunds if they has been added by owner, accepted by themselves, and didn't renounce to be beneficiaries
    mapping(address => Beneficiary) public beneficiaries;
    struct Beneficiary {
        bool isAdded;
        bool isAccepted;
    }

    // DispensedToken is an ERC20Capped token, which total supply is managed by this contract
    DispensedToken public dispensedToken;
    // Bidimentional array to store raimaing allowed withdrawals per months
    uint[12][29] public limits;

    // events
    event beneficiaryInvited(address indexed invitedBeneficiary);
    event beneficiaryRemoved(address indexed deletedBeneficiary);
    event benficiaryRightsAccepted (address indexed newBeneficiary);
    event benficiaryRightsRenounced (address indexed newBeneficiary);

    event dispenserPeriodFinilized (uint reamainingAmount);
    event fundsClaimed(uint amount);

    constructor() public{
        dispensedToken = new DispensedToken();
        startTime = now;
        stopThresholdLimit = 100;
        finalized = false;
        populateLimits();
        addBeneficiary(msg.sender);
        acceptBeneficiaryRights();
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
                populateSingleYear((_startpoint.add(period)).add(i),allowed);
            }
            period = period.add(4);// + 4;
            allowed = allowed.div(2);// /2;
        } while (allowed > stopThresholdLimit);
    }

    // here the convertion is just to fit number of decimals defined Dispensed token
    // the function asummes the argument received represents an integer amount of DSP
    function populateSingleYear (uint _yearorder, uint _limit) private {
        uint limit = _limit.mul((uint(10)) ** dispensedToken.decimals());

        for (uint i = 0; i < 12; i++) {
                //index year in year-1 because the first year is represented in 0 index array
                limits[_yearorder.sub(1)][i] = limit;
            }
    }

     /**
     * returns how many years and months has been pased betweeen the startpoint and a given timesttamp
     * uses SafeMath to avoid overflows
     */
    function getYearAndMonths (uint _time) public view returns (uint _year,uint _month){
        // this is the number of years between two timestamps in seconds, assuming years have 360 days for simplification
         //((((_time - startTime ) / 60 ) / 60 ) / 24 ) / 360;
        uint yea = ((((_time.sub(startTime)).div(60)).div(60)).div(24)).div(360);
        // this is how many months
        //((((( _time - startTime ) / 60 ) / 60 ) / 24 ) / 30 ) - yea*12;
        uint all_monts = ((((_time.sub(startTime)).div(60)).div(60)).div(24)).div(30);
        uint mon = all_monts.sub(yea.mul(12));
        return (yea,mon);
    }

    //this function is being created just for cheking array state
    function getCurrentMonthUnclaimedFund() public view returns (uint remainingAllowed){
        (uint y, uint m) = getYearAndMonths(now);
        return limits[y][m];
    }

    function getMonthUnclaimedFund(uint y, uint m) public view returns (uint _remining_funds) {
        require (m <= 12, 'month not allowed more than 12');
        require (0 < m, 'month not allowed more less than zero');
        require (y <= 28, 'year should not be more than 28');
        require (0 < y, 'year should not be more than 28');
        return (limits[y.sub(1)][m.sub(1)]);
    }

    function claimFunds (uint _amount) public notFinalized {
        require(isAcceptedBeneficiary(msg.sender), 'Only accepted beneficiary addredss are allowed to claim founds');
        (uint y, uint m) = getYearAndMonths(now);
    //    assert (y>28 && m >12) emitir evento de finalización y liberar todos los fondos
        require(_amount <= limits[y][m], 'You are trying to withdraw more than remaining allowed this month');
        address beneficiary = msg.sender;
        dispensedToken.transfer(beneficiary, _amount);
        limits[y][m] = limits[y][m] - _amount;
        emit fundsClaimed(_amount);

    }

    // When dispensed period os finilized all reamining funds in the contract will be transfered to the Owner of the contract.
    function finalizeDispensedPeriod () public onlyOwner notFinalized {
        uint remainingAmount = dispensedToken.balanceOf(address(this));
        dispensedToken.transfer(owner(),remainingAmount);
        finalized = true;
        emit dispenserPeriodFinilized (remainingAmount);

    }
    modifier notFinalized() {
        require(!finalized, "This contract is not dispensing any more, dispensed period has ended");
        _;
    }


    /**
     * only owner operations regarding beneficiaries: add and remove
     */
    function addBeneficiary (address _newBeneficiary) public onlyOwner returns (bool success){
        require(_newBeneficiary != address(0), "Beneficiary can not be the zero address");
        beneficiaries[_newBeneficiary].isAdded = true;
        emit beneficiaryInvited(_newBeneficiary);
        return true;
    }
    function removeBeneficiary (address _deletedBeneficiary) public onlyOwner returns (bool success){
        require(_deletedBeneficiary != address(0), "Beneficiary can not be the zero address");
        beneficiaries[_deletedBeneficiary].isAdded = false;
        emit beneficiaryRemoved(_deletedBeneficiary);
        return true;
    }

     /**
     * Beneficiaries can accept or renounce their rigth to claim funds, just if they has been previusly added by owner
     */
    function acceptBeneficiaryRights () public returns (bool _success){
        require( isAddedBeneficiary(msg.sender), "Only previously added beneficiaries can accept beneficiary rights");
        beneficiaries[msg.sender].isAccepted = true;
        emit benficiaryRightsAccepted(msg.sender);
        return true;
    }
    function renounceBeneficiaryRights() public returns (bool _success) {
        require(isAcceptedBeneficiary(msg.sender), 'Only an accepted beneficiaries can renounce beneficiary rights');
        beneficiaries[msg.sender].isAccepted = false;
        emit benficiaryRightsRenounced(msg.sender);
        return true;
    }

    //  any addres can check if beneficiaries has been added by owner
    function isAddedBeneficiary(address _beneficiary) public view returns (bool _isadded){
        return beneficiaries[_beneficiary].isAdded;
    }
    function isAcceptedBeneficiary(address _beneficiary) public view returns (bool _isaccepted){
        return (beneficiaries[_beneficiary].isAdded && beneficiaries[_beneficiary].isAccepted);
    }
    
    // remove this before deploy, is just for testing 
    function checkLimitsArrays ( uint _1, uint _2) public view returns (uint _value1)  {
        return (limits[_1][_2]);
    }

}


