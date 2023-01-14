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
1. Multiple inheritancein solidity

2. modifier and a function cant have same name

3. Note that the ERC721 spec has 2 different ways to transfer tokens:

The first way is the token's owner calls transferFrom with his address as the _from 
parameter, the address he wants to transfer to as the _to parameter, and the _tokenId of
 the token he wants to transfer.

The second way is the token's owner first calls approve with the address he wants to
 transfer to, and the _tokenID . The contract then stores who is approved to take a token,
  usually in a mapping (uint256 => address). Then, when the owner or the approved address 
  calls transferFrom, the contract checks if that msg.sender is the owner or is approved by
   the owner to take the token, and if so it transfers the token to him.
 NOTE:
 Notice that both methods contain the same transfer logic. In one case the sender of the
 token calls the transferFrom function; in the other the owner or the approved receiver of
  the token calls it.

 4.There are extra features we may want to add to our implementation, such as some extra
  checks to make sure users don't accidentally transfer their zombies to address 0
   (which is called "burning" a token — basically it's sent to an address that no one
    has the private key of, essentially making it unrecoverable). Or to put some basic 
    auction logic in the DApp itself.

  5. Prevent Overflows and underflows
   Safe math library
   The SafeMath library has 4 functions — add, sub, mul, and div

  using SafeMath for uint256;
  uint256 a = 5;
  uint256 b = a.add(3); // 5 + 3 = 8
  uint256 c = a.mul(2); // 5 * 2 = 10

 6.  First we have the library keyword — libraries are similar to contracts but with a few 
 differences. For our purposes, libraries allow us to use the using keyword, which
 automatically tacks on all of the library's methods to another data type
 
 using SafeMath for uint;
// now we can use these methods on any uint
uint test = 2;
test = test.mul(3); // test now equals 6
test = test.add(5); // test now equals 11

Let's look at the code behind add to see what SafeMath does:

function add(uint256 a, uint256 b) internal pure returns (uint256) {
  uint256 c = a + b;
  assert(c >= a);
  return c;
}

 7. assert is similar to require, where it will throw an error if false. The difference 
 between assert and require is that require will refund the user the rest of their gas when
  a function fails, whereas assert will not. So most of the time you want to use require 
  in your code; assert is typically used when something has gone horribly wrong with the 
  code (like a uint overflow).

8. The standard in the Solidity community is to use a format called natspec. for commenting
/// @title A contract for basic math operations
/// @author H4XF13LD MORRIS 💯💯😎💯💯
/// @notice For now, this contract just adds a multiply function
contract Math {
  /// @notice Multiplies 2 numbers together
  /// @param x the first uint.
  /// @param y the second uint.
  /// @return z the product of (x * y)
  /// @dev This function does not currently check for overflows
  function multiply(uint x, uint y) returns (uint z) {
    // This is just a normal comment, and won't get picked up by natspec
    z = x * y;
  }
}
@title and @author are straightforward.

@notice explains to a user what the contract / function does. @dev is for explaining extra details to developers.

@param and @return are for describing what each parameter and return value of a function are for.

Note that you don't always have to use all of these tags for every function — all tags are optional. But at the very least, leave a @dev note explaining what each function does.

9. 
 */