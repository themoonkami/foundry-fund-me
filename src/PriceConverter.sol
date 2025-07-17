// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


library PriceConverter{
        function getPrice(AggregatorV3Interface priceFeed) internal view returns(uint256){
        // CA: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        // ABI:
        
        (, int256 price,,,) = priceFeed.latestRoundData();
        // should return price of ETH in terms of USD
        // solidity does not work with decimals 
        return uint256(price * 1e10);
    }
    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
        ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }

    function getVersion() public view returns (uint256){
        return AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306).version();
    }
}