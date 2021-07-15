// SPDX-License-Identifier: MIT
pragma solidity ^0.6.7;

import "../strategy-png-farm-base.sol";


contract StrategyPngAvaxSporeLp is StrategyPngFarmBase {
    // Token addresses
    address public png_avax_spore_lp_rewards = 0xd3e5538A049FcFcb8dF559B85B352302fEfB8d7C;
    address public png_avax_spore_lp = 0x0a63179a8838b5729E79D239940d7e29e40A0116;
    address public spore = 0x6e7f5C0b9f4432716bDd0a77a3601291b9D9e985;

    constructor(
        address _governance,
        address _strategist,
        address _controller,
        address _timelock
    )
        public
        StrategyPngFarmBase(
            spore,
            png_avax_spore_lp_rewards,
            png_avax_spore_lp,
            _governance,
            _strategist,
            _controller,
            _timelock
        )
    {}

    // **** Views ****

    function getName() external override pure returns (string memory) {
        return "StrategyPngAvaxSporeLp";
    }
}
