// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
contract vemate {
    uint public purchaseToken = 1000;
    uint public purchasedTime = block.timestamp;
    uint public timeDifference = 0;
    string public name;
    string public symbol;
    uint unlockedToken;
    mapping(address => uint) public balances;

    event Transfer(address indexed from, address indexed to, uint amount);

    constructor(){
        name = "Vemate";
        symbol = "VMC";
        balances[msg.sender] = unlockedToken;
    }

    function transfer(address to, uint amount) public returns(bool){
        getBalance();
        require(balances[msg.sender] > amount, 'Insufficient amount');
        balances[to] += amount;
        balances[msg.sender] -= amount;

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function getBalance() public returns(uint) {
        uint endTime = block.timestamp;
        timeDifference = endTime - purchasedTime;
        require(timeDifference > 0, 'There is no unlocked token to show');

        if(timeDifference > 0 && timeDifference < 1814399){
            //from 1st day 
            unlockedToken = (purchaseToken * 10) / 100;
            balances[msg.sender] += unlockedToken;
            return unlockedToken;
        }
        else if(timeDifference > 1814400 && timeDifference < 5183999){
            //21 days
            unlockedToken = (purchaseToken * 20) / 100;
            balances[msg.sender] += unlockedToken;
            return unlockedToken;
        }
        else if(timeDifference > 5184000 && timeDifference < 7775999){
            //60 days
            unlockedToken = (purchaseToken * 30) / 100;
            balances[msg.sender] += unlockedToken;
            return unlockedToken;
        }
        else if(timeDifference > 7776000 && timeDifference < 10367999){
            //90 days
            unlockedToken = (purchaseToken * 45) / 100;
            balances[msg.sender] += unlockedToken;
            return unlockedToken;
        }
        else if(timeDifference > 10368000 && timeDifference < 12959999){
            //120 days
            unlockedToken = (purchaseToken * 55) / 100;
            balances[msg.sender] += unlockedToken;
            return unlockedToken;
        }
        else if(timeDifference > 12960000 && timeDifference < 15551999){
            //150 days
            unlockedToken = (purchaseToken * 65) / 100;
            balances[msg.sender] += unlockedToken;
            return unlockedToken;
        }
        else if(timeDifference > 15552000 && timeDifference < 18143999){
            //180 days
            unlockedToken = (purchaseToken * 75) / 100;
            balances[msg.sender] += unlockedToken;
            return unlockedToken;
        }
        else if(timeDifference > 18144000 && timeDifference < 20735999){
            //210 days
            unlockedToken = (purchaseToken * 85) / 100;
            balances[msg.sender] += unlockedToken;
            return unlockedToken;
        }
        else if(timeDifference > 20736000){
            //240 days
            unlockedToken = purchaseToken;
            balances[msg.sender] += unlockedToken;
            return unlockedToken;
        }
    }
}