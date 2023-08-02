// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//1. Deploy mocks when we are on local anvil chain
//2. Kepp track of contract address across different chains
//3. Sepolia ETH/USD
//4. Mainnet ETH/USD

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    constructor() {
        initConfig();
    }

    function initConfig() internal {
        if (block.chainid == 11155111) {
            activeNetwork = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetwork = getMainnetEthConfig();
        } else {
            activeNetwork = getOrCreateAnvilEthConfig();
        }
    }

    struct NetworkConfig {
        address priceFeed;
    }

    NetworkConfig public activeNetwork;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        //do some logic
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory mainnetConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return mainnetConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        //check if there is an existing active config network address
        if (activeNetwork.priceFeed != address(0)) {
            return activeNetwork;
        }
        //deploy mock v3 aggregator
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();
        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
        //get the contract address
    }
}
