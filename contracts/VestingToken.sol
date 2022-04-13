// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "./VemateToken.sol";
import "./VestingToken.sol";
import "https://github.com/sadiq1971/sol-contracts/blob/main/lib/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PrivateSale is Ownable, Vesting{
    Vemate immutable private vemate;
    IERC20 immutable private erc20;

    bool public isInPrivateSale;
    bool public isPrivateSaleDone;
    bool public isPrivateSalePaused;

    uint256 private constant DAY = 24 * 60 * 60;
    uint256 private constant MONTH = DAY * 30;

    uint256 public totalSoldToken;
    uint256 public minimumPrivateSaleToken;
    uint256 public maximumPrivateSaleToken;
    uint256 public totalAmountInVesting;

    uint256 public initialTokenUnlockTime;

    uint256 public vematePerBUSD = 1000;

    uint8 private _decimals = 18;
    uint8 public interestPercentageForDeposit = 27;


    constructor(address payable vemateToken, address erc20Token){
        require(vemateToken != address(0x0));
        require(erc20Token != address(0x0));
        require(owner() != address(0), "Owner must be set");

        vemate = Vemate(vemateToken);
        erc20 = IERC20(erc20Token);

        isInPrivateSale = false;
        isPrivateSaleDone = false;
        isPrivateSalePaused = true;
    }

    function startPrivateSale(uint256 minTokenPerSale, uint256 maxTokenPerSale, uint256 initialTokenUnlkTime, uint8 _interestPercentageForDeposit) external onlyOwner {
        require(!isPrivateSaleDone, "PrivateSale finished");
        require(!isInPrivateSale, "Already In PrivateSale");

        isInPrivateSale = true;
        isPrivateSalePaused = false;

        minimumPrivateSaleToken = minTokenPerSale;
        maximumPrivateSaleToken = maxTokenPerSale;

        initialTokenUnlockTime = initialTokenUnlkTime;

        interestPercentageForDeposit = _interestPercentageForDeposit;
    }

    function stopPrivateSale() external onlyOwner {
        require(isInPrivateSale, "PrivateSale not started");

        isInPrivateSale = false;
        isPrivateSaleDone = true;
    }

    function togglePausePrivateSale() external onlyOwner {
        require(isInPrivateSale, "Not in a PrivateSale");
        isPrivateSalePaused = !isPrivateSalePaused;
    }

    // function updatePrice(uint256 _vematePerBUSD) external onlyOwner{
    //     vematePerBUSD = _vematePerBUSD;
    // }

    function updateVematePrice(uint256 _vematePerBUSD) external onlyOwner{
        vematePerBUSD = _vematePerBUSD;
    }

    /**
    * @notice buyTokenForVesting is to buy token. token won't be sent to buyers wallet immediately, rather it will be unlock gradually and buyers need to claim it.
    * @param tokenAmount amount of token to be sold
    */
    function buyTokenForVesting(uint256 tokenAmount) external{
        address to = _msgSender();
        require(to != address(0), "Not a valid address");
        require(isInPrivateSale, "Not in a PrivateSale");
        require(!isPrivateSalePaused, "PrivateSale is Paused");
        require(tokenAmount >= minimumPrivateSaleToken, "Token is less than minimum");
        require(tokenAmount <= maximumPrivateSaleToken, "Token is greater than maximum");
        require(getAmountLeftForPrivateSale()>= tokenAmount, "Not enough amount left for sell");

        // check balance of the buyer
        uint256 priceInBUSD = tokenAmount/vematePerBUSD;
        require(erc20.balanceOf(to) >= priceInBUSD, "Not enough busd token on balance");



        uint256 time = getCurrentTime();
        // unlock 10% on initialTokenUnlockTime
        createVestingSchedule(to, time, initialTokenUnlockTime, (tokenAmount*10)/100);
        // unlock another 10% on 21 days after initialTokenUnlockTime
        createVestingSchedule(to, time, initialTokenUnlockTime + (DAY*21), (tokenAmount*10)/100);
        // unlock another 10% on 60 days after initialTokenUnlockTime
        createVestingSchedule(to, time, initialTokenUnlockTime + (MONTH*2), (tokenAmount*10)/100);
        // unlock 15% on 90 days after initialTokenUnlockTime
        createVestingSchedule(to, time, initialTokenUnlockTime + (MONTH*3), (tokenAmount*15)/100);

        for (uint8 i = 1; i < 5; i++){
            // unlock 10% on each month
            createVestingSchedule(to, time, initialTokenUnlockTime + (MONTH*(3+i)), (tokenAmount*10)/100);
        }
        // unlock last 15% on 8th month after initialTokenUnlockTime
        createVestingSchedule(to, time, initialTokenUnlockTime + (MONTH*8), (tokenAmount*15)/100);

        totalAmountInVesting += tokenAmount;
        totalSoldToken += tokenAmount;
        erc20.transferFrom(to, address(this), priceInBUSD);
    }
    /**
    * @notice sellTokenForDeposit sells token to the buyers. buyers will be able to claim token with interest after deposit period.
    * only 10% token will be unlocked immediately
    * @param tokenAmount amount of token to be sold
    */
    function buyTokenForDeposit(uint256 tokenAmount) external{
        address to = _msgSender();
        require(to != address(0), "Not a valid address");
        require(isInPrivateSale, "Not in a PrivateSale");
        require(!isPrivateSalePaused, "PrivateSale is Paused");
        require(tokenAmount >= minimumPrivateSaleToken, "Token is less than minimum");
        require(tokenAmount <= maximumPrivateSaleToken, "Token is greater than maximum");
        require(getAmountLeftForPrivateSale()>= tokenAmount, "Not enough amount left for sell");

        // check balance of the buyer
        uint256 priceInBUSD = tokenAmount/vematePerBUSD;
        require(erc20.balanceOf(to) >= priceInBUSD, "Not enough usdt token on balance");

        uint256 interest = (tokenAmount*interestPercentageForDeposit)/100;
        uint256 totalToken = tokenAmount += interest;

        require(getAmountLeftForPrivateSale()>= totalToken, "Not enough amount left for sell");

        totalSoldToken+= totalToken;
        uint256 time = getCurrentTime();
        createVestingSchedule(to, time, time + (MONTH*12), totalToken);
        totalAmountInVesting += tokenAmount;
        erc20.transferFrom(to, address(this), priceInBUSD);
    }

    function balanceBUSD() external view onlyOwner returns(uint256){
        return erc20.balanceOf(address(this));
    }

    function withdrawBUSD(uint256 amount, address where) external onlyOwner{
        require(where != address(0), "cannot withdraw to a zero address");
        require(erc20.balanceOf(address(this)) >= amount, "not enough balance");
        erc20.transfer(where, amount);
    }

    function withdrawToken(uint256 amount, address where) external onlyOwner{
        require(where != address(0), "cannot withdraw to a zero address");
        require(vemate.balanceOf(address(this)) >= amount, "not enough balance");
        vemate.transfer(where, amount);
    }

    /**
    * @dev Returns the amount of tokens that can be withdrawn by the owner.
    * @return the amount of tokens
    */
    function getAmountLeftForPrivateSale() public view returns(uint256){
        return vemate.balanceOf(address(this)) - totalAmountInVesting;
    }

    /**
    * @dev Claim the withdrawable tokens
    */
    function claimWithdrawableAmount() external {
        uint256 amount = claim(_msgSender());
        vemate.transfer(_msgSender(), amount);
        totalAmountInVesting -= amount;
    }

    receive() external payable {}
}