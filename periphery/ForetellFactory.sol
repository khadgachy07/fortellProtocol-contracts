// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BaseForetell.sol";
import "./OracleClosingPrice.sol";

contract ForetellFactory is OracleClosingPrice {

 event StockDeployed (address indexed stockAddress,uint16 indexed stockId);
    
    address private tokenAddress;

    mapping(uint16 => address) public StockContracts;

   constructor(address _tokenAddress) {
       tokenAddress = _tokenAddress;
   }

    function getOpening(uint16 _stockId) internal view returns(uint256){
        return OracleClosingPrice.getPrice(_stockId);
    }


    function addStuck(uint16 _stockId,string memory _stockName) public {
        BaseForetell newContract = new BaseForetell(_stockId,_stockName,getOpening(_stockId),tokenAddress);
        StockContracts[_stockId] = address(newContract);
        emit StockDeployed(address(newContract), _stockId);

    }
}