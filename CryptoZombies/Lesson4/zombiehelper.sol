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
    zombies[_zombieId].level++;
  }

  function changeName(uint _zombieId, string calldata _newName) external aboveLevel(2, _zombieId) ownerOf(_zombieId) {
    zombies[_zombieId].name = _newName;
  }

  function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId) ownerOf(_zombieId) {
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


/**
1. Visibility Modifiers:
 We have visibility modifiers that control when and where the function can be called from:
 private means it's only callable from other functions inside the contract; internal is like
 private but can also be called by contracts that inherit from this one; external can only be
 called outside the contract; and finally public can be called anywhere, both internally and
 externally.

2. State Modifiers:
  We also have state modifiers, which tell us how the function interacts with the BlockChain:
  view tells us that by running the function, no data will be saved/changed. pure tells us
  that not only does the function not save any data to the blockchain, but it also doesn't
  read any data from the blockchain. Both of these don't cost any gas to call if they're 
  called externally from outside the contract (but they do cost gas if called internally
  by another function).

3. Custom modifiers
 custom modifiers, which we learned about in Lesson 3: onlyOwner and aboveLevel,
 for example. For these we can define custom logic to determine how they affect a function.

4. payable Modifier
 they are a special type of function that can receive Ether.

5. msg.value is a way to see how much Ether was sent to the contract,
 and ether is a built-in unit

6.  If a function is not marked payable and you try to send Ether to it , the function will reject your transaction.

7. someone would call the function from web3.js (from the DApp's JavaScript front-end)
 as follows:
 
 // Assuming `OnlineStore` points to your contract on Ethereum:
OnlineStore.buySomething({from: web3.eth.defaultAccount, value: web3.utils.toWei(0.001)})

 Notice the value field, where the javascript function call specifies how much ether to send 
 (0.001). If you think of the transaction like an envelope, and the parameters you send to 
 the function call are the contents of the letter you put inside, then adding a value is like
 putting cash inside the envelope — the letter and the money get delivered together to the recipient.

8. After you send Ether to a contract, it gets stored in the contract's Ethereum account, 
and it will be trapped there — unless you add a function to withdraw the Ether from the contract.

9. After you send Ether to a contract, it gets stored in the contract's Ethereum account,
 and it will be trapped there — unless you add a function to withdraw the Ether from the contract.

Note: the _owner variable is of type uint160, meaning that we must explicitly cast it to address payable.
Once you cast the address from uint160 to address payable, you can transfer Ether to that address using the transfer function

 address(this).balance will return the total balance stored on the contract
 
 -> you could have a function that transfers Ether back to the msg.sender,
  if they overpaid for an item
  uint itemFee = 0.001 ether;
  msg.sender.transfer(msg.value - itemFee);

-> in a contract with a buyer and a seller, you could save the seller's address in storage,
 then when someone purchases his item, transfer him the fee paid by the buyer: 
 seller.transfer(msg.value)

10. The best source of randomness we have in Solidity is the keccak256 hash function.
 Other ways are not safe.

 // Generate a random number between 1 and 100:
uint randNonce = 0;
uint random = uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % 100;
randNonce++;
uint random2 = uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % 100;

better generate random numbers using oracles
 */