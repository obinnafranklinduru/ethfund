// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {EthFund} from "../../src/EthFund.sol";
import {DeployEthFund} from "../../script/EthFund.s.sol";

contract EthFundTest is Test {
    EthFund ethFund;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 1 ether;
    uint256 constant STARTING_BALANCE = 100 ether;
    uint256 constant GAS_PRICE = 1 gwei;

    // Setup function to deploy the EthFund contract and provide initial balances
    function setUp() public {
        DeployEthFund deployEthFund = new DeployEthFund();
        ethFund = deployEthFund.run();
        vm.deal(USER, STARTING_BALANCE);
        vm.deal(ethFund.owner(), STARTING_BALANCE);
    }

    // Test to ensure the minimum USD amount is set to 5
    function testMinimumDollarIsFive() public view {
        assertEq(ethFund.MINIMUM_USD(), 5e18, "Minimum USD should be 5e18");
    }

    // Test to ensure the price feed version is accurate
    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = ethFund.getVersion();
        assertEq(version, 4, "Price feed version should be 4");
    }

    // Test to ensure funding fails without enough ETH
    function testFundFailWithoutEnoughETH() public {
        vm.expectRevert("You need to spend more ETH!");
        ethFund.fund{value: 0}();
    }

    // Modifier to fund the contract before running the test
    modifier funded() {
        vm.prank(USER);
        ethFund.fund{value: SEND_VALUE}();
        _;
    }

    // Test to ensure the funded data structure is updated correctly
    function testFundUpdateFundedDataStructure() public funded {
        uint256 amountFunded = ethFund.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE, "Amount funded should match send value");
    }

    // Test to ensure the funder is added to the array of funders
    function testAddsFunderToArrayOfFunders() public funded {
        address funder = ethFund.getFunder(0);
        assertEq(funder, USER, "Funder should be added to array of funders");
    }

    // Test to ensure only the owner can withdraw funds
    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        ethFund.withdraw();
    }

    // Test to withdraw funds with a single funder
    function testWithdrawWithSingleFunder() public funded {
        uint256 startingOwnerBalance = ethFund.owner().balance;
        uint256 startingEthFundBalance = address(ethFund).balance;

        vm.prank(ethFund.owner());
        ethFund.withdraw();

        uint256 endingOwnerBalance = ethFund.owner().balance;
        uint256 endingEthFundBalance = address(ethFund).balance;

        assertEq(endingEthFundBalance, 0, "Contract balance should be zero after withdrawal");
        assertEq(startingEthFundBalance + startingOwnerBalance, endingOwnerBalance, "Owner balance should include withdrawn funds");
    }

    // Test to withdraw funds with multiple funders
    function testWithdrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), STARTING_BALANCE);
            ethFund.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = ethFund.owner().balance;
        uint256 startingEthFundBalance = address(ethFund).balance;

        vm.startPrank(ethFund.owner());
        ethFund.withdraw();
        vm.stopPrank();

        uint256 endingOwnerBalance = ethFund.owner().balance;
        uint256 endingEthFundBalance = address(ethFund).balance;

        assertEq(endingEthFundBalance, 0, "Contract balance should be zero after withdrawal");
        assertEq(startingEthFundBalance + startingOwnerBalance, endingOwnerBalance, "Owner balance should include withdrawn funds");
    }

    // Test to ensure the contract can be paused and unpaused by the owner
    function testPauseAndUnpause() public {
        vm.prank(ethFund.owner());
        ethFund.pause();
        assert(ethFund.paused());

        vm.prank(ethFund.owner());
        ethFund.unpause();
        assert(!ethFund.paused());
    }

    // Test to ensure funding fails while the contract is paused
    function testFundWhilePaused() public {
        vm.prank(ethFund.owner());
        ethFund.pause();

        vm.prank(USER);
        vm.expectRevert();
        ethFund.fund{value: SEND_VALUE}();
    }

    // Test to ensure the receive function works correctly
    function testReceiveFunction() public {
        vm.prank(USER);
        (bool success, ) = address(ethFund).call{value: SEND_VALUE}("");
        assert(success);

        uint256 amountFunded = ethFund.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE, "Amount funded should match send value");
    }

    // Test to ensure the fallback function works correctly
    function testFallbackFunction() public {
        vm.prank(USER);
        (bool success, ) = address(ethFund).call{value: SEND_VALUE}(abi.encodeWithSignature("nonExistingFunction()"));
        assert(success);

        uint256 amountFunded = ethFund.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE, "Amount funded should match send value");
    }

    // Test to ensure getFunder function reverts when index is out of bounds
    function testGetFunderOutOfBounds() public {
        vm.expectRevert();
        ethFund.getFunder(1);
    }
}