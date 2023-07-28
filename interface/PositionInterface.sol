// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface PositionInterface {
    function getLongPostion(
        address _to,
        uint256 amount,
        address stockAddress
    ) external payable;

    function getShortPosition(
        address _to,
        uint256 amount,
        address stockAddress
    ) external payable;

    function burnLong(address holder, uint256 amount) external;

    function burnShort(address holder, uint256 amount) external;
}
