// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract DecentralizedVPNPayment {
    address public owner;
    uint256 public ratePerMinute; // in wei per minute
    mapping(address => uint256) public balances;

    event PaymentReceived(address indexed user, uint256 amount, uint256 minutesPaid);
    event Withdraw(address indexed provider, uint256 amount);

    constructor(uint256 _ratePerMinute) {
        owner = msg.sender;
        ratePerMinute = _ratePerMinute;
    }

    // Users pay VPN providers per unit of time
    function payForVPN(uint256 usageMinutes) external payable {
        require(usageMinutes > 0, "Usage time must be greater than zero");
        uint256 requiredAmount = usageMinutes * ratePerMinute;
        require(msg.value >= requiredAmount, "Insufficient payment");

        uint256 excess = msg.value - requiredAmount;
        if (excess > 0) {
            payable(msg.sender).transfer(excess);
        }

        balances[owner] += requiredAmount;
        emit PaymentReceived(msg.sender, requiredAmount, usageMinutes);
    }

    // Provider withdraws collected funds
    function withdraw() external {
        require(msg.sender == owner, "Only provider can withdraw");
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No balance to withdraw");

        balances[msg.sender] = 0;
        payable(owner).transfer(amount);
        emit Withdraw(msg.sender, amount);
    }
}
