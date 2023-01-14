pragma solidity >=0.5.0 <0.6.0;

import "./zombiefeeding.sol";

contract ZombieHelper is ZombieFeeding {

  modifier aboveLevel(uint _level, uint _zombieId) {
    require(zombies[_zombieId].level >= _level);
    _;
  }

  function changeName(uint _zombieId, string calldata _newName) external aboveLevel(2, _zombieId) {
    require(msg.sender == zombieToOwner[_zombieId]);
    zombies[_zombieId].name = _newName;
  }

  function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId) {
    require(msg.sender == zombieToOwner[_zombieId]);
    zombies[_zombieId].dna = _newDna;
  }

  function getZombiesByOwner(address _owner) external view returns(uint[] memory) {
    uint[] memory result = new uint[](ownerZombieCount[_owner]);
    // Start here
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
1. Ownable Contracts 

2. Modifiers. 
 Modifies the working of function, check ownly owner in ownable.sol

3. Gas

4. Struct packing to save gas
 If you have multiple uints inside a struct, using a smaller-sized uint when possible will
 allow Solidity to pack these variables together to take up less storage. For example:

 place uint32 etc together to save gas. 
struct MiniMe {
  uint32 a;
  uint32 b;
  uint c;
}

Normally there's no benefit to using these sub-types because Solidity reserves 256 bits of 
storage regardless of the uint size. For example, using uint8 instead of uint (uint256)
 won't save you any gas.

5. The variable "now" will return the current unix timestamp of the latest block
 (the number of seconds that have passed since January 1st 1970).

 Note: Unix time is traditionally stored in a 32-bit number. This will lead to the
  "Year 2038" problem, when 32-bit unix timestamps will overflow and break a lot of legacy
   systems. So if we wanted our DApp to keep running 20 years from now, we could use a 
   64-bit number instead — but our users would have to spend more gas to use our DApp
    in the meantime. Design decisions!

6. Solidity also contains the time units seconds, minutes, hours, days, weeks and years.
 These will convert to a uint of the number of seconds in that length of time.
  So 1 minutes is 60, 1 hours is 3600 (60 seconds x 60 minutes),
   1 days is 86400 (24 hours x 60 minutes x 60 seconds), etc.

7. An important security practice is to examine all your public and external functions,
 and try to think of ways users might abuse them. Remember — unless these functions have
  a modifier like onlyOwner, any user can call them and pass them any data they want to.

 so the easiest way to prevent these exploits is to make it internal.

8. Function modifiers can also take arguments.

9. Note: calldata is somehow similar to memory, but it's only available to external functions.

10. view functions don't cost any gas when they're called externally by a user.

Note: If a view function is called internally from another function in the same contract
 that is not a view function, it will still cost gas. This is because the other function
  creates a transaction on Ethereum, and will still need to be verified from every node.
  So view functions are only free when they're called externally.

11. Storage is Expensive
 In order to keep costs down, you want to avoid writing data to storage except when
 absolutely necessary. Sometimes this involves seemingly inefficient programming logic — 
 like rebuilding an array in memory every time a function is called instead of simply saving
 that array in a variable for quick lookups.

 In most programming languages, looping over large data sets is expensive. But in Solidity, 
 this is way cheaper than using storage if it's in an external view function, since view 
 functions don't cost your users any gas. (And gas costs your users real money!).

12. Declaring arrays in memory
You can use the memory keyword with arrays to create a new array inside a function without
 needing to write anything to storage. The array will only exist until the end of the 
 function call, and this is a lot cheaper gas-wise than updating an array in storage — free
  if it's a view function called externally. 

Note: memory arrays must be created with a length argument (in this example, 3). 
They currently cannot be resized like storage arrays can with array.push(), although this 
 may be changed in a future version of Solidity.

 */