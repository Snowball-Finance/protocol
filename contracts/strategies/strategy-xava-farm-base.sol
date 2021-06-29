// SPDX-License-Identifier: MIT
pragma solidity ^0.6.7;

import "./strategy-base.sol";
import "../interfaces/farming-xava.sol";

abstract contract StrategyXAVAFarmBase is StrategyBase {
    // Token addresses
    address public constant xava = 0xd1c3f94DE7e5B45fa4eDBBA472491a9f4B166FC4;
    address public constant farmingXava = 0xE82AAE7fc62547BdFC36689D0A83dE36FF034A68;
    
    // within the XAVA/<token1> pair
    address public token1;

    // How much XAVA tokens to keep?
    uint256 public keepXAVA = 0;
    uint256 public constant keepXAVAMax = 10000;

    uint256 public poolId;

    constructor(
        address _token1,
        uint256 _poolId,
        address _lp,
        address _governance,
        address _strategist,
        address _controller,
        address _timelock
    )
        public
        StrategyBase(
            _lp,
            _governance,
            _strategist,
            _controller,
            _timelock
        )
    {
        poolId = _poolId;
        token1 = _token1;
    }

    function balanceOfPool() public override view returns (uint256) {
        (uint256 amount, ) = IFarmingXava(farmingXava).userInfo(poolId, address(this));
        return amount;
    }

    function getHarvestable() external view returns (uint256) {
        return IFarmingXava(farmingXava).pending(poolId, address(this));
    }

    // **** Setters ****

    function deposit() public override {
        uint256 _want = IERC20(want).balanceOf(address(this));
        if (_want > 0) {
            IERC20(want).safeApprove(farmingXava, 0);
            IERC20(want).safeApprove(farmingXava, _want);
            IFarmingXava(farmingXava).deposit(poolId, _want);
        }
    }

    function _withdrawSome(uint256 _amount)
        internal
        override
        returns (uint256)
    {
        IFarmingXava(farmingXava).withdraw(poolId, _amount);
        return _amount;
    }

    function setKeepXAVA(uint256 _keepXAVA) external {
        require(msg.sender == timelock, "!timelock");
        keepXAVA = _keepXAVA;
    }

    // **** State Mutations ****

    function harvest() public override onlyBenevolent {
        // Anyone can harvest it at any given time.
        // I understand the possibility of being frontrun
        // But AVAX is a dark forest, and I wanna see how this plays out
        // i.e. will be be heavily frontrunned?
        //      if so, a new strategy will be deployed.

        // Collects XAVA tokens
        IFarmingXava(farmingXava).withdraw(poolId, 0);
        uint256 _xava = IERC20(xava).balanceOf(address(this));
        if (_xava > 0) {
            // 10% is locked up for future gov
            uint256 _keepXAVA = _xava.mul(keepXAVA).div(keepXAVAMax);
            if (_keepXAVA > 0) {
                IERC20(xava).safeTransfer(
                    IController(controller).treasury(),
                    _keepXAVA
                );
            }
            // Swap half XAVA for token1
            uint256 _swap = IERC20(xava).balanceOf(address(this));
            _swapXava(xava, token1, _swap.div(2));

            // Adds in liquidity for XAVA/token1
            _xava = IERC20(xava).balanceOf(address(this));
            uint256 _token1 = IERC20(token1).balanceOf(address(this));
            if (_xava > 0 && _token1 > 0) {
                IERC20(xava).safeApprove(pangolinRouter, 0);
                IERC20(xava).safeApprove(pangolinRouter, _xava);

                IERC20(token1).safeApprove(pangolinRouter, 0);
                IERC20(token1).safeApprove(pangolinRouter, _token1);

                IPangolinRouter(pangolinRouter).addLiquidity(
                    xava,
                    token1,
                    _xava,
                    _token1,
                    0,
                    0,
                    address(this),
                    now + 60
                );

                // Donates DUST
                IERC20(xava).transfer(
                    IController(controller).treasury(),
                    IERC20(xava).balanceOf(address(this))
                );
                IERC20(token1).safeTransfer(
                    IController(controller).treasury(),
                    IERC20(token1).balanceOf(address(this))
                );
            }

            // We want to get back XAVA LP tokens
            _distributePerformanceFeesAndDeposit();
        }
    }

    function _swapXava(
        address _from,
        address _to,
        uint256 _amount
    ) internal {
        require(_to != address(0));

        address[] memory path;

        if (_from == xava || _to == xava) { // now assuming xava
            path = new address[](2);
            path[0] = _from;
            path[1] = _to;
        } else {
            path = new address[](3);
            path[0] = _from;
            path[1] = wavax; // if neither token is xava, it should still use wavax as intermediary
            path[2] = _to;
        }

        IPangolinRouter(pangolinRouter).swapExactTokensForTokens(
            _amount,
            0,
            path,
            address(this),
            now.add(60)
        );
    }

}