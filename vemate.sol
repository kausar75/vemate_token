// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
contract vemate {
    uint purchaseToken;
    uint purchasedTime = block.timestamp;
    uint unlockedToken;
    //mapping(address => uint) public unlockedToken;

    function getBalance(address owner) public returns(uint) {
        uint endTime = block.timestamp;
        require(endTime > purchasedTime, 'There is no unlocked token to show');
        uint dayDifference = (endTime - purchasedTime) / (3600*24);

        if(dayDifference > 0) {
            unlockedToken = purchaseToken * 10 / 100;
            return unlockedToken;
        }
        else if(dayDifference > 21){
            unlockedToken = purchaseToken * 20 / 100;
            return unlockedToken;
        }
        else if(dayDifference > 60){
            unlockedToken = purchaseToken * 30 / 100;
            return unlockedToken;
        }
        else if(dayDifference > 90){
            unlockedToken = purchaseToken * 45 / 100;
            return unlockedToken;
        }
        else if(dayDifference > 120){
            unlockedToken = purchaseToken * 55 / 100;
            return unlockedToken;
        }
        else if(dayDifference > 150){
            unlockedToken = purchaseToken * 65 / 100;
            return unlockedToken;
        }
        else if(dayDifference > 180){
            unlockedToken = purchaseToken * 75 / 100;
            return unlockedToken;
        }
        else if(dayDifference > 210){
            unlockedToken = purchaseToken * 85 / 100;
            return unlockedToken;
        }
        else{
            unlockedToken = purchaseToken;
            return unlockedToken;
        }
    }
}