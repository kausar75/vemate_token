// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import  "./IBEP20.sol";
import  "./VestingToken.sol";
import "./IUniswapV2Router02.sol";
import "./IUniswapV2Factory.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Vemate is  IBEP20, Ownable{
    using SafeMath for uint256;

    string private  _name = "Vemate";
    string private _symbol = "VMC";

    uint8 private _decimals = 18;
    uint256 private _totalSupply = 150000000 * 10**_decimals; // 150 million;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFeeAndLock;
    mapping(address => uint256) private _addressToLastSwapTime;

    address public lpWallet;
    address public devWallet;
    address public marketingWallet;
    address public charityWallet;

    uint8 public lpFeePercent;
    uint8 public devFeePercent;
    uint8 public marketingFeePercent;
    uint8 public charityFeePercent;
    uint8 public constant maxTaxPercentage = 5;

    uint256 public lockedBetweenSells = 10;
    uint256 public lockedBetweenBuys = 10;
    bool private antiBot = true;

    constructor(address router, address lpAddress, address devAddress, address marketingAddress,address charityAddress){
        require(owner() != address(0), "Owner must be set");
        lpWallet = lpAddress;
        devWallet = devAddress;
        marketingWallet = marketingAddress;
        charityWallet = charityAddress;

        _isExcludedFromFeeAndLock[owner()] = true;
        _isExcludedFromFeeAndLock[lpWallet] = true;
        _isExcludedFromFeeAndLock[devWallet] = true;
        _isExcludedFromFeeAndLock[marketingWallet] = true;
        _isExcludedFromFeeAndLock[charityWallet] = true;
        _isExcludedFromFeeAndLock[address(this)] = true;

        lpFeePercent = 2;
        devFeePercent = 1;
        marketingFeePercent = 1;
        charityFeePercent = 1;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

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

        bool takeFee = false;
        uint256 currentTime = getCurrentTime();

        if (_isExcludedFromFeeAndLock[sender] || _isExcludedFromFeeAndLock[recipient]) {
            _tokenTransfer(sender, recipient, amount, takeFee);
        }else{
            // we need to collect tax only on selling token.
            if (recipient == uniswapV2Pair) {
                takeFee = true;
                if (antiBot) {
                    uint256 lastSwapTime = _addressToLastSwapTime[sender];
                    require(
                        currentTime - lastSwapTime >= lockedBetweenSells,
                        "Lock time has not been released from last swap"
                    );
                }
                _addressToLastSwapTime[sender] = currentTime;
            }
            if (sender == uniswapV2Pair) { // buy
                if (antiBot) {
                    uint256 lastSwapTime = _addressToLastSwapTime[recipient];
                    require(
                        currentTime - lastSwapTime >= lockedBetweenBuys,
                        "Lock time has not been released from last swap"
                    );
                }
                _addressToLastSwapTime[recipient] = currentTime;
            }
            _tokenTransfer(sender, recipient, amount, takeFee);
        }
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        uint256 transferAmount = amount;
        if (takeFee) {
            uint256 lpTax = amount.mul(lpFeePercent).div(10**2);
            uint256 devTax = amount.mul(devFeePercent).div(10**2);
            uint256 marketetingTax = amount.mul(marketingFeePercent).div(10**2);
            uint256 charityTax = amount.mul(charityFeePercent).div(10**2);

            // TODO: take BNB as tax not the token!
            _balances[lpWallet] = _balances[lpWallet].add(lpTax);
            emit Transfer(sender, lpWallet, lpTax);

            _balances[devWallet] = _balances[devWallet].add(devTax);
            emit Transfer(sender, devWallet, devTax);

            _balances[marketingWallet] = _balances[marketingWallet].add(marketetingTax);
            emit Transfer(sender, marketingWallet, marketetingTax);


            _balances[charityWallet] = _balances[charityWallet].add(charityTax);
            emit Transfer(sender, charityWallet, charityTax);

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

    function setRouterAddress(address newRouter) external onlyOwner {
        IUniswapV2Router02 _newPancakeRouter = IUniswapV2Router02(newRouter);
        IUniswapV2Factory factory = IUniswapV2Factory(
            _newPancakeRouter.factory()
        );
        address pair = factory.getPair(address(this), _newPancakeRouter.WETH());
        if (pair == address(0)) {
            uniswapV2Pair = factory.createPair(
                address(this),
                _newPancakeRouter.WETH()
            );
        } else {
            uniswapV2Pair = pair;
        }

        uniswapV2Router = _newPancakeRouter;

        emit UpdatePancakeRouter(uniswapV2Router, uniswapV2Pair);
    }

    function setLpAddress(address lpAddress) external onlyOwner {
        lpWallet = lpAddress;
        emit UpdateLpAddress(lpWallet);
    }

    function setDevAddress(address devAddress) external onlyOwner {
        devWallet = devAddress;
        emit UpdateDevAddress(devWallet);
    }

    function setMarketingAddress(address marketingAddress) external onlyOwner {
        marketingWallet = marketingAddress;
        emit UpdateMarketingAddress(marketingWallet);
    }

    function setCharityAddress(address charityAddress) external onlyOwner {
        charityWallet = charityAddress;
        emit UpdateCharityAddress(charityWallet);
    }

    function setLpTaxPercentage(uint8 lpTaxPercentage) external onlyOwner {
        lpFeePercent = lpTaxPercentage;
        emit UpdateLpTaxPercentage(lpFeePercent);
    }

    function setDevTaxPercentage(uint8 devTaxPercentage) external onlyOwner {
        devFeePercent = devTaxPercentage;
        emit UpdateDevTaxPercentage(devFeePercent);
    }

    function setMarketingTaxPercentage(uint8 marketingTaxPercentage) external onlyOwner {
        marketingFeePercent = marketingTaxPercentage;
        emit UpdateMarketingTaxPercentage(marketingFeePercent);
    }

    function setCharityTaxPercentage(uint8 charityTaxPercentage) external onlyOwner {
        charityFeePercent = charityTaxPercentage;
        emit UpdateCharityTaxPercentage(charityFeePercent);
    }

    function setLockTimeBetweenSells(uint256 newLockSeconds)
    external
    onlyOwner
    {
        require(
            newLockSeconds <= 30,
            "Time between sells must be less than 30 seconds"
        );
        uint256 _previous = lockedBetweenSells;
        lockedBetweenSells = newLockSeconds;

        emit UpdateLockedBetweenSells(lockedBetweenSells, _previous);
    }

    function setLockTimeBetweenBuys(uint256 newLockSeconds) external onlyOwner {
        require(
            newLockSeconds <= 30,
            "Time between buys be less than 30 seconds"
        );
        uint256 _previous = lockedBetweenBuys;
        lockedBetweenBuys = newLockSeconds;
        emit UpdateLockedBetweenBuys(lockedBetweenBuys, _previous);
    }

    function toggleAntiBot() external onlyOwner {
        antiBot = !antiBot;

        emit UpdateAntibotUpdated(antiBot);
    }

    function getCurrentTime()
    internal
    virtual
    view
    returns(uint256){
        return block.timestamp;
    }

    event UpdatePancakeRouter(IUniswapV2Router02 router, address pair);
    event UpdateLpAddress(address lpAddress);
    event UpdateDevAddress(address devAddress);
    event UpdateMarketingAddress(address marketAddress);
    event UpdateCharityAddress(address charityAddress);

    event UpdateLpTaxPercentage(uint8 lpTaxPercentage);
    event UpdateDevTaxPercentage(uint8 devTaxPercentage);
    event UpdateMarketingTaxPercentage(uint8 devTaxPercentage);
    event UpdateCharityTaxPercentage(uint8 charityTaxPercentage);

    event UpdateLockedBetweenBuys(uint256 cooldown, uint256 previous);
    event UpdateLockedBetweenSells(uint256 cooldown, uint256 previous);

    event UpdateAntibotUpdated(bool isEnabled);
}
