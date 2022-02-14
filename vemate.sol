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
        require(balances[msg.sender] > amount, 'Insufficient amount!');
        balances[to] += amount;
        balances[msg.sender] -= amount;

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function getBalance() public{
        uint endTime = block.timestamp;
        timeDifference = endTime - purchasedTime;
        require(timeDifference > 0, 'There is no unlocked token to show');

        if(timeDifference > 0 && timeDifference <= 1814400){
            //from 1st day 
            unlockedToken = (purchaseToken * 10) / 100;
            balances[msg.sender] += unlockedToken;
        }
        else if(timeDifference > 1814401 && timeDifference <= 5184000){
            //21 days
            unlockedToken = (purchaseToken * 20) / 100;
            balances[msg.sender] += unlockedToken;
        }
        else if(timeDifference > 5184001 && timeDifference <= 7776000){
            //60 days
            unlockedToken = (purchaseToken * 30) / 100;
            balances[msg.sender] += unlockedToken;
        }
        else if(timeDifference > 7776001 && timeDifference <= 10368000){
            //90 days
            unlockedToken = (purchaseToken * 45) / 100;
            balances[msg.sender] += unlockedToken;
        }
        else if(timeDifference > 10368001 && timeDifference <= 12960000){
            //120 days
            unlockedToken = (purchaseToken * 55) / 100;
            balances[msg.sender] += unlockedToken;
        }
        else if(timeDifference > 12960001 && timeDifference <= 15552000){
            //150 days
            unlockedToken = (purchaseToken * 65) / 100;
            balances[msg.sender] += unlockedToken;
        }
        else if(timeDifference > 15552001 && timeDifference <= 18144000){
            //180 days
            unlockedToken = (purchaseToken * 75) / 100;
            balances[msg.sender] += unlockedToken;
        }
        else if(timeDifference > 18144001 && timeDifference <= 20736000){
            //210 days
            unlockedToken = (purchaseToken * 85) / 100;
            balances[msg.sender] += unlockedToken;
        }
        else if(timeDifference > 20736001 && timeDifference <= 31536000){
            //240 days
            unlockedToken = purchaseToken;
            balances[msg.sender] += unlockedToken;
        }
        else if(timeDifference > 31536001){
            // calculating 27% bonus for the reservation of the token for one year
            uint yearDifference = timeDifference / (3600 * 24 * 365);
            uint bonus = (purchaseToken * 27 * yearDifference) / 100;
            balances[msg.sender] = purchaseToken + bonus;
        }
    }
}