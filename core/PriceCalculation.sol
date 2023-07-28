// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./PositionInterface.sol";
import "./ForetellFactory.sol";

contract ForetellTokenPrice  is ForetellFactory{
    uint256 private longPositionCounter;
    uint256 private shortPositionCounter;

    uint256 public sumOfLongPricePool;
    uint256 public sumOfShortPricePool;

    uint256 public currentLongPrice;
    uint256 public currentShortPrice;

    PositionInterface private positionToken;
    address private tokenAddress;

    uint private totalLengthCycle;

    uint256 startTime;

    struct longPricePosition{
        uint256 position;
        uint256 price;
    }

    struct shortPricePosition{
        uint256 position;
        uint256 price;
    }


    mapping (uint256 => longPricePosition) private positionToLongPrice;
    mapping (uint256 => shortPricePosition) private positionToShortPrice;

    constructor (address _tokenAddress) ForetellFactory(_tokenAddress){
        sumOfLongPricePool = 0;
        sumOfShortPricePool = 0;
        longPositionCounter = 0;
        shortPositionCounter = 0;
        currentLongPrice = 1;
        currentShortPrice = 1;
        totalLengthCycle = 86400 seconds;
        startTime = block.timestamp;
        tokenAddress = _tokenAddress;
        positionToken = PositionInterface(_tokenAddress);
    }
    
    function getToken(bool isLong,uint16 stockId,uint256 tokenAmount) public {
        uint256 position;
        if(isLong == true){
            position = longPositionCounter++;
            positionToLongPrice[position] = longPricePosition(position,currentLongPrice);
            positionToken.getLongPostion(msg.sender,tokenAmount,StockContracts[stockId]);
            
        }
        else {
            position = shortPositionCounter ++;
            positionToShortPrice[position] = shortPricePosition(position,currentShortPrice);
            positionToken.getShortPosition(msg.sender,tokenAmount,StockContracts[stockId]);
        }
    }

    function getSummation(bool isLong,uint position, uint256 positionPrice)public returns(uint256) {
        uint sum = 0;
        sum += (position * positionPrice);
        if (isLong == true) {
            return sumOfLongPricePool += sum;
        }
        else {
            return sumOfShortPricePool += sum;
        }
    }

    function getTimePassed()public view returns(uint){
        return block.timestamp - startTime;
    }

    function getPriceNumerator(bool isLong,uint position,uint price)public returns(uint256){
        return getSummation(isLong,position,price) * (totalLengthCycle - getTimePassed()) * price;
    }

    function getDenominator(bool isLong,uint position,uint price) public returns(uint256){
        return getSummation(isLong,position,price) * totalLengthCycle;
    }

    function getTokenPrice(bool isLong) public returns(uint256) {
        require(longPositionCounter > 1 && shortPositionCounter > 1);
        uint tokenPrice;
        if (isLong == true) {
            tokenPrice =  getPriceNumerator(true,longPositionCounter,currentLongPrice)/getDenominator(false,shortPositionCounter,currentShortPrice);
            currentLongPrice = tokenPrice;
            positionToLongPrice[longPositionCounter] = longPricePosition(longPositionCounter,tokenPrice);
        }
        else {
            tokenPrice = getPriceNumerator(false,shortPositionCounter,currentShortPrice)/getDenominator(true,longPositionCounter,currentLongPrice);
            currentShortPrice = tokenPrice;
            positionToShortPrice[shortPositionCounter] = shortPricePosition(shortPositionCounter,tokenPrice);
        }
        return tokenPrice * 100;
    }




}