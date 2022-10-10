/*
Basic Algo of this Crowd Funding Smart Contract:
Company's Manager: Collects fund for the company(for project, business or charity)
-> Manager sets Target, deadline and Min. Contribution
Contributors: Sends money to smart contract
-> More than 50% of the contributors have to vote 'Yes', than manager can take money from smart contract.
-> If the target amount isn't collected in deadline the contributors can take their money back.
but only if deadline and target didn't meet.
*/

//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 < 0.9.0;

contract CrowdFunding{
    /*
    Address is mapped to total ethers a contributor is contributing,
    address => ethers
    to tell by address, how much an contributor is contributing.
    Contributor[msg.sender] gives ether amount of the contributor.
    msg.sender gives the address of the current contributor.
    */
    mapping(address=>uint) public contributors; /* */
    //Each address maps contribution (Address -> Contribution), initially contribution is zero
    // Mapping: Its like rows and columns, e.g:
    // 0xa1 -> 100
    // 0xa2 -> 104
    // 0xa3 -> 190
    address public manager;
    uint public minContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributors;

    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address=>bool) voters;
    }

    mapping(uint=>Request) public requests;
    uint public numRequests;

    
    //Manager will define the deadline and target while deploying the smart contract.  
    constructor(uint _target, uint _deadline)
    {
        target= _target;
        deadline=block.timestamp+_deadline; // timestamp gives unix time
        minContribution=100 wei;
        manager=msg.sender; // Adress will be assigned to manager as the contract is deployed  
    }

    // for contributors to contribute Ether
    function sendEth() public payable
    { 
    //this require will check deadline, if deadline has passed then contract will not store more ethers
    require(block.timestamp < deadline, "Deadline ha passed");
    //this require will check contributor's contribution, if the contribution is less than the require value contract will not store or accept the ether.
    require(msg.value >= minContribution, "Minimum Contributiion is not met");
    //Only increment when there is a new contriutor, if same person contributes again no increment
    if(contributors[msg.sender]==0)
    {
    noOfContributors++;
    }    
    // Adding to the contributed Ethers
    contributors[msg.sender]+=msg.value;
    raisedAmount+=msg.value;
    }

    //Function to check balance of our smart contract
    function getContractbalance() public view returns(uint){
        return address(this).balance;
    }
    
    //This function will refund contributor his ethers, if the deadline is passed and target is not met. 
    function refund() public{
        // This require checks, if the deadline has passed and target has met or not.
        require(block.timestamp>deadline && raisedAmount<target, "You are not eligible for refund");
        //This require will check if the contributor has funded ethers before.
        require(contributors[msg.sender]>0, "You are not a contributor");
        // If all conditions satisfies the contributor is eligible for the refund
        address payable eligible_user=payable(msg.sender); // msg.sender (address) is payable cuz we have to transfer eth to it
        //Refunding Eth
        eligible_user.transfer(contributors[msg.sender]);
         /*
        Now resetting the contributor's contribution to 0
        cuz the amount as been refunded.
        */
        contributors[msg.sender]=0;
    }

    modifier onlyManager(){
        require(msg.sender==manager,"Only manager can call this function");
        _; // ending of modifier;
    }

    function createRequests(string memory _description, address payable _recipient, uint _value) public onlyManager
    {
        Request storage newRequest = requests[numRequests]; // always use storage when using mapping in struct
        numRequests++;
        newRequest.description= _description;
        newRequest.recipient= _recipient;
        newRequest.value= _value;
        newRequest.completed=false;
        newRequest.noOfVoters=0;
   }

 // Through this function a contributor can vote for a particular request made by the manager
   function voteRequest(uint _requestNo) public
   {
        //For vote a person should be a contributor, This require will check if the person is contributor  or not
        require(contributors[msg.sender]>0, "You must be a contributor");
        Request storage thisRequest = requests[_requestNo];
        /*
        This require will check if the contributor has voted before or not
        if contributor has already voted he can not vote for same request twice but he can vote for other requests.
        */
        require(thisRequest.voters[msg.sender]==false,"You have already voted");
        thisRequest.voters[msg.sender]=true;
        thisRequest.noOfVoters++; // counting total num of voters for a particular request
   }

    /*
    Through this function manager will make payment to that firm for which he had pulled a request.
    but manager can only make this transaction if and only if,
    -> Raised_Amount should be greater or equal to target_amount.
    -> Total_Number_Of_votes for that firms_request should be greater than 50% of the no_of _contributors.
    -> That particular request should not be completed before.    
    */
   function makePayment(uint _requestNo) public onlyManager{
       require(raisedAmount>=target); // raised amount must be >= target
       Request storage thisRequest = requests[_requestNo];
        /*
        This require will check whether the particular firm's request has been completed.
        If the request has been completed then no fund should be given to that particular firm.
        */
       require(thisRequest.completed==false, "The request has been completed");
        //This require will check if the num of voters for that particular firm are > the 50% of the num of contributors. 
       require(thisRequest.noOfVoters > noOfContributors/2, "Majority does not support");
       //If all conditions met then amount will be funded to that particular firm.
       thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed=true;
   }
}
