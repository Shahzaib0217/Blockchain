pragma solidity >=0.5.0 <0.6.0;

import "./zombiefeeding.sol";

contract ZombieHelper is ZombieFeeding {

  uint levelUpFee = 0.001 ether;

  modifier aboveLevel(uint _level, uint _zombieId) {
    require(zombies[_zombieId].level >= _level);
    _;
  }

  function withdraw() external onlyOwner {
    address _owner = owner();
    _owner.transfer(address(this).balance);
  }

  function setLevelUpFee(uint _fee) external onlyOwner {
    levelUpFee = _fee;
  }

  function levelUp(uint _zombieId) external payable {
    require(msg.value == levelUpFee);
    zombies[_zombieId].level = zombies[_zombieId].level.add(1);
  }

  function changeName(uint _zombieId, string calldata _newName) external aboveLevel(2, _zombieId) onlyOwnerOf(_zombieId) {
    zombies[_zombieId].name = _newName;
  }

  function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId) onlyOwnerOf(_zombieId) {
    zombies[_zombieId].dna = _newDna;
  }

  function getZombiesByOwner(address _owner) external view returns(uint[] memory) {
    uint[] memory result = new uint[](ownerZombieCount[_owner]);
    uint counter = 0;
    for (uint i = 0; i < zombies.length; i++) {
      if (zombieToOwner[i] == _owner) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }

}


/**   ERC721 Token
1. Setting a Web3 Provider in Web3.js tells our code which node we should be talking to 
 handle our reads and writes. It's kind of like setting the URL of the remote web server
 for your API calls in a traditional web app.

2. Infura 
 Infura is a service that maintains a set of Ethereum nodes with a caching layer for fast
 reads, which you can access for free through their API. Using Infura as a provider,
 you can reliably send and receive messages to/from the Ethereum blockchain without 
 needing to set up and maintain your own node.

You can set up Web3 to use Infura as your web3 provider as follows:
var web3 = new Web3(new Web3.providers.WebsocketProvider("wss://mainnet.infura.io/ws"));

3. Web3.js will need 2 things to talk to your contract: its address and its ABI.

 After you deploy your contract, it gets a fixed address on Ethereum where it will live forever.

 ABI stands for Application Binary Interface. Basically it's a representation of your 
 contracts' methods in JSON format that tells Web3.js how to format function calls in a way
 your contract will understand.
 When you compile your contract to deploy to Ethereum, the Solidity compiler will give you 
 the ABI, so you'll need to copy and save this in addition to the contract address.

4. Talking to contract with web3.js
// Instantiate myContract
var myContract = new web3js.eth.Contract(myABI, myContractAddress);

5. Web3.js has two methods we will use to call functions on our contract: call and send
call is used for view and pure functions. It only runs on the local node, and won't create
 a transaction on the blockchain.

6. call is used for view and pure functions. It only runs on the local node, 
 and won't create a transaction on the blockchain.
Review: view and pure functions are read-only and don't change state on the blockchain.
 They also don't cost any gas, and the user won't be prompted to sign a transaction with MetaMask

myContract.methods.myMethod(123).call()

7. send will create a transaction and change data on the blockchain.
 You'll need to use send for any functions that aren't view or pure.
Note: sending a transaction will require the user to pay gas, and will pop up their
 Metamask to prompt them to sign a transaction. When we use Metamask as our web3 provider,
  this all happens automatically when we call send(), and we don't need to do anything 
  special in our code. Pretty cool!
 
 myContract.methods.myMethod(123).send()

 8. Zombie[] public zombies;
In Solidity, when you declare a variable public, it automatically creates a public "getter"
 function with the same name. So if you wanted to look up the zombie with id 15, you would 
 call it as if it were a function: zombies(15).

 9. Version 1.0 of Web3.js, which uses promises instead of callbacks.

function getZombieDetails(id) {
  return cryptoZombies.methods.zombies(id).call()
}

// Call the function and do something with the result:
getZombieDetails(15)
.then(function(result) {
  console.log("Zombie 15: " + JSON.stringify(result));
})
Note that this is asynchronous, like an API call to an external server.
 So Web3 returns a promise here. 

10. Getting the user's account in MetaMask
We can see which account is currently active on the injected web3 variable via:
var userAccount = web3.eth.accounts[0]

11. Function to change ui when user account is changed from metamask
var accountInterval = setInterval(function() {
  // Check if account has changed
  if (web3.eth.accounts[0] !== userAccount) {
    userAccount = web3.eth.accounts[0];
    // Call some function to update the UI with the new account
    updateInterface();
  }
}, 100);

What this does is check every 100 milliseconds to see if userAccount is still equal
 web3.eth.accounts[0] (i.e. does the user still have that account active).
  If not, it reassigns userAccount to the currently active account, and calls a function
  to update the display.

12. Note: You can optionally specify gas and gasPrice when you call send,
 e.g. .send({ from: userAccount, gas: 3000000 }). If you don't specify this,
  MetaMask will let the user choose these values.

13.The way to send Ether along with a function is simple, with one caveat: 
 we need to specify how much to send in wei, not Ether.

 14. Web3.js has a conversion utility that converts eth to wei
 // This will convert 1 ETH to Wei
web3js.utils.toWei("1");

15. In order to filter events and only listen for changes related to the current user,
 our Solidity contract would have to use the indexed keyword, like we did in the Transfer
  event of our ERC721 implementation:

 event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);

 In this case, because _from and _to are indexed, that means we can filter for them in
  our event listener in our front end:

// Use `filter` to only fire this code when `_to` equals `userAccount`
cryptoZombies.events.Transfer({ filter: { _to: userAccount } })
.on("data", function(event) {
  let data = event.returnValues;
  // The current user just received a zombie!
  // Do something here to update the UI to show it
}).on("error", console.error);

16. Querying past events
We can even query past events using getPastEvents, and use the filters fromBlock and
 toBlock to give Solidity a time range for the event logs ("block" in this case referring 
 to the Ethereum block number):

cryptoZombies.getPastEvents("NewZombie", { fromBlock: 0, toBlock: "latest" })
.then(function(events) {
  // `events` is an array of `event` objects that we can iterate, like we did above
  // This code will get us a list of every zombie that was ever created
});
 Because you can use this method to query the event logs since the beginning of time,
 this presents an interesting use case: Using events as a cheaper form of storage.

 */