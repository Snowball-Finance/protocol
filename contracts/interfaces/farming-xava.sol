// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

interface IFarmingXava {
    // Reads
    function deposited(uint256 poolId, address account) external view returns (uint256);

    function endTimestamp() external view returns (uint256);

    function erc20() external view returns (address);

    function owner() external view returns (address);

    function paidOut() external view returns (uint256);

    function pending(uint256 poolId, address account) external view returns (uint256);

    function poolInfo(uint256 poolId) external view returns (
        IERC20 lpToken,                 // Address of LP token contract.
        uint256 allocPoint,             // How many allocation points assigned to this pool. ERC20s to distribute per block.
        uint256 lastRewardTimestamp,    // Last timstamp that ERC20s distribution occurs.
        uint256 accERC20PerShare,       // Accumulated ERC20s per share, times 1e36.
        uint256 totalDeposits           // Total amount of tokens deposited at the moment (staked)
    );

    function poolLength() external view returns (uint256);

    function rewardPerSecond() external view returns (uint256);

    function startTimestamp() external view returns (uint256);

    function totalAllocPoint() external view returns (uint256);

    function totalPending() external view returns (uint256);

    function totalRewards() external view returns (uint256);

    function rewardsDistribution() external view returns (address);

    function userInfo(uint256 poolId, address account) external view returns (
        uint256 amount,
        uint256 rewardDebt
    );
    

    // Writes

    function add(uint256 allocPoint, address lpToken, bool withUpdate) external;

    function deposit(uint256 poolId, uint256 amount) external;

    function emergencyWithdraw(uint256 poolId) external;

    function fund(uint256 amount) external;

    function massUpdatePools() external;

    function renounceOwnership() external;

    function set(uint256 poolId, uint256 allocPoint, bool withUpdate) external;

    function transferOwnership(address newOwner) external;

    function updatePool(uint256 poolId) external;

    function withdraw(uint256 poolId, uint256 amount) external;
}