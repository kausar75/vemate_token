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

    uint s = 0;
    uint t = 100;

    event Transfer(address indexed from, address indexed to, uint amount);

    constructor(){
        name = "Vemate";
        symbol = "VMC";
        balances[msg.sender] = unlockedToken;
    }

    function transfer(address payable to, uint amount) public returns(bool){
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

        if(timeDifference >  0 && timeDifference <= 1814400){
            //from 1st day => first 10% of the token
            if(s==10){
                balances[msg.sender];
            }
            else{
                uint p = 10;
                uint cumulitive = p - s;

                unlockedToken = (purchaseToken * cumulitive) / 100;
                balances[msg.sender] += unlockedToken;

                t -= cumulitive;
                s = p;
            }
        }
        else if(timeDifference > 1814400 && timeDifference <= 5184000){
            //21 days => 20% of the token
            if(s==20){
                balances[msg.sender];
            }
            else{
                uint p = 20;
                uint cumulitive = p - s;

                unlockedToken = (purchaseToken * cumulitive) / 100;
                balances[msg.sender] += unlockedToken;

                t -= cumulitive;
                s = p;
            }  
        }
        else if(timeDifference > 5184000 && timeDifference <= 7776000){
            //60 days => 30% of the token
            if(s==30){
                balances[msg.sender];
            }
            else{
                uint p = 30;
                uint cumulitive = p - s;

                unlockedToken = (purchaseToken * cumulitive) / 100;
                balances[msg.sender] += unlockedToken;

                t -= cumulitive;
                s = p;
            }
        }
        else if(timeDifference > 7776000 && timeDifference <= 10368000){
            //90 days => 45% of the token
            if(s==45){
                balances[msg.sender];
            }
            else{
                uint p = 45;
                uint cumulitive = p - s;

                unlockedToken = (purchaseToken * cumulitive) / 100;
                balances[msg.sender] += unlockedToken;

                t -= cumulitive;
                s = p;
            } 
        }
        else if(timeDifference > 10368000 && timeDifference <= 12960000){
            //120 days => 55% of the token
            if(s==55){
                balances[msg.sender];
            }
            else{
                uint p = 55;
                uint cumulitive = p - s;

                unlockedToken = (purchaseToken * cumulitive) / 100;
                balances[msg.sender] += unlockedToken;

                t -= cumulitive;
                s = p;
            } 
        }
        else if(timeDifference > 12960000 && timeDifference <= 15552000){
            //150 days => 65% of the token
            if(s==65){
                balances[msg.sender];
            }
            else{
                uint p = 65;
                uint cumulitive = p - s;

                unlockedToken = (purchaseToken * cumulitive) / 100;
                balances[msg.sender] += unlockedToken;

                t -= cumulitive;
                s = p;
            }
        }
        else if(timeDifference > 15552000 && timeDifference <= 18144000){
            //180 days => 75% of the token
            if(s==75){
                balances[msg.sender];
            }
            else{
                uint p = 75;
                uint cumulitive = p - s;

                unlockedToken = (purchaseToken * cumulitive) / 100;
                balances[msg.sender] += unlockedToken;

                t -= cumulitive;
                s = p;
            }
        }
        else if(timeDifference > 18144000 && timeDifference <= 20736000){
            //210 days => 85% of the token
            if(s==85){
                balances[msg.sender];
            }
            else{
                uint p = 85;
                uint cumulitive = p - s;

                unlockedToken = (purchaseToken * cumulitive) / 100;
                balances[msg.sender] += unlockedToken;

                t -= cumulitive;
                s = p;
            }
        }
        else if(timeDifference > 20736000 && timeDifference <= 31536000){
            //240 days => 100% of the token
            if(s==100){
                balances[msg.sender];
            }
            else{
                uint p = 100;
                uint cumulitive = p - s;

                unlockedToken = (purchaseToken * cumulitive) / 100;
                balances[msg.sender] += unlockedToken;

                t -= cumulitive;
                s = p;
            }
        }
        else if(timeDifference > 31536000){
            // for presale 01: calculating 27% bonus for the reservation of the token for per year
            uint p = 100;
            uint cumulitive = p - s;

            if(cumulitive == 0){
                uint requiredAmount = (balances[msg.sender] * 100) / purchaseToken; 

                if(requiredAmount >= 90){
                    uint yearDifference = timeDifference / (3600 * 24 * 365);
                    uint bonus = (balances[msg.sender] * 27 * yearDifference) / 100;
                    balances[msg.sender] += bonus;
                }
                else{
                    balances[msg.sender];
                }
            }
            else{
                unlockedToken = (purchaseToken * cumulitive) / 100;
                balances[msg.sender] += unlockedToken;

                uint requiredAmount = (balances[msg.sender] * 100) / purchaseToken; 

                if(requiredAmount >= 90){
                    uint yearDifference = timeDifference / (3600 * 24 * 365);
                    uint bonus = (balances[msg.sender] * 27 * yearDifference) / 100;
                    balances[msg.sender] += bonus;
                }
                else{
                    balances[msg.sender];
                }
            }
        }
    }
}