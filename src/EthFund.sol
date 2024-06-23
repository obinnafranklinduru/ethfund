// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

/**
 * @title EthFund
 * @author Obinna Franklin Duru
 * @notice A contract that tracks funders and their contributions while ensuring secure and controlled fund withdrawals by the owner.
 * @dev A contract that allows users to fund the contract and withdraw funds.
 */
contract EthFund is Ownable, Pausable, ReentrancyGuard {
    using PriceConverter for uint256;

    // Events
    event FundsReceived(address indexed funder, uint256 amount);
    event Withdrawal(address indexed contractOwner, uint256 amount, bytes data);

    // State variables
    mapping(address => uint256) private s_funderToAmountFunded; // Tracks the amount each funder has contributed
    address[] private s_funders; // List of unique funders
    AggregatorV3Interface private s_priceFeed;

    // Constants
    uint256 public constant MINIMUM_USD = 5e18; // Minimum amount in USD to fund

    constructor(address _priceFeed) Ownable(msg.sender) {
        s_priceFeed = AggregatorV3Interface(_priceFeed);
    }

    /**
     * @dev Accepts ETH from a funder, requires a minimum ETH amount, and tracks the amount funded.
     */
    function fund() public payable whenNotPaused {
        // Convert the amount to USD and check against the minimum requirement
        uint256 minimumUsd = MINIMUM_USD;
        require(msg.value.getConversionRate(s_priceFeed) >= minimumUsd, "You need to spend more ETH!");

        // Add the funder to the list if they haven't funded before
        if (s_funderToAmountFunded[msg.sender] == 0) {
            s_funders.push(msg.sender);
        }

        // Update the funder's total funded amount
        s_funderToAmountFunded[msg.sender] += msg.value;

        // Emit an event to log the funds received
        emit FundsReceived(msg.sender, msg.value);
    }

    /**
     * @dev Withdraws all funds from the contract and distributes them to the funders.
     */
    function withdraw() public payable onlyOwner nonReentrant whenNotPaused {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No funds available to withdraw");

        // Reset the amount funded for each funder
        for (uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_funderToAmountFunded[funder] = 0;
        }

        // Reset the list of funders to an empty array
        s_funders = new address[](0);

        // Transfer all funds to the owner
        (bool success, bytes memory data) = payable(owner()).call{value: contractBalance}("");
        require(success, "Transfer failed");

        // Emit an event to log the withdrawal
        emit Withdrawal(owner(), contractBalance, data);
    }

    /**
     * @dev Retrieves the version of the Chainlink price feed being used.
     */
    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    /**
     * @dev Retrieves the amount of ETH funded by a specific address.
     * @param _fundingAddress The address of the funder.
     * @return The amount of ETH funded by the given address.
     */
    function getAddressToAmountFunded(address _fundingAddress) public view returns (uint256) {
        return s_funderToAmountFunded[_fundingAddress];
    }

    /**
     * @dev Retrieves the address of a funder by index.
     * @param _index The index of the funder in the funders array.
     * @return The address of the funder at the specified index.
     */
    function getFunder(uint256 _index) public view returns (address) {
        return s_funders[_index];
    }

    /**
     * @dev Retrieves the Chainlink price feed contract being used.
     * @return The address of the AggregatorV3Interface contract.
     */
    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }

    /**
     * @dev Pauses the contract, preventing certain functions from being executed.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Unpauses the contract, allowing all functions to be executed again..
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @dev Fallback function to receive ETH. Automatically calls the `fund` function.
     */
    receive() external payable {
        fund();
    }

    /**
     * @dev Fallback function to handle calls to non-existing functions or calls with data.
     */
    fallback() external payable {
        fund();
    }
}
