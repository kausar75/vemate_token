// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
contract vemate {
    uint public purchaseToken = 10000000000;
    uint purchasedTime = block.timestamp;
    string public name = "Vemate";
    string public symbol = "VMC";
    mapping(address => uint) public unlockedToken;

    event Transfer(address indexed from, address indexed to, uint amount);

    constructor(){
        unlockedToken[msg.sender] = purchaseToken * 10 / 100;  
    }

    function transfer(address to, uint amount) public returns(bool){
        //have to call getBalance method
        require(unlockedToken[msg.sender] > amount, 'Insufficient amount');
        unlockedToken[to] += amount;
        unlockedToken[msg.sender] -= amount;

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function getBalance(address owner) public returns(uint) {
        uint endTime = block.timestamp;
        require(endTime > purchasedTime, 'There is no unlocked token to show');
        uint dayDifference = (endTime - purchasedTime) / (3600*24);

        if(dayDifference > 21){
            unlockedToken[msg.sender] = purchaseToken * 20 / 100;
            return unlockedToken[msg.sender];
        }
        else if(dayDifference > 60){
            unlockedToken[msg.sender] = purchaseToken * 30 / 100;
            return unlockedToken[msg.sender];
        }
        else if(dayDifference > 90){
            unlockedToken[msg.sender] = purchaseToken * 45 / 100;
            return unlockedToken[msg.sender];
        }
        else if(dayDifference > 120){
            unlockedToken[msg.sender] = purchaseToken * 55 / 100;
            return unlockedToken[msg.sender];
        }
        else if(dayDifference > 150){
            unlockedToken[msg.sender] = purchaseToken * 65 / 100;
            return unlockedToken[msg.sender];
        }
        else if(dayDifference > 180){
            unlockedToken[msg.sender] = purchaseToken * 75 / 100;
            return unlockedToken[msg.sender];
        }
        else if(dayDifference > 210){
            unlockedToken[msg.sender] = purchaseToken * 85 / 100;
            return unlockedToken[msg.sender];
        }
        else{
            unlockedToken[msg.sender] = purchaseToken;
            return unlockedToken[msg.sender];
        }
    }
}