pragma solidity >=0.5.0 <0.6.0;

import "./zombiefactory.sol";

/** In interface we only mention functions we want to interact with
    we dont define functions body. only declare functions */
contract KittyInterface {
  function getKitty(uint256 _id) external view returns (
    bool isGestating,
    bool isReady,
    uint256 cooldownIndex,
    uint256 nextActionAt,
    uint256 siringWithId,
    uint256 birthTime,
    uint256 matronId,
    uint256 sireId,
    uint256 generation,
    uint256 genes
  );
}

contract ZombieFeeding is ZombieFactory {

  address ckAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
  KittyInterface kittyContract = KittyInterface(ckAddress);

  // Modify function definition here:
  function feedAndMultiply(uint _zombieId, uint _targetDna, string memory _species) public {
    require(msg.sender == zombieToOwner[_zombieId]);
    Zombie storage myZombie = zombies[_zombieId];
    _targetDna = _targetDna % dnaModulus;
    uint newDna = (myZombie.dna + _targetDna) / 2;
    // Add an if statement here
    if (keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
      newDna = newDna - newDna % 100 + 99; // setting last 2 digits to 99
    }
    _createZombie("NoName", newDna);
  }

  function feedOnKitty(uint _zombieId, uint _kittyId) public {
    uint kittyDna;
    (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId); // multiple return values
    // And modify function call here:
    feedAndMultiply(_zombieId, kittyDna, "kitty");
  }

}

/**                        -------- NOTES Lesson 2--------
1. In Solidity, there are certain global variables that are available to all functions.
 One of these is msg.sender, which refers to the address of the person (or smart contract)
 who called the current function.
In Solidity, function execution always needs to start with an external caller.
 A contract will just sit on the blockchain doing nothing until someone calls one of its
 functions. So there will always be a msg.sender.

2. require makes it so that the function will throw an error and stop executing if some
   condition is not true

3. Inheritance: 
 BabyDoge inherits from Doge. That means if you compile and deploy BabyDoge,
 it will have access to any public functions we may define on Doge.

 This can be used for logical inheritance (such as with a subclass, a Cat is an Animal).
 But it can also be used simply for organizing your code by grouping similar logic together
 into different contracts.

4. Split long code bases into multiple files using import

5. In Solidity, there are two locations you can store variables — in storage and in memory.
 Storage refers to variables stored permanently on the blockchain.
 Memory variables are temporary, and are erased between external
 function calls to your contract. 

 Most of the time you don't need to use these keywords because Solidity handles them
 by default. State variables (variables declared outside of functions) are by default
 storage and written permanently to the blockchain, while variables declared inside functions
 are memory and will disappear when the function call ends.

 We use these keywords when dealing with structs and arrays within functions

6. internal is the same as private, except that it's also accessible to contracts
 that inherit from this contract.

7. external is similar to public, except that these functions can ONLY be called
 outside the contract — they can't be called by other functions inside that contract. 

 */