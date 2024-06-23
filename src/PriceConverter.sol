// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

/**
 * @title PriceConverter
 * @dev Library for fetching ETH/USD price from Chainlink price feed and converting ETH amounts to USD.
 */
library PriceConverter {
    /**
     * @dev Fetches the latest ETH/USD price from the Chainlink price feed.
     * @param _priceFeed The address of the Chainlink price feed contract.
     * @return The ETH/USD price in 18 digits.
     */
    function getPrice(AggregatorV3Interface _priceFeed) internal view returns (uint256) {
        try _priceFeed.latestRoundData() returns (uint80, int256 answer, uint256, uint256 updatedAt, uint80) {
            // Ensure the price is greater than zero and data is recent (within last hour)
            require(answer > 0, "Price feed returned non-positive value");
            require(block.timestamp - updatedAt <= 3600, "Price feed data is stale");

            // ETH/USD rate in 18 digits
            return uint256(answer * 10 ** 10);
        } catch {
            revert("Failed to fetch price from price feed");
        }
    }

    /**
     * @dev Converts a given amount of ETH to USD using the current ETH/USD price.
     * @param ethAmount Amount of ETH to convert.
     * @param _priceFeed The address of the Chainlink price feed contract.
     * @return The converted amount in USD.
     */
    function getConversionRate(uint256 ethAmount, AggregatorV3Interface _priceFeed) internal view returns (uint256) {
        uint256 ethPrice = getPrice(_priceFeed);
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;

        return ethAmountInUsd;
    }
}
