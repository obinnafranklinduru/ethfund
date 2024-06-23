// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {EthFund} from "../src/EthFund.sol";

contract FundEthFund is Script {
    // Constants
    uint256 constant SEND_VALUE = 1 ether;

    /**
     * @dev Function to fund the EthFund contract with a specified amount of ETH.
     * @param mostRecentlyDeployed The address of the most recently deployed EthFund contract.
     */
    function fundEthFund(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        EthFund(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded EthFund with %s ETH", SEND_VALUE);
    }

    /**
     * @dev Run function to get the most recent deployment and fund the EthFund contract.
     */
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("EthFund", block.chainid);
        console.log("Most recently deployed EthFund address: %s", mostRecentlyDeployed);

        fundEthFund(mostRecentlyDeployed);
    }
}

contract WithdrawEthFund is Script {
    /**
     * @dev Function to withdraw all funds from the EthFund contract.
     * @param mostRecentlyDeployed The address of the most recently deployed EthFund contract.
     */
    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        EthFund(payable(mostRecentlyDeployed)).withdraw();
        console.log("Withdrew balance from EthFund!");
        vm.stopBroadcast();
    }

    /**
     * @dev Run function to get the most recent deployment and withdraw from the EthFund contract.
     */
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("EthFund", block.chainid);
        console.log("Most recently deployed EthFund address: %s", mostRecentlyDeployed);

        withdrawFundMe(mostRecentlyDeployed);
    }
}
