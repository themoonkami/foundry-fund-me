// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract InteractionsTest is Test {
    FundMe public fundMe;
    DeployFundMe public deployFundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.2 ether;
    uint256 constant STARTING_BALANCE = 1 ether;

    function setUp() external {
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();

        vm.deal(USER, STARTING_BALANCE); // Give USER 1 ether
    }

    function testUserCanFundInteractions() public {
        // Simulate USER calling fund() directly
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }
}
