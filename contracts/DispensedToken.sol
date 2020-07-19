// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
import "@openzeppelin/contracts/token/ERC20/ERC20Capped.sol";

contract DispensedToken is ERC20Capped {
    constructor(uint _cap)
        ERC20("Dispensed Token", "DSP")
        ERC20Capped(_cap * (10 ** 18))
        public {
            _mint(msg.sender, _cap * (10 ** 18));
    }
}
