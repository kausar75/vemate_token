// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import { Context } from "./Context.sol";
import { IBEP20 } from "./IBEP20.sol";
import { Ownable } from "./Ownable.sol";
import { SafeMath } from "./SafeMath.sol";

contract Vemate is Context, IBEP20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    mapping(address => uint256) private _balancesForStaking;

    uint8 private _decimals;
    uint256 private _totalSupply;
    string private _symbol;
    string private _name;

    uint private unlockedToken = 0;
    mapping(address => uint256) private purchaseToken;
    mapping(address => uint256) private purchasedTime;

    uint private rewardChecker = 0;
    bool lockYourBalance = false;

    mapping(address => uint256) private s;
    mapping (address => uint256) private t;
    mapping (address => uint256) private p;  

    constructor(){
        _name = "Vemate";
        _symbol = "VMC";
        _decimals = 7;
        _totalSupply = 15 * 10 ** (_decimals);
        _balances[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    /**
    * @dev Returns the bep token owner.
    */
    function getOwner() external override view returns (address) {
        return owner();
    }

    /**
    * @dev Returns the token decimals.
    */
    function decimals() external override view returns (uint8) {
        return _decimals;
    }

    /**
    * @dev Returns the token symbol.
    */
    function symbol() external override view returns (string memory) {
        return _symbol;
    }

    /**
    * @dev Returns the token name.
    */
    function name() external override view returns (string memory) {
        return _name;
    }

    /**
    * @dev See {BEP20-totalSupply}.
    */
    function totalSupply() external override view returns (uint256) {
        return _totalSupply;
    }

    modifier onlyTokenHolder(){
        require(msg.sender != 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, 'You are owner');
        _;
    }

    //calculate the unlocked token amount
    function unlockTokenChecker() internal onlyTokenHolder{
        
        uint cumulitive = p[msg.sender].sub(s[msg.sender]);

        //as the balances was adding the unlocked token amount with purchased token
        //that's why I was subtracting the purchase amount
        _balances[msg.sender] = _balances[msg.sender].sub(purchaseToken[msg.sender]);

        unlockedToken = (purchaseToken[msg.sender].mul(cumulitive)).div(100);
        _balances[msg.sender] = _balances[msg.sender].add(unlockedToken);

        t[msg.sender] = t[msg.sender].sub(cumulitive);
        s[msg.sender] = p[msg.sender];
    }
    
    function reloadBalance() public onlyTokenHolder{
        uint endTime = block.timestamp;
        uint timeDifference = endTime.sub(purchasedTime[msg.sender]);
        require(timeDifference > 0, 'There is no unlocked token to show');

        if(timeDifference >  0 && timeDifference <= 1814400){
            //from 1st day => first 10% of the token
            if(s[msg.sender]==10){
                _balances[msg.sender];
            }
            else{
                p[msg.sender] = 10;
                unlockTokenChecker();
                if(lockYourBalance==true){
                    _balancesForStaking[msg.sender] = purchaseToken[msg.sender];
                    _balances[msg.sender] = 0;
                    purchaseToken[msg.sender] = 0;
                    lockYourBalance = false;
                }
                else{
                    _balances[msg.sender];
                }
            }
        }
        else if(timeDifference > 1814400 && timeDifference <= 5184000){
            //21 days => 20% of the token
            if(s[msg.sender]==20){
                _balances[msg.sender];
            }
            else{
                p[msg.sender] = 20;
                unlockTokenChecker();
            }  
        }
        else if(timeDifference > 5184000 && timeDifference <= 7776000){
            //60 days => 30% of the token
            if(s[msg.sender]==30){
                _balances[msg.sender];
            }
            else{
                p[msg.sender] = 30;
                unlockTokenChecker();
            }
        }
        else if(timeDifference > 7776000 && timeDifference <= 10368000){
            //90 days => 45% of the token
            if(s[msg.sender]==45){
                _balances[msg.sender];
            }
            else{
                p[msg.sender] = 45;
                unlockTokenChecker();
            } 
        }
        else if(timeDifference > 10368000 && timeDifference <= 12960000){
            //120 days => 55% of the token
            if(s[msg.sender]==55){
                _balances[msg.sender];
            }
            else{
                p[msg.sender] = 55;
                unlockTokenChecker();
            } 
        }
        else if(timeDifference > 12960000 && timeDifference <= 15552000){
            //150 days => 65% of the token
            if(s[msg.sender]==65){
                _balances[msg.sender];
            }
            else{
                p[msg.sender] = 65;
                unlockTokenChecker();
            }
        }
        else if(timeDifference > 15552000 && timeDifference <= 18144000){
            //180 days => 75% of the token
            if(s[msg.sender]==75){
                _balances[msg.sender];
            }
            else{
                p[msg.sender] = 75;
                unlockTokenChecker();
            }
        }
        else if(timeDifference > 18144000 && timeDifference <= 20736000){
            //210 days => 85% of the token
            if(s[msg.sender]==85){
                _balances[msg.sender];
            }
            else{
                p[msg.sender] = 85;
                unlockTokenChecker();
            }
        }
        else if(timeDifference > 20736000 && timeDifference <= 31536000){
            //240 days => 100% of the token
            if(s[msg.sender]==100){
                _balances[msg.sender];
            }
            else{
                p[msg.sender] = 100;
                unlockTokenChecker();
            }
        }
    }

    function getReward() public onlyTokenHolder{
        uint endTime = block.timestamp;
        uint timeDifference = endTime.sub(purchasedTime[msg.sender]);

        if(timeDifference > 31536000){
            if(_balancesForStaking[msg.sender] > 0){
                if(rewardChecker == 0){
                    uint bonus = (_balancesForStaking[msg.sender].mul(27)).div(100);
                    _balancesForStaking[msg.sender] = _balancesForStaking[msg.sender].add(bonus);
                    _balances[msg.sender] = _balancesForStaking[msg.sender];
                    _balancesForStaking[msg.sender] = 0;
                    rewardChecker = 1;
                }
                else{
                    _balances[msg.sender];
                }
            }
            else{
                _balances[msg.sender];
            }

        }
    }

    /**
    * to see the unlocked balance without changing state
    */
    function UnlockedTokenBalance(address account) public view onlyTokenHolder returns(uint256){
        // mapping(address => uint256) private unlockBalance;
        uint unlockBalance;
        uint calculation_time = block.timestamp;
        uint t_difference = calculation_time.sub(purchasedTime[account]);

        if(t_difference >  0 && t_difference <= 1814400){
            //from 1st day => first 10% of the token
            unlockBalance = (purchaseToken[account].mul(10)).div(100);
            return unlockBalance;
        }
        else if(t_difference > 1814400 && t_difference <= 5184000){
            //21 days => 20% of the token
            unlockBalance = (purchaseToken[account].mul(20)).div(100);
            return unlockBalance; 
        }
        else if(t_difference > 5184000 && t_difference <= 7776000){
            //60 days => 30% of the token
            unlockBalance = (purchaseToken[account].mul(30)).div(100);
            return unlockBalance;
        }
        else if(t_difference > 7776000 && t_difference <= 10368000){
            //90 days => 45% of the token
            unlockBalance = (purchaseToken[account].mul(45)).div(100);
            return unlockBalance;
        }
        else if(t_difference > 10368000 && t_difference <= 12960000){
            //120 days => 55% of the token
            unlockBalance = (purchaseToken[account].mul(55)).div(100);
            return unlockBalance; 
        }
        else if(t_difference > 12960000 && t_difference <= 15552000){
            //150 days => 65% of the token
            unlockBalance = (purchaseToken[account].mul(65)).div(100);
            return unlockBalance;
        }
        else if(t_difference > 15552000 && t_difference <= 18144000){
            //180 days => 75% of the token
            unlockBalance = (purchaseToken[account].mul(75)).div(100);
            return unlockBalance;
        }
        else if(t_difference > 18144000 && t_difference <= 20736000){
            //210 days => 85% of the token
            unlockBalance = (purchaseToken[account].mul(85)).div(100);
            return unlockBalance;
        }
        else if(t_difference > 20736000 && t_difference <= 31536000){
            //240 days => 100% of the token
            unlockBalance = (purchaseToken[account].mul(100)).div(100);
            return unlockBalance;
        }

    }
    
    /**
    * @dev See {BEP20-balanceOf}.
    */
    function balanceOf(address account) external override view returns(uint256){
        return _balances[account];
    }

    /**
    * @dev See {BEP20-transfer}.
    *
    * Requirements:
    *
    * - `recipient` cannot be the zero address.
    * - the caller must have a balance of at least `amount`.
    */
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        if(msg.sender == 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4){
            //for owner of the vemate

            _transfer(_msgSender(), recipient, amount);

            t[recipient] = 100;
            s[recipient] = 0;
            p[recipient] = 0;

            purchaseToken[recipient] = amount;
            purchasedTime[recipient] = block.timestamp;
            return true;
        }else{
            //for token holder
            reloadBalance();
            getReward();
            if(recipient == 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4){
                uint256 lpTax = amount.mul(5).div(100);
                uint256 checkBalance = _balances[_msgSender()].add(lpTax);
                require(checkBalance > _balances[_msgSender()],'Balances are low');
                _transfer(_msgSender(), recipient, amount);
                _transfer(_msgSender(), recipient, lpTax);
                return true;

            }else{
                _transfer(_msgSender(), recipient, amount);
                return true;
            }   
        }
    }

    /**
    * @dev See {BEP20-allowance}.
    */
    function allowance(address owner, address spender) external override view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
    * @dev See {BEP20-approve}.
    *
    * Requirements:
    *
    * - `spender` cannot be the zero address.
    */
    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
    * @dev See {BEP20-transferFrom}.
    *
    * Emits an {Approval} event indicating the updated allowance. This is not
    * required by the EIP. See the note at the beginning of {BEP20};
    *
    * Requirements:
    * - `sender` and `recipient` cannot be the zero address.
    * - `sender` must have a balance of at least `amount`.
    * - the caller must have allowance for `sender`'s tokens of at least
    * `amount`.
    */
    function transferFrom(address sender, address recipient, uint256 amount) external override onlyTokenHolder returns (bool){
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    /**
    * @dev Atomically increases the allowance granted to `spender` by the caller.
    *
    * This is an alternative to {approve} that can be used as a mitigation for
    * problems described in {BEP20-approve}.
    *
    * Emits an {Approval} event indicating the updated allowance.
    *
    * Requirements:
    *
    * - `spender` cannot be the zero address.
    */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
    * @dev Atomically decreases the allowance granted to `spender` by the caller.
    *
    * This is an alternative to {approve} that can be used as a mitigation for
    * problems described in {BEP20-approve}.
    *
    * Emits an {Approval} event indicating the updated allowance.
    *
    * Requirements:
    *
    * - `spender` cannot be the zero address.
    * - `spender` must have allowance for the caller of at least
    * `subtractedValue`.
    */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    /**
    * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
    * the total supply.
    *
    * Requirements
    *
    * - `msg.sender` must be the token owner
    */
    function mint(uint256 amount) public onlyOwner returns (bool) {
        _mint(_msgSender(), amount);
        return true;
    }

    /**
    * @dev Moves tokens `amount` from `sender` to `recipient`.
    *
    * This is internal function is equivalent to {transfer}, and can be used to
    * e.g. implement automatic token fees, slashing mechanisms, etc.
    *
    * Emits a {Transfer} event.
    *
    * Requirements:
    *
    * - `sender` cannot be the zero address.
    * - `recipient` cannot be the zero address.
    * - `sender` must have a balance of at least `amount`.
    */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(_balances[sender] > amount, "Insufficient amount!");

        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
    * the total supply.
    *
    * Emits a {Transfer} event with `from` set to the zero address.
    *
    * Requirements
    *
    * - `to` cannot be the zero address.
    */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
    * @dev Destroys `amount` tokens from `account`, reducing the
    * total supply.
    *
    * Emits a {Transfer} event with `to` set to the zero address.
    *
    * Requirements
    *
    * - `account` cannot be the zero address.
    * - `account` must have at least `amount` tokens.
    */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
    * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
    *
    * This is internal function is equivalent to `approve`, and can be used to
    * e.g. set automatic allowances for certain subsystems, etc.
    *
    * Emits an {Approval} event.
    *
    * Requirements:
    *
    * - `owner` cannot be the zero address.
    * - `spender` cannot be the zero address.
    */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
    * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
    * from the caller's allowance.
    *
    * See {_burn} and {_approve}.
    */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
    }
}