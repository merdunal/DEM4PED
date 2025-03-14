// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract ENRToken is ERC20, Ownable {
    uint256 public tokenPrice = 0.001 ether;

    constructor(address initialOwner) ERC20("ENR Token", "ENR") Ownable(initialOwner) {
        _mint(owner(), 1_000_000 * 10 ** decimals());
    }

    function deposit() external payable {
        require(msg.value == tokenPrice, "Deposit must be exactly 0.001 ETH");
        _transfer(owner(), msg.sender, 1 * 10 ** decimals());
    }

    function withdraw(uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, "Insufficient ENR tokens");
        uint256 ethAmount = amount * tokenPrice;
        require(address(this).balance >= ethAmount, "Contract does not have enough ETH");
        amount = amount * 1 ether;
        _transfer(msg.sender, owner(), amount);
        payable(msg.sender).transfer(ethAmount);
    }

    function ownerWithdraw(uint256 amount) external onlyOwner {
        payable(owner()).transfer(amount);
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable {}
}
