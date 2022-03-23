// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

interface IBEP20 {
    /**
    * @dev Returns the amount of tokens in existence.
    */
    function totalSupply() external view returns (uint256);

    /**
    * @dev Returns the token decimals.
    */
    function decimals() external view returns (uint8);
    
    /**
    * @dev Returns the token symbol.
    */
    function symbol() external view returns (string memory);

    /**
    * @dev Returns the token name.
    */
    function name() external view returns (string memory);

    /**
    * @dev Returns the bep token owner.
    */
    function getOwner() external view returns (address);

    /**
    * @dev Returns the amount of tokens owned by `account`.
    */
    function balanceOf(address account) external view returns(uint256);

    /**
    * @dev Moves `amount` tokens from the caller's account to `recipient`.
    *
    * Returns a boolean value indicating whether the operation succeeded.
    *
    * Emits a {Transfer} event.
    */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
    * @dev Returns the remaining number of tokens that `spender` will be
    * allowed to spend on behalf of `owner` through {transferFrom}. This is
    * zero by default.
    *
    * This value changes when {approve} or {transferFrom} are called.
    */
    function allowance(address _owner, address spender) external view returns (uint256);

    /**
    * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
    *
    * Returns a boolean value indicating whether the operation succeeded.
    *
    * IMPORTANT: Beware that changing an allowance with this method brings the risk
    * that someone may use both the old and the new allowance by unfortunate
    * transaction ordering. One possible solution to mitigate this race
    * condition is to first reduce the spender's allowance to 0 and set the
    * desired value afterwards:
    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    *
    * Emits an {Approval} event.
    */

    function approve(address spender, uint256 amount) external returns (bool);
    /**
    * @dev Moves `amount` tokens from `sender` to `recipient` using the
    * allowance mechanism. `amount` is then deducted from the caller's
    * allowance.
    *
    * Returns a boolean value indicating whether the operation succeeded.
    *
    * Emits a {Transfer} event.
    */
    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
    * @dev Emitted when `value` tokens are moved from one account (`from`) to
    * another (`to`).
    *
    * Note that `value` may be zero.
    */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
    * @dev Emitted when the allowance of a `spender` for an `owner` is set by
    * a call to {approve}. `value` is the new allowance.
    */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

    /*
    * @dev Provides information about the current execution context, including the
    * sender of the transaction and its data. While these are generally available
    * via msg.sender and msg.data, they should not be accessed in such a direct
    * manner, since when dealing with GSN meta-transactions the account sending and
    * paying for execution may not be the actual sender (as far as an application
    * is concerned).
    *
    * This contract is only required for intermediate, library-like contracts.
    */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    
    constructor () { }

