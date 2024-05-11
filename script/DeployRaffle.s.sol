// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Rafflle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscribtion, FundSubscribtion, AddConsumer} from "./interactions.s.sol";

contract DeployRaffle is Script {
    function run() external returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        (
            uint256 entranceFee,
            uint256 interval,
            address vrfCoordinator,
            bytes32 gasLane,
            uint64 subscribtionId,
            uint32 callbackGasLimit,
            address link,
            uint256 deployerKey
        ) = helperConfig.activeNetworkConfig();

        if (subscribtionId == 0) {
            // We are going to need to create a subscribtion!
            CreateSubscribtion createSubscribtion = new CreateSubscribtion();
            subscribtionId = createSubscribtion.createSubscribtion(
                vrfCoordinator,
                deployerKey
            );

            // Fund it!
            FundSubscribtion fundSubscribtion = new FundSubscribtion();
            fundSubscribtion.fundSubscribtion(
                vrfCoordinator,
                subscribtionId,
                link,
                deployerKey
            );
        }

        vm.startBroadcast();
        Raffle raffle = new Raffle(
            entranceFee,
            interval,
            vrfCoordinator,
            gasLane,
            subscribtionId,
            callbackGasLimit
        );
        vm.stopBroadcast();

        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(
            address(raffle),
            vrfCoordinator,
            subscribtionId,
            deployerKey
        );
        return (raffle, helperConfig);
    }
}
