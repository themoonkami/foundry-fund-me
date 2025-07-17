/* 
1) Get funds from users 
2) Withdraw this funding to external address
3) Set minimum funding value in USD
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// constant, immutable both help to reduce gas cost
// constant makes you edit the variable name to all caps with an underscore in between
// for immutable, you do i_name

error FundMe__NotOwner();
// whenyou name an error, you can add the contract name and __ to help you easily identify the error source

contract FundMe {
    using PriceConverter for uint256;

    // uint256 public myValue = 1;
    uint256 public constant MINIMUM_USD = 20e18;

    address[] public s_funders;
    mapping(address funder => uint256 amountFunded)
        private s_addressToAmountFunded;

    address public immutable i_owner;
    AggregatorV3Interface public s_priceFeed;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        // myValue = myValue + 2;

        // uint256 ethAmountInUsd = getConversionRate(msg.value);
        // require(ethAmountInUsd >= MINIMUM_USD, "Didn't send enough ETH!");

        // require(getConversionRate(msg.value) >= MINIMUM_USD, "not enough ETH");
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "not enough ETH"
        );

        // msg.value.getConversionRate();
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] =
            s_addressToAmountFunded[msg.sender] +
            msg.value;
    }

    function cheaperWithdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;
        for (
            uint256 funderIndex = 0;
            funderIndex < fundersLength;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0; // reset the mapping
        }

        s_funders = new address[](0); // reset the array

        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    function withdraw() public onlyOwner {
        // reset the mapping function using a for loop??
        // for (start index, ending index, jump amount)

        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        // reset the array
        s_funders = new address[](0); // means the new array should start from zero

        // now to actually wothdraw the funds

        // - transfer
        // now, "this" replies to the entire code and you have to add payable.gas linmit is 2300, above that will throw an error
        //payable(msg.sender).transfer(address(this).balance);

        // - send
        // gas limit is 2300 as well, but you have to include an error message so it reverts (bool).
        //bool sendSuccess = payable(msg.sender).send(address(this).balance);
        //require(sendSuccess, "transfer failed");

        // - call
        // no gas limit. you can use it to call any fxn in eth withoiut having the ABI. looks similar to send
        // has a .call("") where you put any information about what we want to call
        // call returns two variables

        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    modifier onlyOwner() {
        //require(msg.sender == i_owner, "Sender is not owner");
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function getAddressToAmountFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }
    function getOwner() external view returns (address) {
        return i_owner;
    }
}
