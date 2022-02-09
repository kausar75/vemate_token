// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
contract vemate {
    uint purchaseToken;
    uint purchasTime;
    mapping(address => uint) public unlockedToken;
}