// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Decentralized Subscription Service
/// @notice A simple contract to manage subscriptions using ETH
contract Project {
    address public owner;
    uint256 public subscriptionFee;
    uint256 public subscriptionDuration; // in seconds

    struct Subscriber {
        uint256 expiry;
    }

    mapping(address => Subscriber) public subscribers;

    event Subscribed(address indexed user, uint256 expiry);
    event SubscriptionCancelled(address indexed user);

    constructor(uint256 _fee, uint256 _duration) {
        owner = msg.sender;
        subscriptionFee = _fee; // e.g., 0.01 ETH
        subscriptionDuration = _duration; // e.g., 30 days = 2592000 seconds
    }

    /// @notice Subscribe or renew subscription
    function subscribe() external payable {
        require(msg.value == subscriptionFee, "Incorrect fee");
        uint256 currentExpiry = subscribers[msg.sender].expiry;

        if (currentExpiry < block.timestamp) {
            subscribers[msg.sender].expiry = block.timestamp + subscriptionDuration;
        } else {
            subscribers[msg.sender].expiry += subscriptionDuration;
        }

        emit Subscribed(msg.sender, subscribers[msg.sender].expiry);
    }

    /// @notice Cancel active subscription
    function cancelSubscription() external {
        require(subscribers[msg.sender].expiry > block.timestamp, "No active subscription");
        subscribers[msg.sender].expiry = block.timestamp;
        emit SubscriptionCancelled(msg.sender);
    }

    /// @notice Check if user is subscribed
    function isSubscribed(address user) external view returns (bool) {
        return subscribers[user].expiry > block.timestamp;
    }

    /// @notice Withdraw collected fees (only owner)
    function withdraw() external {
        require(msg.sender == owner, "Not owner");
        payable(owner).transfer(address(this).balance);
    }
}

