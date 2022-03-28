// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import  "./IBEP20.sol";
import  "./VestingToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Vemate is  IBEP20, Ownable, Vesting{
    using SafeMath for uint256;

    string private  _name = "Vemate";
    string private  _symbol = "VMC";

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;

    uint8 private  _decimals = 18;
    uint256 private _totalSupply;

    address private _lpAddress;
    address private _devAddress;
    address private _marketingAddress;
    address private _charityAddress;

    uint8 private _lpTaxPercentage;
    uint8 private _devTaxPercentage;
    uint8 private _marketingTaxPercentage;
    uint8 private _charityTaxPercentage;

    constructor(address lpAddress, address devAddress, address marketingAddress,address charityAddress){
        require(owner() != address(0), "Owner must be set");

        _name = "Vemate";
        _symbol = "VMC";
        _decimals = 18;
        _totalSupply = 15000000 * 10**_decimals;

        _lpAddress = lpAddress;
        _devAddress = devAddress;
        _marketingAddress = marketingAddress;
        _charityAddress = charityAddress;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[_lpAddress] = true;
        _isExcludedFromFee[_devAddress] = true;
        _isExcludedFromFee[_marketingAddress] = true;
        _isExcludedFromFee[_charityAddress] = true;
        _isExcludedFromFee[address(this)] = true;

        _lpTaxPercentage = 2;
        _devTaxPercentage = 1;
        _marketingTaxPercentage = 1;
        _charityTaxPercentage = 1;


        _balances[_msgSender()] = _totalSupply;

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
        _transfer(_msgSender(), recipient, amount);
        return true;
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
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
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
        require(amount > 0, "Transfer amount must be greater than zero");
        require(_balances[sender] >= amount, "BEP20: transfer amount exceeds balance");

        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            takeFee = false;
        }
        _tokenTransfer(sender, recipient, amount, takeFee);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        uint256 transferAmount = amount;
        if (takeFee) {
            uint256 lpTax = amount.mul(_lpTaxPercentage).div(10**2);
            uint256 devTax = amount.mul(_devTaxPercentage).div(10**2);
            uint256 marketetingTax = amount.mul(_marketingTaxPercentage).div(10**2);
            uint256 charityTax = amount.mul(_charityTaxPercentage).div(10**2);

            _balances[_lpAddress] = _balances[_lpAddress].add(lpTax);
            emit Transfer(sender, _lpAddress, lpTax);

            _balances[_devAddress] = _balances[_devAddress].add(devTax);
            emit Transfer(sender, _devAddress, devTax);

            _balances[_marketingAddress] = _balances[_marketingAddress].add(marketetingTax);
            emit Transfer(sender, _marketingAddress, marketetingTax);


            _balances[_charityAddress] = _balances[_charityAddress].add(charityTax);
            emit Transfer(sender, _charityAddress, charityTax);

            transferAmount = transferAmount.sub(lpTax.add(devTax).add(marketetingTax).add(charityTax));
        }
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(transferAmount);
        emit Transfer(sender, recipient, transferAmount);
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

    function claimWithdrawableAmount() external {
        uint256 amount = claim(_msgSender());
        _transfer(address(this),_msgSender(), amount);
    }

    function setLpAddress(address lpAddress) external onlyOwner {
        _lpAddress = lpAddress;
        emit UpdateLpAddress(_lpAddress);
    }

    function setDevAddress(address devAddress) external onlyOwner {
        _devAddress = devAddress;
        emit UpdateDevAddress(_devAddress);
    }

    function setMarketingAddress(address marketingAddress) external onlyOwner {
        _marketingAddress = marketingAddress;
        emit UpdateMarketingAddress(_marketingAddress);
    }

    function setCharityAddress(address charityAddress) external onlyOwner {
        _charityAddress = charityAddress;
        emit UpdateCharityAddress(_charityAddress);
    }

    function setLpTaxPercentage(uint8 lpTaxPercentage) external onlyOwner {
        _lpTaxPercentage = lpTaxPercentage;
        emit UpdateLpTaxPercentage(_lpTaxPercentage);
    }

    function setDevTaxPercentage(uint8 devTaxPercentage) external onlyOwner {
        _devTaxPercentage = devTaxPercentage;
        emit UpdateDevTaxPercentage(_devTaxPercentage);
    }

    function setMarketingTaxPercentage(uint8 marketingTaxPercentage) external onlyOwner {
        _marketingTaxPercentage = marketingTaxPercentage;
        emit UpdateMarketingTaxPercentage(_marketingTaxPercentage);
    }

    function setCharityTaxPercentage(uint8 charityTaxPercentage) external onlyOwner {
        _charityTaxPercentage = charityTaxPercentage;
        emit UpdateCharityTaxPercentage(_charityTaxPercentage);
    }

    event UpdateLpAddress(address lpAddress);
    event UpdateDevAddress(address devAddress);
    event UpdateMarketingAddress(address marketAddress);
    event UpdateCharityAddress(address charityAddress);

    event UpdateLpTaxPercentage(uint8 lpTaxPercentage);
    event UpdateDevTaxPercentage(uint8 devTaxPercentage);
    event UpdateMarketingTaxPercentage(uint8 devTaxPercentage);
    event UpdateCharityTaxPercentage(uint8 charityTaxPercentage);
}
