// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/ENRToken.sol";

contract ENRTokenTest is Test {
    ENRToken public enrToken;
    address public owner;
    address public user;

    function setUp() public {
        owner = address(this); // test kontrat sahibi
        user = vm.addr(1);     // test kullanıcısı
        enrToken = new ENRToken(owner);

        // Owner'a biraz ETH gönderelim
        vm.deal(owner, 10 ether);
        // Kullanıcıya da ETH gönderelim
        vm.deal(user, 10 ether);
    }

    function testDeposit() public {
        vm.prank(user);
        enrToken.deposit{value: 0.001 ether}();

        uint256 userBalance = enrToken.balanceOf(user);
        assertEq(userBalance, 1 * 10 ** enrToken.decimals(), "Deposit failed: Incorrect ENR amount");
    }

    function testDepositFailsIfNotExactAmount() public {
        vm.prank(user);
        vm.expectRevert("Deposit must be exactly 0.001 ETH");
        enrToken.deposit{value: 0.002 ether}();
    }

    function testWithdraw() public {
    // Önce kullanıcıya 10 ENR verelim
    vm.prank(owner);
    enrToken.transfer(user, 10 * 10 ** enrToken.decimals());

    // Kontrata ETH gönderelim
    vm.deal(address(enrToken), 10 ether);

    vm.prank(user);
    enrToken.withdraw(10);

    uint256 userBalanceAfterWithdraw = enrToken.balanceOf(user);
    assertEq(userBalanceAfterWithdraw, 0, "Withdraw failed: ENR not returned");

    uint256 userEthBalance = user.balance;
    assertGt(userEthBalance, 9 ether, "Withdraw failed: ETH not received");
}

    function testWithdrawFailsIfNotEnoughTokens() public {
        vm.prank(user);
        vm.expectRevert("Insufficient ENR tokens");
        enrToken.withdraw(1);
    }

    function testGetContractBalance() public {
        payable(address(enrToken)).transfer(2 ether);

        uint256 contractBalance = enrToken.getContractBalance();
        assertEq(contractBalance, 2 ether, "Contract balance incorrect");
    }

    function testReceiveFunctionality() public {
        vm.prank(user);
        payable(address(enrToken)).transfer(1 ether);

        uint256 balance = enrToken.getContractBalance();
        assertEq(balance, 1 ether, "Receive fallback failed");
    }
}
