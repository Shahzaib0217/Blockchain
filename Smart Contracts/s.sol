
/* 
Basic Algo of this Lottery Smart Contract:
-> 2 major entities in this project,
 Manager: have a full control of lottery, checks balance, activating lottery
 Participants: persons involved in lottery (min. participants 3)
-> All participents will send a specific decided amount of ether to contract.
-> once a participant sends ether its address will be registered.
-> Participant can send ethers more than 1 time but not more than the decided amount.
-> The contract will be reset after a winner is selected.
-> Winner is selected Randomly.
*/

//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract Lottery{
    address public manager; // stores address of manager
    address payable[] public participants; // Dynamic Array for holding address of participants, payable cuz participants will transfer Ether

    constructor() // For storing account address in manager to provide control of lottery
    {
        manager=msg.sender; // msg.sender is a global variable 
        /* Working:
         The account address (through which the contract is deployed) will be stored in static variable manager (through msg.sender)
         So manager will have full control of contract because he deployed the contract.
        */
    }

    /*
    Now, making a payable function() through which participants can transfer Ethers to smart contract.
    -> receive is a special type of function for receiving ethers, can be used only 1 time, no parameters can be passed,
    -> receive is always external and payable 
    */
    receive() external payable 
    {
        /* require statement is like if else*/
        require(msg.value==1 ether); // if its ture then run next line  
        /*
        For receiving ethers, we need to register the address of participant (by using msg.sender)
        Must use payable with msg.sender cuz participants array is payable
        */
        participants.push(payable(msg.sender));
    }

    // To check the balance stored in smart contract
    function getbalance() public view returns(uint) 
    {
        require(msg.sender==manager); // only manager can check the balance
        return address(this).balance; // this will return the balance stored in contract
        /*
        address(this) refers to smart contract's address
        smart contract adresss uniquely identifies smart contract
        contract address is associated with NONCE and other fields.
        */
    }

    // Now, function for selecting participants on random basis
    function random() public view returns(uint)
    {
        // keccak256 is an hashing algo. same like SHA-256
       return uint(keccak256(abi.encodePacked(block.difficulty,block.timestamp,participants.length))); // never use this random function in main net
    }

    function selectWinner() public 
    {
        require(msg.sender==manager);
        require(participants.length>=3);

        uint r=random();
        uint index = r%participants.length;

        address payable winner; // payable cuz we will transfer ethers to winner
        winner=participants[index];
        winner.transfer(getbalance()); // transfering contract balance to winner 
        participants=new address payable[](0); // resetting array at end
    }
}
 
