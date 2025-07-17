//SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.2 ether; // 0.2 ether = 200000000000000000 wei
    uint256 constant STARTING_BALANCE = 1 ether; // 1 ether = 1000000000000000000 wei

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); // give USER 10 ether
    }

    function testMinimumDollarIsTwenty() public view {
        assertEq(fundMe.MINIMUM_USD(), 20e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    /* function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }*/

      function testPriceFeedVersionIsAccurate() public view {
        if (block.chainid == 11155111) {
            uint256 version = fundMe.getVersion();
            assertEq(version, 4);
        } else if (block.chainid == 1) {
            uint256 version = fundMe.getVersion();
            assertEq(version, 6);
        }
  }   

  function testFundFailsWithoutEnoughEth() public {
    vm.expectRevert(); // we expect the next line/call to revert.
    fundMe.fund();
  }

  function testFundUpdatesFundedDataStructure() public {

    vm.prank(USER); // we are pretending that the next call is made by USER 

    fundMe.fund{value: SEND_VALUE}(); 

    uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
    assertEq(amountFunded, SEND_VALUE);
  }

 function testWithdrawFromMultipleFunders() public {
    uint160 numberOfFunders = 10;
    uint160 startingFunderIndex = 1;

    for (uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++) {
        // we get hoax from stdcheats
        // prank + deal
        // vm.deal + vm.prank combo
        hoax(address(i), SEND_VALUE); // vm.deal + vm.prank combo
        fundMe.fund{value: SEND_VALUE}();
    }

    uint256 startingFundMeBalance = address(fundMe).balance;
    uint256 startingOwnerBalance = fundMe.getOwner().balance;

    vm.startPrank(fundMe.getOwner());
    fundMe.withdraw();
    vm.stopPrank();

    uint256 endingOwnerBalance = fundMe.getOwner().balance;
    uint256 endingFundMeBalance = address(fundMe).balance;

    // Use assertEq from forge-std/Test.sol to give better error messages and avoid overflow
    assertEq(endingFundMeBalance, 0); // we are checking that the balance of the contract is zero
    assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance); // we are checking that the balance of the owner
    // is equal to the starting balance of the contract + the starting balance of the owner
   
}


  function testWithdrawFromMultipleFundersCheaper() public {
    uint160 numberOfFunders = 10;
    uint160 startingFunderIndex = 1;

    for (uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++) {
        hoax(address(i), SEND_VALUE); // Simulate funder with ETH and a call
        fundMe.fund{value: SEND_VALUE}();
    }

    uint256 startingFundMeBalance = address(fundMe).balance;
    uint256 startingOwnerBalance = fundMe.getOwner().balance;

    vm.startPrank(fundMe.getOwner());
    fundMe.cheaperWithdraw(); // call the gas-optimized version
    vm.stopPrank();

    uint256 endingOwnerBalance = fundMe.getOwner().balance;
    uint256 endingFundMeBalance = address(fundMe).balance;

    assertEq(endingFundMeBalance, 0);
    assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance);
}


}