    function _msgSender()  public view returns (address) {
        return(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

    /**
    * @dev Wrappers over Solidity's arithmetic operations with added overflow
    * checks.
    *
    * Arithmetic operations in Solidity wrap on overflow. This can easily result
    * in bugs, because programmers usually assume that an overflow raises an
    * error, which is the standard behavior in high level programming languages.
    * `SafeMath` restores this intuition by reverting the transaction when an
    * operation overflows.
    *
    * Using this library instead of the unchecked operations eliminates an entire
    * class of bugs, so it's recommended to use it always.
    */
library SafeMath{
    /**
    * @dev Returns the addition of two unsigned integers, reverting on
    * overflow.
    *
    * Counterpart to Solidity's `+` operator.
    *
    * Requirements:
    * - Addition cannot overflow.
    */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;    
    }

    /**
    * @dev Returns the subtraction of two unsigned integers, reverting on
    * overflow (when the result is negative).
    *
    * Counterpart to Solidity's `-` operator.
    *
    * Requirements:
    * - Subtraction cannot overflow.
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
    * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
    * overflow (when the result is negative).
    *
    * Counterpart to Solidity's `-` operator.
    *
    * Requirements:
    * - Subtraction cannot overflow.
    */

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Returns the multiplication of two unsigned integers, reverting on
    * overflow.
    *
    * Counterpart to Solidity's `*` operator.
    *
    * Requirements:
    * - Multiplication cannot overflow.
    */

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
    if (a == 0) {
        return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
    }

    /**
    * @dev Returns the integer division of two unsigned integers. Reverts on
    * division by zero. The result is rounded towards zero.
    *
    * Counterpart to Solidity's `/` operator. Note: this function uses a
    * `revert` opcode (which leaves remaining gas untouched) while Solidity
    * uses an invalid opcode to revert (consuming all remaining gas).
    *
    * Requirements:
    * - The divisor cannot be zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
    * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
    * division by zero. The result is rounded towards zero.
    *
    * Counterpart to Solidity's `/` operator. Note: this function uses a
    * `revert` opcode (which leaves remaining gas untouched) while Solidity
    * uses an invalid opcode to revert (consuming all remaining gas).
    *
    * Requirements:
    * - The divisor cannot be zero.
    */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
    * Reverts when dividing by zero.
    *
    * Counterpart to Solidity's `%` operator. This function uses a `revert`
    * opcode (which leaves remaining gas untouched) while Solidity uses an
    * invalid opcode to revert (consuming all remaining gas).
    *
    * Requirements:
    * - The divisor cannot be zero.
    */

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
    * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
    * Reverts with custom message when dividing by zero.
    *
    * Counterpart to Solidity's `%` operator. This function uses a `revert`
    * opcode (which leaves remaining gas untouched) while Solidity uses an
    * invalid opcode to revert (consuming all remaining gas).
    *
    * Requirements:
    * - The divisor cannot be zero.
    */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

    /**
    * @dev Contract module which provides a basic access control mechanism, where
    * there is an account (an owner) that can be granted exclusive access to
    * specific functions.
    *
    * By default, the owner account will be the one that deploys the contract. This
    * can later be changed with {transferOwnership}.
    *
    * This module is used through inheritance. It will make available the modifier
    * `onlyOwner`, which can be applied to your functions to restrict their use to
    * the owner.
    */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */

    constructor (){
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
    * @dev Returns the address of the current owner.
    */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
    * @dev Leaves the contract without owner. It will not be possible to call
    * `onlyOwner` functions anymore. Can only be called by the current owner.
    *
    * NOTE: Renouncing ownership will leave the contract without an owner,
    * thereby removing any functionality that is only available to the owner.
    */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
    * @dev Transfers ownership of the contract to a new account (`newOwner`).
    * Can only be called by the current owner.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
    * @dev Transfers ownership of the contract to a new account (`newOwner`).
    */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

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
    /**
    * Here I reduced time for testing purpose
    * I assumed 21 days =   50
                60 days =  100
                90 days =  150
                120 days = 200
                150 days = 250
                180 days = 300
                210 days = 350
                240 days = 400
    */
    
    function reloadBalance() public onlyTokenHolder{
        uint endTime = block.timestamp;
        uint timeDifference = endTime.sub(purchasedTime[msg.sender]);
        require(timeDifference > 0, 'There is no unlocked token to show');

        // if(timeDifference >  0 && timeDifference <= 1814400){
        if(timeDifference> 0 && timeDifference <= 50){
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
        // else if(timeDifference > 1814400 && timeDifference <= 5184000){
        else if(timeDifference > 50 && timeDifference <= 100){
            //21 days => 20% of the token
            if(s[msg.sender]==20){
                _balances[msg.sender];
            }
            else{
                p[msg.sender] = 20;
                unlockTokenChecker();
            }  
        }
        // else if(timeDifference > 5184000 && timeDifference <= 7776000){
        else if(timeDifference > 100 && timeDifference <= 150){
            //60 days => 30% of the token
            if(s[msg.sender]==30){
                _balances[msg.sender];
            }
            else{
                p[msg.sender] = 30;
                unlockTokenChecker();
            }
        }
        // else if(timeDifference > 7776000 && timeDifference <= 10368000){
        else if(timeDifference > 150 && timeDifference <= 200){
            //90 days => 45% of the token
            if(s[msg.sender]==45){
                _balances[msg.sender];
            }
            else{
                p[msg.sender] = 45;
                unlockTokenChecker();
            } 
        }
        // else if(timeDifference > 10368000 && timeDifference <= 12960000){
        else if(timeDifference > 200 && timeDifference <= 250){
            //120 days => 55% of the token
            if(s[msg.sender]==55){
                _balances[msg.sender];
            }
            else{
                p[msg.sender] = 55;
                unlockTokenChecker();
            } 
        }
        // else if(timeDifference > 12960000 && timeDifference <= 15552000){
        else if(timeDifference > 250 && timeDifference <= 300){
            //150 days => 65% of the token
            if(s[msg.sender]==65){
                _balances[msg.sender];
            }
            else{
                p[msg.sender] = 65;
                unlockTokenChecker();
            }
        }
        // else if(timeDifference > 15552000 && timeDifference <= 18144000){
        else if(timeDifference > 350 && timeDifference <= 400){
            //180 days => 75% of the token
            if(s[msg.sender]==75){
                _balances[msg.sender];
            }
            else{
                p[msg.sender] = 75;
                unlockTokenChecker();
            }
        }
        // else if(timeDifference > 18144000 && timeDifference <= 20736000){
        else if(timeDifference > 400 && timeDifference <= 450){
            //210 days => 85% of the token
            if(s[msg.sender]==85){
                _balances[msg.sender];
            }
            else{
                p[msg.sender] = 85;
                unlockTokenChecker();
            }
        }
        // else if(timeDifference > 20736000 && timeDifference <= 31536000){
        else if(timeDifference > 450){
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

        if(timeDifference > 500){
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
            t[recipient] = 100;
            s[recipient] = 0;
            p[recipient] = 0;

            _transfer(_msgSender(), recipient, amount);

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