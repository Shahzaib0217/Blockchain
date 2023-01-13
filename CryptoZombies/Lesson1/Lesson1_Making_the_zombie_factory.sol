pragma solidity >=0.5.0 <0.6.0;

contract ZombieFactory {

    // declare our event here
  event NewZombie(uint zombieId, string name, uint dna);

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;

    struct Zombie {
        string name;
        uint dna;
    }

    Zombie[] public zombies; // array of struct type

    function _createZombie(string memory _name, uint _dna) private {
        /** array.push() returns a uint of the new length of the array
        and since the first item in an array has index 0, array.push() - 1,
        will be the index of the zombie we just added.
        Store the result of zombies.push() - 1 in a uint called id,
        so you can use this in the NewZombie event in the next line. */
        
        uint id = zombies.push(Zombie(_name, _dna)) - 1; // (new length of array - 1)
        // Firing Event
        emit NewZombie(id, _name, _dna);
    }

    function _generateRandomDna(string memory _str) private view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus; // To make DNA only be 16 digits long
    }

    function createRandomZombie(string memory _name) public {
        uint randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    }

}

/*                             ------- NOTES -------
1. State variables are permanently stored in contract storage. This means they're
 written to the Ethereum blockchain. 

2. uint is actually an alias for uint256. uints with less bits — uint8, uint16, uint32, etc.

3. Solidity also supports an exponential operator, uint x = 5 ** 2; // equal to 5^2 = 25

4.Strings are used for arbitrary-length UTF-8 data. 

5. There are two types of arrays in Solidity: fixed arrays and dynamic arrays
    uint[2] fixedArray;
    uint[] dynamicArray;

6. Declare an array as public, Solidity will automatically create a getter method for it.
    Person[] public people;  // public data(anyone can read/get)
   Other contracts would then be able to read from, but not write to, this array. 

7.  memory is required for all reference types such as arrays, structs, mappings, and strings. 
Q) What is a reference type you ask?
Well, there are two ways in which you can pass an argument to a Solidity function:
By value, which means that the Solidity compiler creates a new copy of the parameter's value
and passes it to your function. This allows your function to modify the value without worrying
 that the value of the initial parameter gets changed.
By reference, which means that your function is called with a reference to the original variable.
Thus, if your function changes the value of the variable it receives, the value of the original
variable gets changed.

8. It's convention parameter variable names starts with underscore ( _ ) 

9. In Solidity, functions are public by default. only make public the functions you want to expose to the world.

10. only other functions within our contract will be able to call PRIVATE functions,
 it's convention to start private function names with an underscore (_).

11. view function, meaning it's only viewing the data but not modifying it.

12. pure functions, which means you're not even accessing any data in the app. 
This function doesn't even read from the state of the app — its return value depends
only on its function parameters. So in this case we would declare the function as pure.

13. Ethereum has the hash function keccak256 built in, which is a version of SHA3.
A hash function basically maps an input into a random 256-bit hexadecimal number.
 keccak256 expects a single parameter of type bytes. This means that we have to
 "pack" any parameters before calling keccak256

keccak256(abi.encodePacked("aaaab"));
Returned Value:
//6e91ec6b618bb462a4a6ee5aa2cb0e9cf30f7a052bb467b0ba58b8748c00d2e5

14. TypeCasting:
uint8 a = 5;
uint b = 6;
// throws an error because a * b returns a uint, not uint8:
uint8 c = a * b;
// we have to typecast b as a uint8 to make it work:
uint8 c = a * uint8(b);

15. Events are a way for your contract to communicate that something happened on the
 blockchain to your app front-end, which can be 'listening' for certain events 
 and take action when they happen.
 
 Example:

// declare the event
event IntegersAdded(uint x, uint y, uint result);

function add(uint _x, uint _y) public returns (uint) {
  uint result = _x + _y;
  // fire an event to let the app know the function was called:
  emit IntegersAdded(_x, _y, result);
  return result;
}
Your app front-end could then listen for the event. A javascript implementation would look something like:

YourContract.IntegersAdded(function(error, result) {
  // do something with result
})

*/
