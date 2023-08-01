// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract PositionToken is
    ERC1155,
    Pausable,
    Ownable,
    ERC1155Supply,
    ERC1155Burnable
{
    uint256 private constant longPosition = 0;
    uint256 private constant shortPosition = 1;
    uint256 private constant nftFor1000Position = 2;
    uint256 private constant nftFor3000Position = 3;
    uint256 private constant nftFor5000Position = 4;

    uint256[] private positionIds;

    uint256 public longPositionCounter;
    uint256 public shortPositionCounter;

    uint256 public sumOfLongPricePool;
    uint256 public sumOfShortPricePool;

    uint256 public currentLongPrice;
    uint256 public currentShortPrice;

    uint256 private totalLengthCycle;

    uint256 startTime;

    struct longPricePosition {
        uint256 position;
        uint256 price;
    }

    struct shortPricePosition {
        uint256 position;
        uint256 price;
    }

    mapping(address => uint256) public postionBalForLong;
    mapping(address => uint256) public positionBalForShort;
    mapping(address => uint256) public positionBalance;

    mapping(uint256 => longPricePosition) public positionToLongPrice;
    mapping(uint256 => shortPricePosition) public positionToShortPrice;

    modifier checkBalance(uint256 amount) {
        require(
            positionBalance[msg.sender] >= amount,
            "You haven't reached the milestone"
        );
        _;
    }

    modifier shouldHaveOnlyOne(uint256 id) {
        require(
            balanceOf(msg.sender, id) == 0,
            "You already obtained your NFT"
        );
        _;
    }

    constructor()
        ERC1155(
            "https://ipfs.io/ipfs/bafybeig7hkykbwh3five2kk3df5aqr3rnqc7ddnzb4ad7t2rg5qh4ddqwe/"
        )
    {
        positionIds = [longPosition, shortPosition];
        sumOfLongPricePool = 1;
        sumOfShortPricePool = 1;
        longPositionCounter = 0;
        shortPositionCounter = 0;
        currentLongPrice = 1000000000000000 wei; //0.001 ether;
        currentShortPrice = 1000000000000000 wei;
        totalLengthCycle = 1440 minutes;
        startTime = block.timestamp;
        positionToLongPrice[1] = longPricePosition(1, currentLongPrice);
        positionToShortPrice[1] = shortPricePosition(1, currentShortPrice);
    }

    event LongToken(address minter,address forStock,uint256 amount,uint256 position, uint256 price);

    event ShortToken(address minter,address forStock,uint256 amount,uint256 position, uint256 price);

    event ObtainedNFT(address rewardReceiver,uint milestone);

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function getLongPostion(
        address _to,
        uint256 amount,
        address payable stockAddress
    ) public payable {
         uint256 tokenPrice;
        if (longPositionCounter < 0) {
            tokenPrice = checkReq(true);
            require(
                msg.value == tokenPrice,
                "You must pay the token price"
            );
        } else {
            tokenPrice = currentLongPrice;
            require(
                msg.value == tokenPrice,
                "You must pay the token price"
            );
        }
        postionBalForLong[_to] += amount;
        positionBalance[_to] += amount;
        longPositionCounter++;
        
        _mint(_to, 0, amount, "");
        setApprovalForAll(stockAddress, true);
        payable(stockAddress).transfer(tokenPrice);
        emit LongToken(msg.sender,stockAddress,amount,longPositionCounter,currentLongPrice);
    }

    function getShortPosition(
        address _to,
        uint256 amount,
        address stockAddress
    ) public payable {
        uint256 tokenPrice;
        if (shortPositionCounter < 0) {
            tokenPrice = checkReq(false);
            require(
                msg.value == tokenPrice,
                "You must pay the token price"
            );
        }
        else {
            tokenPrice = currentShortPrice;
            require(
                msg.value == tokenPrice,
                "You must pay the token price"
            );
        }
        positionBalForShort[_to] += amount;
        positionBalance[_to] += amount;
        shortPositionCounter++;
        
        _mint(_to, 1, amount, "");
        setApprovalForAll(stockAddress, true);
        payable(stockAddress).transfer(tokenPrice);
        emit ShortToken(msg.sender,stockAddress,amount,shortPositionCounter,currentShortPrice);
    }

    function getRewardNftOne()
        public
        checkBalance(1000)
        shouldHaveOnlyOne(nftFor1000Position)
    {
        _mint(msg.sender, 2, 1, "");
        emit ObtainedNFT(msg.sender,1000);
    }

    function getRewardNftTwo()
        public
        checkBalance(3000)
        shouldHaveOnlyOne(nftFor3000Position)
    {
        _mint(msg.sender, 3, 1, "");
        emit ObtainedNFT(msg.sender,3000);
    }

    function getRewardNftThree()
        public
        checkBalance(5000)
        shouldHaveOnlyOne(nftFor5000Position)
    {
        _mint(msg.sender, 4, 1, "");
        emit ObtainedNFT(msg.sender,5000);
    }

    function burnLong(address holder, uint256 amount) public {
        burn(holder, 0, amount);
    }

    function burnShort(address holder, uint256 amount) public {
        burn(holder, 1, amount);
    }

    function uri(uint256 _id)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(exists(_id), "URI: nonexistent token");
        return
            string(
                abi.encodePacked(super.uri(_id), Strings.toString(_id), ".json")
            );
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) whenNotPaused {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function getSummation(
        bool isLong,
        uint256 position,
        uint256 positionPrice
    ) internal returns (uint256) {
        uint256 sum = 0;
        sum += (position * positionPrice);
        if (isLong == true) {
            return sumOfLongPricePool += sum;
        } else {
            return sumOfShortPricePool += sum;
        }
    }

    function getTimePassed() internal view returns (uint256) {
        return (block.timestamp - startTime) / 60;
    }

    function getPriceNumerator(
        bool isLong,
        uint256 position,
        uint256 price
    ) internal returns (uint256) {
        return
            getSummation(isLong, position, price) *
            (totalLengthCycle - getTimePassed()) *
            price;
    }

    function getDenominator(
        bool isLong,
        uint256 position,
        uint256 price
    ) internal returns (uint256) {
        return getSummation(isLong, position, price) * totalLengthCycle;
    }

    function checkReq(bool isLong) public returns (uint256 price) {
        uint256 tokenPrice;
        uint256 position;
        if (isLong == true) {
            tokenPrice = getTokenPrice(true);
            currentLongPrice = tokenPrice;
            position = longPositionCounter + 1;
            positionToLongPrice[position] = longPricePosition(
                position,
                tokenPrice
            );
        } else {
            tokenPrice = getTokenPrice(false);
            currentShortPrice = tokenPrice;
            position = shortPositionCounter + 1;
            positionToShortPrice[position] = shortPricePosition(
                position,
                tokenPrice
            );
        }
        return tokenPrice;
    }

    function getTokenPrice(bool isLong) internal returns (uint256) {
        require(
            longPositionCounter > 0 || shortPositionCounter > 0,
            "Position should gether than 0"
        );
        uint256 tokenPrice;
        if (isLong == true && longPositionCounter > 0) {
            tokenPrice =
                getPriceNumerator(true, longPositionCounter, currentLongPrice) /
                getDenominator(false, shortPositionCounter, currentShortPrice);
        } else if (isLong == false && shortPositionCounter > 0) {
            tokenPrice =
                getPriceNumerator(
                    false,
                    shortPositionCounter,
                    currentShortPrice
                ) /
                getDenominator(true, longPositionCounter, currentLongPrice);
        }
        return tokenPrice;
    }
}
