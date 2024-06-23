// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {EthFund} from "../../src/EthFund.sol";
import {DeployEthFund} from "../../script/EthFund.s.sol";
import {FundEthFund, WithdrawEthFund} from "../../script/Interactions.s.sol";

contract InteractionTest is Test {
    EthFund ethFund;

    address USER = makeAddr("user");
    uint256 constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        // Deploy the EthFund contract
        DeployEthFund deployEthFund = new DeployEthFund();
        ethFund = deployEthFund.run();

        // Fund the USER with initial balance
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteraction() public {
        // User funds the EthFund contract
        vm.prank(USER);
        FundEthFund fundEthFund = new FundEthFund();
        fundEthFund.fundEthFund(address(ethFund));

        // Withdraw the funds from the EthFund contract
        WithdrawEthFund withdrawEthFund = new WithdrawEthFund();
        withdrawEthFund.withdrawFundMe(address(ethFund));

        // Assert that the contract balance is 0 after withdrawal
        assertEq(address(ethFund).balance, 0, "Contract balance should be zero after withdrawal");
    }
}
