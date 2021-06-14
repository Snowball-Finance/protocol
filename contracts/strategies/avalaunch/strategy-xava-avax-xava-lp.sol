// SPDX-License-Identifier: MIT
pragma solidity ^0.6.7;

import "../strategy-xava-farm-base.sol";

contract StrategyXavaAvaxXavaLp is StrategyXAVAFarmBase {
    // Token/ETH pool id in MasterChef contract
    uint256 public avax_xava_poolId = 2; //check in with bmino on this
    // Token addresses
    address public xava_avax_xava_lp = 0x42152bDD72dE8d6767FE3B4E17a221D6985E8B25;
    address public avax = 0xb31f66aa3c1e785363f0875a1b74e27b85fd66c7;

    constructor(
        address _governance,
        address _strategist,
        address _controller,
        address _timelock
    )
        public
        StrategyXAVAFarmBase(
            avax,
            xava_avax_xava_lp_rewards,
            xava_avax_xava_lp,
            _governance,
            _strategist,
            _controller,
            _timelock
        )
    {}

    // **** Views ****

    function getName() external override pure returns (string memory) {
        return "StrategyXavaAvaxXavaLp";
    }
}
