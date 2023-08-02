// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

//run test with `forge test` command, add -vv to show Logs
contract FundMeTest is Test {
    FundMe fundMe;

    uint256 constant VALUE_SEND = 0.1 ether; // or 10e18
    uint256 constant STARTING_BALANCE = 10 ether;
    address FAKE_SENDER = makeAddr("Softcoder");

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(FAKE_SENDER, STARTING_BALANCE); //WE GIVE OUR FAKE USER 10 ETHER AS A STARTING BALANCE
    }

    function testMinimumUsdIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testGetVersionIsCorrect() public {
        assertEq(fundMe.getVersion(), 4);
    }

    //test fund fails due to insufficient minimum amount

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); //expect the next line code to revert or fails
        fundMe.fund();
    }

    //test that fund pass with enough eth

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(FAKE_SENDER);
        fundMe.fund{value: VALUE_SEND}(); //sending 10eth as value
        uint256 amountFunded = fundMe.getAddressToAmountFunded(FAKE_SENDER);
        assertEq(amountFunded, VALUE_SEND);
    }

    modifier funded() {
        vm.prank(FAKE_SENDER);
        fundMe.fund{value: VALUE_SEND}();
        _;
    }

    function testAddFunderToArrayOfFunders() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, FAKE_SENDER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(FAKE_SENDER);
        vm.expectRevert();
        fundMe.withdraw(); //msg.sender == FAKE_SENDER which is not the owner of the contract, it is expect to revert
    }
}
