// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "https://github.com/sadiq1971/sol-contracts/blob/main/lib/Ownable.sol";

contract Whitelist is Ownable{
    uint8 public constant version = 1;

    mapping (address => bool) private _isWhitelisted;

    function addAddress(address _address)
    public
    onlyOwner{
        require(_isWhitelisted[_address] != true);
        _isWhitelisted[_address] = true;
        emit Whitelisted(_address, true);
    }

    function removeAddress(address _address)
    public
    onlyOwner{
        require(_isWhitelisted[_address] != false);
        _isWhitelisted[_address] = false;
        emit Whitelisted(_address, false);
    }

    function isWhitelisted(address _address)
    public
    view
    returns (bool){
        return _isWhitelisted[_address];
    }

    event Whitelisted(address indexed account, bool isWhitelisted);
}