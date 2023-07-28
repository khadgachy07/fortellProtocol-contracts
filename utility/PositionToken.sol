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

    mapping(address => uint256) public postionBalForLong;
    mapping(address => uint256) public positionBalForShort;
    mapping(address => uint256) public positionBalance;

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
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function getLongPostion(
        address _to,
        uint256 amount,
        address stockAddress
    ) public payable {
        // require(msg.value ==tokenPrice, "User must pay for the token" );
        postionBalForLong[_to] += amount;
        positionBalance[_to] += amount;
        _mint(_to, 0, amount, "");
        setApprovalForAll(stockAddress, true);
    }

    function getShortPosition(
        address _to,
        uint256 amount,
        address stockAddress
    ) public payable {
        // require(msg.value ==tokenPrice, "User must pay for the token" );
        positionBalForShort[_to] += amount;
        positionBalance[_to] += amount;
        _mint(_to, 1, amount, "");
        setApprovalForAll(stockAddress, true);
    }


    function getRewardNftOne()
        public
        checkBalance(1000)
        shouldHaveOnlyOne(nftFor1000Position)
    {
        _mint(msg.sender, 2, 1, "");
    }

    function getRewardNftTwo()
        public
        checkBalance(3000)
        shouldHaveOnlyOne(nftFor3000Position)
    {
        _mint(msg.sender, 3, 1, "");
    }

    function getRewardNftThree()
        public
        checkBalance(5000)
        shouldHaveOnlyOne(nftFor5000Position)
    {
        _mint(msg.sender, 4, 1, "");
    }

    function burnLong(address holder,uint256 amount)public{
        burn(holder,0,amount);
    }

    function burnShort(address holder,uint256 amount)public {
        burn(holder,1,amount);
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
}
