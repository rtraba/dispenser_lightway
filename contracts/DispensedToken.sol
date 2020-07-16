// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
import "@openzeppelin/contracts/token/ERC20/ERC20Capped.sol";

contract DispensedToken is ERC20Capped {
    constructor()
        ERC20("Dispensed Token", "DSP")
        ERC20Capped(700000 * (10 ** 18))
        public {
            _mint(msg.sender, 700000 * (10 ** 18));
    }
}
