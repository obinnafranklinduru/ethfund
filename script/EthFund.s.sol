// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {EthFund} from "../src/EthFund.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

/// @dev This script deploys the EthFund contract using the price feed configuration from HelperConfig.
contract DeployEthFund is Script {
    /// @notice Deploys the EthFund contract.
    /// @return ethFund The deployed EthFund contract instance.
    function run() external returns (EthFund) {
        // Instantiate HelperConfig to get the price feed address for the active network.
        HelperConfig helperConfig = new HelperConfig();
        (address ethUSDPriceFeed) = helperConfig.activeNetworkConfig();

        // Start broadcasting transactions.
        vm.startBroadcast();

        // Deploy the EthFund contract with the price feed address.
        EthFund ethFund = new EthFund(ethUSDPriceFeed);

        // Stop broadcasting transactions.
        vm.stopBroadcast();

        // Return the deployed EthFund contract instance.
        return ethFund;
    }
}
