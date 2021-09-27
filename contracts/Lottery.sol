// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract Lottery is VRFConsumerBase, Ownable {
    address payable[] players;
    uint256 public usdEntryFee;
    address payable public recentWinner;
    AggregatorV3Interface internal ethUsdPriceFeed;
    enum LOTTERY_STATE {
        OPEN,
        CLOSED,
        CALCULATING_WINNER
    }
    LOTTERY_STATE public lottery_state;

    // Link settings
    uint256 public linkFee;
    bytes32 keyhash;

    // Random number by VFR
    uint256 public recentRandomness;

    constructor(
        address _pricefeedAddress,
        address _vfrCoordinator,
        address _linkToken,
        uint256 _linkFee,
        bytes32 _keyhash
    ) public VRFConsumerBase(_vfrCoordinator, _linkToken) {
        usdEntryFee = 50 * (10**18);
        ethUsdPriceFeed = AggregatorV3Interface(_pricefeedAddress);
        lottery_state = LOTTERY_STATE.CLOSED;
        linkFee = _linkFee;
        keyhash = _keyhash;
    }

    function enter() public payable {
        require(lottery_state == LOTTERY_STATE.OPEN, "Lottery not ready");
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

    function startLottery() public onlyOwner {
        require(
            lottery_state == LOTTERY_STATE.CLOSED,
            "Can't start a new lottery yet! Lottery still running"
        );
        lottery_state = LOTTERY_STATE.OPEN;
    }

    /**
     * Callback function used by VRF Coordinator
     * This is internal since we want only the contract itself to call this function
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness)
        internal
        override
    {
        require(
            lottery_state == LOTTERY_STATE.CALCULATING_WINNER,
            "Unable to process random number yet!"
        );
        require(randomness > 0, "Random not found");

        // Picking a random winner
        uint256 indexOfWinner = (randomness % players.length);
        recentWinner = players[indexOfWinner];
        recentWinner.transfer(address(this).balance);
        // Reset the lottery
        players = new address payable[](0);
        lottery_state = LOTTERY_STATE.CLOSED;
        recentRandomness = randomness;
    }

    function endLottery() public onlyOwner {
        // Choose a random winner and end the lottery
        // To get a random number we need to use an external source of random numbers
        /// Using chainlink VRF
        lottery_state = LOTTERY_STATE.CALCULATING_WINNER;
        requestRandomness(keyhash, linkFee); // Will return in requestId using request/receive architecture
    }
}
