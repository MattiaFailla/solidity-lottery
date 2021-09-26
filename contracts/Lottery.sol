// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract Lottery {
    address payable[] players;
    uint256 public usdEntryFee;
    AggregatorV3Interface internal ethUsdPriceFeed;

    constructor(address _pricefeedAddress) public {
        usdEntryFee = 50 * (10**18);
        ethUsdPriceFeed = AggregatorV3Interface(_pricefeedAddress);
    }

    function enter() public payable {
        require(msg.value >= getEntranceFee(), "Not enough ETH");
        players.push(msg.sender);
    }

    function getEntranceFee() public view returns (uint256) {
        // Must use safemath since we are in solidity v.<0.8.*
        (, int256 price, , , ) = ethUsdPriceFeed.latestRoundData();
        uint256 adjustedPrice = uint256(price) * 10**10; // 18 decimals
        // Setting $50 as entrance price
        // 50 * 100000 / 200
        uint256 costToEnter = (usdEntryFee * 10**18) / adjustedPrice;
        return costToEnter;
    }

    function startLotter() public {}

    function endLottery() public {}
}
