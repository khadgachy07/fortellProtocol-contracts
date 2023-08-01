// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface BaseInterface{

    function openLongPostion(uint amount) external;

    function openShortPostion(uint amount) external;

    function updateChange(bool isRaised) external ;

    function endProcess() external ;
}