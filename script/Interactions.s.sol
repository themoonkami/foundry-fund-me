// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

// Fund
// Withdraw

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether; // 0.01 ether = 10000000000000000 wei

    function fundFundMe(address fundMeAddress) public payable {
        FundMe(payable(fundMeAddress)).fund{value: msg.value}();
        console.log("Funded FundMe with %s", msg.value);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        vm.startBroadcast();
        fundFundMe(mostRecentlyDeployed);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether; // 0.01 ether = 10000000000000000 wei

    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        // This is the same as calling FundMe.withdraw() but we are using the contract address
        FundMe(mostRecentlyDeployed).withdraw();
        vm.stopBroadcast();
        // This is the same as calling FundMe.cheaperWithdraw() but we are using the contract address

        console.log("Withdrew from FundMe with %s", SEND_VALUE);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        vm.startBroadcast();
        withdrawFundMe(mostRecentlyDeployed);
        vm.stopBroadcast();
    }
}
