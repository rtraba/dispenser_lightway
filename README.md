# Dispenser

Dispenser contract is designed to manage an ERC20Capped token - from here refered as DispensedToken or just DSP -. At first approach Dispenser was resposable of creating that token during its own deployment and therefore, Dispenser was the "owner" of DispensedToken. Also all the supply was being is just minted during cration, an finally Dispenser's address was the only holder of DSP at the begening of Dispensing period. 
This has changed because of a an increasing cost in gas during deployment. So the actuall shchema for deploying Dispenser is to manually deploy first DSP, with a capped supply given as a parameter, then deploy Dispenser passing DSP address and stopThresholdLimit to its constructor.

Dispensed Contract has been deployed to fit just one very particullar **monetary pollicy**. Given by DSP Cap of 700000 and stopThresholdLimit 100, resulting in a dispensing period of 28 years for funds unlocking schedule. Dispenser is going to be releasing or unlockig a predertimend amount of DSP in variable limit rates that changes in a yearly based timeframe, and thos limits apply for every single months.
There is only one single address, called *beneficiary*, that could claim those monthly unlocked funds. Something interesting to see is that Beneficiary could or could not claim all unlocked funds, resulting in a re-locked amount of DSP that Beneficiary won't be able to unlock again after finalizing the Dispensing period. 

Dispenser contract is an Ownable contract. This was not part of requirements but has been included in order to make a more felxible escenario regarding demostration. The owner is the *defaul beneficiary*. Owner address is the onlyone who can finilize the dispensing period at any time and can also change de beneficiary address.

## Funds Unlocking Schedule
DispensedToken has a capp of 700000 DSP, Dispneser is going to be unlocking, at maximunm this amount per month:
- year 1: 1000
- year 2: 2500
- year 3: 5000
- year 4: 10000
- years 5 - 8: 5000
- years 9 - 12: 2500
- years 13 - 16: 1250
- years 17 -20: 650
- years 21 - 24: 312.5
- years 25 - 28: 156.25

Dispensing period ends at the begining of the first month of the year 29, from that point any attemp to claim funds from Beneficiary is going to transfer all the remaining DSP balance to that address. 

## Monetary Policy Consistency check
At Dispenser creation time, its constructor executes the *populateLimits* process. As you can see, only the first four years are hardcoded with limits progression, and starting on year 5 it takes place what I call "satoshiMonetaryPolicy". SatoshiMonetaryPolicy just means: downsize the limits by a halv,one time each 4 years... and stop when the monthly limits cross the stopThresholdLimit. 
As this is a parameters dependent process, there are combinations between DSP capp and stopThresholdLimit tha can be considered *inconsistent* resulting in a Dispensing period accepting claimingfunds even if all the capp has been already distributed.
This solution has been implemented to prevent inconsistent deployments. If you try to deploy with DSP cap to small or a dispensing period to large, or stopThresholdLimit inadequate, the deploymnet transaction will be reverted and the contract won't be created.
This means you can also use thi contract for deploying diferent dispensing periodsn and work on diferen dispensed tokens.

## Design decisions
Dispenser token implement
The initial requirements for unlocking shcedule has been very precise. There are not requirements or previsibility for changing that schedule or the token or the beneficiary address. This solutions is being deployed for demonstrations porpouses only. So if there is no reason to change in smart contract, by default there are allways security reasons to make it in inflexible. 
 If something doesn't need to change, then it should be unchangable.

Considering previously described scenario, I desided to use a bidimentional array for keeping track of all limits, month by month. This results in a considerable increasing gas cots during deployment, but it allows the Dispenser contract to easly know the limits available for every month in the entire Dispensing period, not just current, but previous and future months too. I consider that capability to be an improvment regarding auditability.
Limits array has been implementes as a bidimentional combined sized array, dinamyc in years and fixed is months. Considering that there ar no certainty about the number of years that could be needed, but it is well known that every single year should use all available months.

## Finalizing the dispensing period
A beneficiary can only interact with the contract using calimFunds function. The dispensing period can be finalazid by owner, or in the normal case it will terminate just because of beneficiary runing claimFunds ot the period. Dispenser contrac checks how much time passed between contract creation time and current function execution. That way, when dispenser detects the feris claiming funds out of time, it just finilaze the contract and transfers all remaining DSP to beneficiary.  
If the contract is finilazed by owner, then owner's address is the recipient of the last transfer from Dispenser.

## Potential improvements:
- Multiplle beneficiaries: the contract could be implemented to support a beneficaries whitelist intead of just one beneficiary address. This should be decoupled from the Dispenser entrypoint contract.
- Beneficiary role tranference: the beneficiary role could be tranfered to a new address, and even more, that it could be implemented to be necesarly aprroved be new beneficiary as an acceptance of that role/capabilities transference. This could be usefull for undenaibility of rights over future unlocked funds, regarding regulation compliance stufs.
- Limts array could be optimized for prevention about running "out of gas", as there are dynamic arrays involved some times it could fail on creation if they has to populate to many years.

