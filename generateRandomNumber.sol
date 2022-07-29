// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;



contract generateRandomNumber {

    function getRandom() public view returns (uint [] memory) {
        // Generate a random number between 1 and 100:
        uint hasta = 100;
        uint randNonce = 0;
        uint random = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % hasta;
        randNonce++;
        uint random2 = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % hasta;

        uint [] memory numeros = new uint[](2);
        numeros[0]=random;
        numeros[1]=random2;
        return numeros;
    }

    function getMultiplesRandom(uint _numbersAmount,uint _initial,uint _limit) public view returns (uint [] memory) {
        require(_initial > 0,"_initial need to by > 0");
        require(_numbersAmount > 1,"_numbersAmount need to by minimun 1 value");
        require(_limit >_initial,"_limit need to by > to _initial");
        // Generate multiples random numbers between 1 and _limit:
        uint [] memory numeros = new uint[](_numbersAmount);
        uint control_initial = _initial;
        for(uint i=0;i<_numbersAmount;i++){
          uint random = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, control_initial))) % _limit;
          control_initial++;
          
          while(random < _initial){
            control_initial++;
            random = uint(keccak256(abi.encodePacked((block.timestamp+(i*7)), msg.sender, control_initial))) % _limit;
          }
           
          numeros[i]=random;
        }

        return numeros;
    }
}
