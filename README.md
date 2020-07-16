# Dispenser

Dispenser contract is designed to manage an ERC20Capped token - from here refered as DispensedToken or just DSP -. In fact Dispenser creates that token during its own deployment and therefore, Dispenser is "owner" of DispensedToken. Also all the supply is just mminted during cration, an finally Dispenser's address is the only holder of DSP at the begening of Dispensing period. 


Dispensed Contract has been implemented to fit just one very particullar monetary pollicy. Dispenser is going to be releasing or unlockig a predertimend amount of DSP in variable rates that changes in a months/years based timeframe. 
There is only one single address, called *beneficiary*, that could claim those monthly unlocked founds. Something interesting to see is that Beneficiary could or could not claim all unlocked found, resulting in a re-locked amount of DSP that Beneficiary won't be able to unlock again after finalizing the Dispensing period. 

## Funds Unlocking Schedule
DispensedToken has a capp of 700000 DSP, DIspneser is going to be unlocking, at maximunm this amount per month:
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

Dispensing period ends at the begining of the first month of the year 29, from that point any attemp to claim funds from Beneficiary is going to tranfer all the amount to that address.

## Designing desitions
The initial implementation is not designed for flexibility regarding the unlocking schedule or token parametrization. The initial requirements for unlocking shcedule has been very precise, and as there is no requirements or previsibility for changing


## Potential improvements:
- Parametrizable token: Dispenser contraact could be Dispensed a predetermined amount of an existing token. For example for managing some amount of DAI (or any stablecoin) ... and releasing founds in a pre-determined schedule.
- Parametrizable schedule: Dispensed contracts cuold be generalized to support a more standar way of parametrization regarding de limits[y][m] array. It cuold be challenging to design some way of parametrization that can bee felxible enought to be widley usefull, but also enoughtly secure. Maybe this can derive in a Schedule library, for defining standar ways of defining limits based in timeframes and other conditions.
- Beneficiary: the contract could be implemented to support a beneficaries whitelist intead of just one beneficiary address.
- Beneficiary role tranference: the beneficiary role could be tranfered to a new address, and even more, that it could be implemented to be necesarly aprroved be new beneficiary as an acceptance of that role/capabilities transference. This could be usefull for undenaibility of rights over future unlocked funds, regarding regulation compliance stufs.

