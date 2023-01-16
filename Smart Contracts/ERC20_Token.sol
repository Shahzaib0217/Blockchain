// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract LW3Token is ERC20 {
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        _mint(msg.sender, 10 * 10 ** 18);
    }
    /*
    _mint is an internal function within the ERC20 standard contract, which means that it can only be called by the contract itself. External users cannot call this function.

    Since you as the developer want to receive some tokens when you deploy this contract, we call the _mint function to mint some tokens to msg.sender.

    _mint takes two arguments - an address to mint to, and the amount of tokens to mint

    msg.sender is a global variable injected by the Ethereum Virtual Machine, which is the address which made this transaction. Since you will be the one deploying this contract, your address will be there in msg.sender.

    10 * 10 ** 18 specifies that you want 10 full tokens to be minted to your address.

    ERC20 tokens by default work with 18 decimal places. So 1 full LW3Token in this case,
    is actually represented as 10 ^ 18. Therefore, to get 10 full LW3Tokens, we use 10 * 10 ** 18
    */

}