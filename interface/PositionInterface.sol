// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface PositionInterface {
    function getLongPostion(
        address _to,
        uint256 amount,
        address payable stockAddress
    ) external payable;

    function getShortPosition(
        address _to,
        uint256 amount,
        address payable stockAddress
    ) external payable;

    function getRewardNftOne() external;

    function getRewardNftTwo() external;

    function getRewardNftThree() external;

    function burnLong(address holder, uint256 amount) external;

    function burnShort(address holder, uint256 amount) external;

    function checkReq(bool isLong) external returns (uint256 price);
}
