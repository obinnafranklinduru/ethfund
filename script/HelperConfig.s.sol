// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {EthFund} from "../src/EthFund.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // Active network configuration
    NetworkConfig public activeNetworkConfig;

    // Constants for the mock price feed
    uint8 public constant PRICE_FEED_DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 200e8;

    // Structure to hold network configuration
    struct NetworkConfig {
        address priceFeed;
    }

    // Constructor to set the active network configuration based on the chain ID
    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = _getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = _getMainnetEthConfig();
        } else {
            activeNetworkConfig = _getOrCreateAnvilEthConfig();
        }
    }

    // Function to get the Sepolia Ethereum network configuration
    function _getSepoliaEthConfig() internal pure returns (NetworkConfig memory) {
        return NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
    }

    // Function to get the Mainnet Ethereum network configuration
    function _getMainnetEthConfig() internal pure returns (NetworkConfig memory) {
        return NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
    }

    // Function to get or create the Anvil Ethereum network configuration
    function _getOrCreateAnvilEthConfig() internal returns (NetworkConfig memory) {
        // Return existing configuration if already set
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        // Deploy a mock price feed if no configuration exists
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(PRICE_FEED_DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        // Return the newly created configuration
        return NetworkConfig({priceFeed: address(mockPriceFeed)});
    }
}
