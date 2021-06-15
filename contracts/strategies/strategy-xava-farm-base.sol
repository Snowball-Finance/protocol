// SPDX-License-Identifier: MIT
pragma solidity ^0.6.7;

import "./strategy-base.sol";
import "../interfaces/farming-xava.sol";

abstract contract StrategyXAVAFarmBase is StrategyBase {
    // Token addresses
    address public xava = 0xd1c3f94de7e5b45fa4edbba472491a9f4b166fc4;
    address public farmingXava = 0xE82AAE7fc62547BdFC36689D0A83dE36FF034A68;

    // WAVAX/<token1> pair
    address public token1;

    // How much XAVA tokens to keep?
    uint256 public keepXAVA = 0;
    uint256 public constant keepXAVAMax = 10000;

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
        // But ETH is a dark forest, and I wanna see how this plays out
        // i.e. will be be heavily frontrunned?
        //      if so, a new strategy will be deployed.

        // Collects XAVA tokens
        IFarmingXava(farmingXava).deposit(poolId, 0);
        uint256 _xava = IERC20(xava).balanceOf(address(this));
        if (_xava > 0) {
            // 10% is locked up for future gov
            uint256 _keepXAVA = _xava.mul(keepXAVA).div(keepXAVAMax);
            IERC20(xava).safeTransfer(
                IController(controller).treasury(),
                _keepXAVA
            );
            uint256 _swap = _xava.sub(_keepXAVA);
            IERC20(xava).safeApprove(xavaRouter, 0);
            IERC20(xava).safeApprove(xavaRouter, _swap);
            _swapXavaswap(xava, wavax, _swap);
        }

        // Swap half WAVAX for token1
        uint256 _wavax = IERC20(wavax).balanceOf(address(this));
        if (_wavax > 0) {
            _swapXavaswap(wavax, token1, _wavax.div(2));
        }

        // Adds in liquidity for ETH/token1
        _wavax = IERC20(wavax).balanceOf(address(this));
        uint256 _token1 = IERC20(token1).balanceOf(address(this));
        if (_wavax > 0 && _token1 > 0) {
            IERC20(token1).safeApprove(xavaRouter, 0);
            IERC20(token1).safeApprove(xavaRouter, _token1);

            UniswapRouterV2(xavaRouter).addLiquidity(
                wavax,
                token1,
                _wavax,
                _token1,
                0,
                0,
                address(this),
                now + 60
            );

            // Donates DUST
            IERC20(wavax).transfer(
                IController(controller).treasury(),
                IERC20(wavax).balanceOf(address(this))
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