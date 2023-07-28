// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "./PositionInterface.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract BaseForetell is ERC1155Holder {
    using Counters for Counters.Counter;
    Counters.Counter private predictionCounter;

    enum State{Rise,Downfall}

    address tokenAddress;

    uint256[] private ids;

    State private Change;

    struct Postion{
        uint256 stakedLong;
        uint256 longStaker;
        uint256 longPool;
        uint256 stakedShort;
        uint256 shortStaker;
        uint256 shortPool;
        uint256 stakedToken;
        uint256 totalStaker;
        uint256 totalPool;
    }

    struct UserTrack{
        uint256 predictionId;
        bool isLong;
        uint256 userStake;
    }

    struct Prediction {
        uint256 _predictionId;
        address participants;
        bool isLong;
        uint256 positionLocked;
        uint256 lockedAt;
        bool isPredictionCorrect;
    }

    struct Stock {
        uint16 stockId;
        string stockName;
        uint256 openingPrice;
        uint256 closingPrice;
    }

    Stock public stock;

    Postion public position;

    mapping( address => bool) private hasPredicted;

    mapping(address => UserTrack) public userTrack;

    mapping(uint256 => Prediction) public Predictions;

    modifier haveEnoughToken(uint256 _id,uint256 amount){
        require(IERC1155(tokenAddress).balanceOf(msg.sender,_id) >= amount,"Your Token Balance isn't Enough");
        require(amount >= 50,"Atleast 50 tokens should be locked");
        _;
    }

    constructor(
        uint16 stockId,
        string memory stockName,
        uint256 price,
        address _tokenAddress
    ) {
        position.longStaker = 0;
        position.shortStaker = 0;
        stock.stockId = stockId;
        stock.stockName = stockName;
        stock.closingPrice = price;
        ids = [0, 1];
        tokenAddress = _tokenAddress;
    }

    function openLongPostion(uint256 amount) external haveEnoughToken(0,amount) returns(uint256){
        predictionCounter.increment();
        uint256 predictionId = predictionCounter.current();
        UserTrack memory user;
        user.predictionId = predictionId;
        user.isLong = true;
        user.userStake = amount;
        userTrack[msg.sender] = user;
        Prediction memory prediction;
        prediction._predictionId = predictionId;
        prediction.participants = msg.sender;
        prediction.isLong = true;
        prediction.positionLocked = amount;
        prediction.lockedAt = block.timestamp;
        Predictions[predictionId] = prediction;
        position.stakedLong += amount;
        position.longStaker ++;
        position.stakedToken += amount;
        position.totalStaker = predictionCounter.current();
        hasPredicted[msg.sender] = true;
        IERC1155(tokenAddress).safeTransferFrom(
            msg.sender,
            address(this),
            0,
            amount,
            ""
        );
        return predictionId;
    }

    function openShortPostion(uint256 amount) external haveEnoughToken(1,amount) returns(uint256) {
        predictionCounter.increment();
        uint256 predictionId = predictionCounter.current();
        UserTrack memory user;
        user.predictionId = predictionId;
        user.isLong = false;
        user.userStake = amount;
        userTrack[msg.sender] = user;
        Prediction memory prediction = Predictions[predictionId];
        prediction._predictionId = predictionId;
        prediction.participants = msg.sender;
        prediction.isLong = false;
        prediction.positionLocked = amount;
        prediction.lockedAt = block.timestamp;
        Predictions[predictionId] = prediction;
        position.stakedShort += amount;
        position.shortStaker ++;
        position.stakedToken += amount;
        position.totalStaker = predictionCounter.current();
        hasPredicted[msg.sender] = true;
        IERC1155(tokenAddress).safeTransferFrom(
            msg.sender,
            address(this),
            1,
            amount,
            ""
        );
        return predictionId;
    }

    function calculateReward() public view returns(uint256 rewardEarned) {
        uint reward;
        if(userTrack[msg.sender].isLong == true){
            reward = (position.shortPool/position.stakedLong) * userTrack[msg.sender].userStake;
        } 
        else {
            reward = (position.longPool/position.stakedShort) * userTrack[msg.sender].userStake;
        }
        return reward;
    }

    function endProcess() external {
        PositionInterface(tokenAddress).burnLong(address(this),position.stakedLong);
        PositionInterface(tokenAddress).burnShort(address(this),position.stakedShort);
        position = Postion(0,0,0,0,0,0,0,0,0);
    }

    function updateChange(bool isRaised) public {
        if (isRaised == true){
            Change = State.Rise;
        } 
        else {
            Change = State.Downfall;
        }
        
    }

    function checkEligibity(address userAddress)public returns(bool) {
        UserTrack memory user = userTrack[userAddress];
        uint256 predictionId = user.predictionId;
        bool isEligible;
        if((Change == State.Rise && user.isLong == true) || (Change == State.Downfall && user.isLong == false)){
            Predictions[predictionId].isPredictionCorrect = true;
            isEligible = true;

        }
        else {
            Predictions[predictionId].isPredictionCorrect = false;
            isEligible = false;
        }

        return isEligible;
    }

    function collectReward(uint256 predictionId)public {
        require(checkEligibity(msg.sender) == true,"Sorry, you are not Eligible for Reward");
        Prediction memory prediction = Predictions[predictionId];
        require(prediction.isPredictionCorrect == true);
    }

}
