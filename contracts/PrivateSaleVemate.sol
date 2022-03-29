// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "./VemateToken.sol";
import "./VestingToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract PrivateSale is Ownable, Vesting{
    using SafeMath for uint256;

    Vemate immutable private vemate;

    bool public isInPrivateSale;
    bool public isPrivateSaleDone;
    bool public isPrivateSalePaused;

    uint256 private constant DAY = 24 * 60 * 60;
    uint256 private constant MONTH = DAY * 30;

    uint256 public totalSoldToken;
    uint256 public minimumPrivateSaleToken;
    uint256 public maximumPrivateSaleToken;
    uint256 public totalAmountInVesting;

    constructor(address vemateToken){
        require(vemateToken != address(0x0));
        vemate = Vemate(vemateToken);
        require(owner() != address(0), "Owner must be set");

        isInPrivateSale = false;
        isPrivateSaleDone = false;
        isPrivateSalePaused = true;
    }

    function startPrivateSale(uint256 minTokenPerSale, uint256 maxTokenPerSale) external onlyOwner {
        require(!isPrivateSaleDone, "PrivateSale finished");
        require(!isInPrivateSale, "Already In PrivateSale");

        isInPrivateSale = true;
        isPrivateSalePaused = false;

        minimumPrivateSaleToken = minTokenPerSale;
        maximumPrivateSaleToken = maxTokenPerSale;
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



    /**
    * @notice sellTokenForVesting sells token to the buyers. token won't be sent to buyers wallet immediately, rather it will be unlock gradually and buyers need to claim it.
    * @param to to address of the buyer
    * @param tokenAmount amount of token to be sold
    * @param initialTokenUnlockTime timestamp of second from when token will start unlocking
    */
    function sellTokenForVesting(address to, uint256 tokenAmount, uint256 initialTokenUnlockTime) external onlyOwner{
        require(isInPrivateSale, "Not in a PrivateSale");
        require(!isPrivateSalePaused, "PrivateSale is Paused");
        require(tokenAmount >= minimumPrivateSaleToken, "Token is less than minimun");
        require(tokenAmount <= maximumPrivateSaleToken, "Token is greater than maximum");
        require(getAmountLeftForPrivateSale()>= tokenAmount, "Not enough amount left for sell");

        totalSoldToken.add(tokenAmount);

        uint256 time = getCurrentTime();

        // unlock 10% on initialTokenUnlockTime
        createVestingSchedule(to, time, initialTokenUnlockTime,tokenAmount.mul(10).div(100));
        // unlock another 10% on 21 days after initialTokenUnlockTime
        createVestingSchedule(to, time, initialTokenUnlockTime.add(DAY.mul(21)),tokenAmount.mul(10).div(100));
        // unlock another 10% on 60 days after initialTokenUnlockTime
        createVestingSchedule(to, time, initialTokenUnlockTime.add(MONTH.mul(2)),tokenAmount.mul(10).div(100));
        // unlock 15% on 90 days after initialTokenUnlockTime
        createVestingSchedule(to, time, initialTokenUnlockTime.add(MONTH.mul(3)),tokenAmount.mul(15).div(100));

        for (uint8 i = 1; i < 5; i++){
            // unlock 10% on each month
            createVestingSchedule(to, time, initialTokenUnlockTime.add(MONTH.mul(3+i)),tokenAmount.mul(10).div(100));
        }
        // unlock last 15% on 8th month after initialTokenUnlockTime
        createVestingSchedule(to, time, initialTokenUnlockTime.add(MONTH.mul(8)),tokenAmount.mul(15).div(100));

        totalAmountInVesting.add(tokenAmount);
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
        require(isInPrivateSale, "Not in a PrivateSale");
        require(!isPrivateSalePaused, "PrivateSale is Paused");
        require(tokenAmount >= minimumPrivateSaleToken, "Token is less than minimum");
        require(tokenAmount <= maximumPrivateSaleToken, "Token is greater than maximum");

        uint256 interest = tokenAmount.mul(interestPercentage).div(100);
        uint256 totalToken = tokenAmount.add(interest);

        require(getAmountLeftForPrivateSale()>= totalToken, "Not enough amount left for sell");

        totalSoldToken.add(totalToken);
        uint256 time = getCurrentTime();
        createVestingSchedule(to, time, start.add(MONTH.mul(periodMonth)),totalToken);
        totalAmountInVesting.add(tokenAmount);
    }

    /**
    * @dev Returns the amount of tokens that can be withdrawn by the owner.
    * @return the amount of tokens
    */
    function getAmountLeftForPrivateSale()
    public
    view
    returns(uint256){
        return vemate.balanceOf(address(this)).sub(totalAmountInVesting);
    }

    /**
    * @dev Claim the withdrawable tokens
    * @return the amount of tokens
    */
    function claimWithdrawableAmount() external {
        uint256 amount = claim(_msgSender());
        vemate.transfer(_msgSender(), amount);
        totalAmountInVesting.sub(amount);
    }
}