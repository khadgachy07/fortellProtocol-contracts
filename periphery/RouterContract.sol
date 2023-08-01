// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ForetellFactory.sol";
import "./BaseInterface.sol";

contract RouterForetell is ForetellFactory{
    
    constructor(address _tokenAddress) ForetellFactory( _tokenAddress){

    }


    function longPostion(uint16 stockId,uint amount) public {
        BaseInterface(StockContracts[stockId]).openLongPostion(amount);
    }

    function shortPostion(uint16 stockId,uint amount) public {
        BaseInterface(StockContracts[stockId]).openShortPostion(amount);
    }

   

}