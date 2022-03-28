// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "./VemateToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Presale is Ownable{
    using SafeMath for uint256;

    Vemate immutable private vemate;

    bool private isInPresale;
    bool private isPresaleDone;
    bool private isPaused;

    uint256 private constant DAY = 24 * 60 * 60;
    uint256 private constant MONTH = DAY * 30;

    uint256 private presaledToken;
    uint256 private minimumPresaleToken;
    uint256 private maximumPresaleToken;

    constructor(address vemateToken){
        require(vemateToken != address(0x0));
        vemate = Vemate(vemateToken);
        require(owner() != address(0), "Owner must be set");

        isInPresale = false;
        isPresaleDone = false;
        isPaused = true;
    }

    function startPresale(uint256 minTokenPerSale, uint256 maxTokenPerSale) external onlyOwner {
        require(!isPresaleDone, "Presale finished");
        require(!isInPresale, "Already In Presale");

        isInPresale = true;
        isPaused = false;

        minimumPresaleToken = minTokenPerSale;
        maximumPresaleToken = maxTokenPerSale;
    }

    function stopPresale() external onlyOwner {
        require(isInPresale, "Presale not started");

        isInPresale = false;
        isPresaleDone = true;
    }

    function togglePausePresale() external onlyOwner {
        require(isInPresale, "Not in a Presale");
        isPaused = !isPaused;
    }



    /**
     * @notice sellTokenForVesting sells token to the buyers. token won't be sent to buyers wallet immediately, rather it will be unlock gradually and buyers need to claim it.
    * @param to to address of the buyer
    * @param tokenAmount amount of token to be sold
    * @param initialTokenUnlockTime timestamp of second from when token will start unlocking
    */
    function sellTokenForVesting(address to, uint256 tokenAmount, uint256 initialTokenUnlockTime) external onlyOwner{
        require(isInPresale, "Not in a Presale");
        require(!isPaused, "Presale is Paused");
        require(tokenAmount >= minimumPresaleToken, "Token is less than minimun");
        require(tokenAmount <= maximumPresaleToken, "Token is greater than maximum");
        require(getPresaleAmountLeft()>= tokenAmount, "Not enough amount left for sell");

        presaledToken.add(tokenAmount);

        uint256 time = getCurrentTime();

        // unlock 10% on initialTokenUnlockTime
        vemate.createVestingSchedule(to, time, initialTokenUnlockTime,tokenAmount.mul(10).div(100));
        // unlock another 10% on 21 days after initialTokenUnlockTime
        vemate.createVestingSchedule(to, time, initialTokenUnlockTime.add(DAY.mul(21)),tokenAmount.mul(10).div(100));
        // unlock another 10% on 60 days after initialTokenUnlockTime
        vemate.createVestingSchedule(to, time, initialTokenUnlockTime.add(MONTH.mul(2)),tokenAmount.mul(10).div(100));
        // unlock 15% on 90 days after initialTokenUnlockTime
        vemate.createVestingSchedule(to, time, initialTokenUnlockTime.add(MONTH.mul(3)),tokenAmount.mul(15).div(100));

        for (uint8 i = 1; i < 5; i++){
            // unlock 10% on each month
            vemate.createVestingSchedule(to, time, initialTokenUnlockTime.add(MONTH.mul(3+i)),tokenAmount.mul(15).div(100));
        }
        // unlock last 15% on 8th month after initialTokenUnlockTime
        vemate.createVestingSchedule(to, time, initialTokenUnlockTime.add(MONTH.mul(8)),tokenAmount.mul(15).div(100));
    }
    /**
    * @notice sellTokenForDeposit sells token to the buyers. buyers will be able to claim token with interest after deposit period.
    * only 10% token will be unlocked immediately
    * @param to to address of the buyer
    * @param tokenAmount amount of token to be sold
    * @param start timestamp of second from when deposite period will start
    * @param interestPercentage percentage of interest on tokenAmount buyers will get
    * @param periodMonth number of months after the token will fully unlock with interest
    */
    function sellTokenForDeposit(address to, uint256 tokenAmount, uint256 start, uint8 interestPercentage, uint64 periodMonth) external onlyOwner{
        require(isInPresale, "Not in a Presale");
        require(!isPaused, "Presale is Paused");
        require(tokenAmount >= minimumPresaleToken, "Token is less than minimun");
        require(tokenAmount <= maximumPresaleToken, "Token is greater than maximum");

        uint256 interest = tokenAmount.mul(interestPercentage).div(100);
        uint256 totalToken = tokenAmount.add(interest);

        require(getPresaleAmountLeft()>= totalToken, "Not enough amount left for sell");

        presaledToken.add(totalToken);

        uint256 time = getCurrentTime();
        uint256 tenPercentToken = tokenAmount.mul(10).div(100);
        uint256 tokenLocked = totalToken.sub(tenPercentToken);

        // unlock last 90% token and interest at the end of the period
        vemate.createVestingSchedule(to, time, start.add(MONTH.mul(periodMonth)),tokenLocked);

        // send 10% immediately
        vemate.transfer(to, tenPercentToken);
    }

    /**
    * @notice sellPrivate sell token to the buyers without vesting or deposit. Token will be sent immeditely to buyers address.
    * only 10% token will be unlocked immediately
    */
    function sellPrivate(address to, uint256 tokenAmount) external onlyOwner{
        require(tokenAmount>0, "Token amount must be greater than zero");
        require(getPresaleAmountLeft()>= tokenAmount, "Not enough amount left for sell");
        vemate.transfer(to, tokenAmount);
    }

    /**
    * @dev Returns the amount of tokens that can be withdrawn by the owner.
    * @return the amount of tokens
    */
    function getPresaleAmountLeft()
    public
    view
    returns(uint256){
        return vemate.balanceOf(address(this));
    }

    function getCurrentTime()
    internal
    virtual
    view
    returns(uint256){
        return block.timestamp;
    }
}