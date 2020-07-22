# Dispenser Lightway

This is a complete code refactoring from https://github.com/rtraba/Dispenser.
This implementation is better in gas consumtion, easier to undertand and audit. 
The main diference is that this lightway Dispenser contract does not store any collection on-chain, intead it just store the minimun required data in state variables, it recalculates things just when it is mandatory and thats trigered by detecting months changes between withdrawals.