// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./ForetellFactory.sol";

contract AdminContract is AccessControl, ForetellFactory{

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant TOKEN_BURNER_ROLE = keccak256("TOKEN_BURNER_ROLE");
    bytes32 public constant STOCK_ADDER_ROLE = keccak256("STOCK_ADDER_ROLE");
    bytes32 public constant UPDATER_ROLE = keccak256("UPDATER_ROLE");

    uint16 private stockCounter;

    struct Stock{
        uint256 stockId;
        string name;
        uint256 open;
        uint256 high;
        uint256 low;
        uint256 close;
        uint256 volume;
    }
    
    mapping(uint16 => Stock) public Stocks;
    mapping(address => bool ) private AdminPanel;

    modifier mustBeInPanel(address member) {
        require(AdminPanel[member] == true,"Member should be in Admin Panel before assigning a role");
        _;
    }

    constructor(address tokenAddress) ForetellFactory(tokenAddress) {
        stockCounter = 0;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        ForetellFactory.addStock(stockCounter++,"RELIANCE INDUSTRIES LTD.");
        Stocks[stockCounter].open = ForetellFactory.getOpening(stockCounter);
        Stocks[stockCounter].name = "RELIANCE INDUSTRIES LTD.";
        ForetellFactory.addStock(stockCounter++,"TATA CONSULTANCY SERIVES LTD.");
        Stocks[stockCounter].open = ForetellFactory.getOpening(stockCounter);
        Stocks[stockCounter].name = "RELIANCE INDUSTRIES LTD.";
        ForetellFactory.addStock(stockCounter++,"HDFC Bank Ltd");
        Stocks[stockCounter].open = ForetellFactory.getOpening(stockCounter);
        Stocks[stockCounter].name = "RELIANCE INDUSTRIES LTD.";
        ForetellFactory.addStock(stockCounter++,"TATA CONSULTANCY SERIVES LTD.");
        Stocks[stockCounter].open = ForetellFactory.getOpening(stockCounter);
        Stocks[stockCounter].name = "RELIANCE INDUSTRIES LTD.";
        ForetellFactory.addStock(stockCounter++,"HINDUSTAN UNILEVER LTD.");
        Stocks[stockCounter].open = ForetellFactory.getOpening(stockCounter);
        Stocks[stockCounter].name = "RELIANCE INDUSTRIES LTD.";
    }



    function addInAdminPanel(address adminMember) public onlyRole(DEFAULT_ADMIN_ROLE){
        AdminPanel[adminMember] = true;
    }

    function removeFromAdminPanel(address adminMember) public onlyRole(DEFAULT_ADMIN_ROLE){
        AdminPanel[adminMember] = false;
    }

    function assignPauser(address _member) public onlyRole(DEFAULT_ADMIN_ROLE) mustBeInPanel(_member){
        _grantRole(PAUSER_ROLE,_member);
    }

    function removePauser(address _member) public onlyRole(DEFAULT_ADMIN_ROLE) mustBeInPanel(_member){
        _revokeRole(PAUSER_ROLE,_member);
    }

    function assignTokenBurner(address _member) public onlyRole(DEFAULT_ADMIN_ROLE) mustBeInPanel(_member){
        _grantRole(TOKEN_BURNER_ROLE,_member);
    }

    function removeTokenBurner(address _member) public onlyRole(DEFAULT_ADMIN_ROLE) mustBeInPanel(_member){
        _revokeRole(TOKEN_BURNER_ROLE,_member);
    }

    function assginStockAdder(address _member)public onlyRole(DEFAULT_ADMIN_ROLE) mustBeInPanel(_member){
        _grantRole(STOCK_ADDER_ROLE,_member);
    }

    function removerStockAdder(address _member)public onlyRole(DEFAULT_ADMIN_ROLE) mustBeInPanel(_member){
        _revokeRole(STOCK_ADDER_ROLE,_member);
    }

    function assignUpdater(address _member)public onlyRole(DEFAULT_ADMIN_ROLE) mustBeInPanel(_member){
        _grantRole(UPDATER_ROLE,_member);
    }

    function removeUpdater(address _member)public onlyRole(DEFAULT_ADMIN_ROLE) mustBeInPanel(_member){
        _revokeRole(UPDATER_ROLE,_member);
    }

    

    function addNewStock(string calldata name)public onlyRole(STOCK_ADDER_ROLE) mustBeInPanel(msg.sender){
        ForetellFactory.addStock(stockCounter++,name);
    }
    
}