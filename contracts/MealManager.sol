// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MealToken.sol";
import "./MealNFT.sol";
import "./IMealManager.sol";
import "./ISuperToken.sol";

contract MealManager is IMealManager, ISuperToken {
    // Storage for order messages
    mapping(string => mapping(string => Order)) public userOrders;
    // Address of MealToken contract
    address public mealToken;
    // Address of MealNFT contract
    address public mealNFT;

    constructor(address _mealToken, address _mealNFT) {
        mealToken = _mealToken;
        mealNFT = _mealNFT;
    }

    // Function to store order message and mint tokens
    function storeOrder(
        string memory userId,
        string memory orderId,
        uint256 orderTime,
        string memory startPoint, // 商家地址
        string memory endPoint, // 用户地址
        uint256 orderAmount,
        string[] memory productIdList,
        string memory note,
        bool isSuper
    ) external {
        // Check if orderTime is earlier than the current block's timestamp
        if (orderTime > block.timestamp) {
            revert InvalidOrderTime(orderTime);
        }

        // Check if orderAmount is greater than 0
        if (orderAmount <= 0) {
            revert InvalidOrderAmount(orderAmount);
        }

        // Check if productIdList is not an empty array
        if (productIdList.length == 0) {
            revert EmptyProductIdList();
        }

        // Create a new order
        Order storage newOrder = userOrders[userId][orderId];
        newOrder.owner = msg.sender;
        newOrder.orderTime = orderTime;
        newOrder.startPoint = startPoint;
        newOrder.endPoint = endPoint;
        newOrder.orderAmount = orderAmount;
        newOrder.userId = userId;
        newOrder.orderId = orderId;
        newOrder.note = note;
        newOrder.productIdList = productIdList;

        emit OrderStored(
            msg.sender,
            orderId,
            userId
        );

        // Mint tokens based on order price
        if (!isSuper) {
            mintTokens(orderAmount, orderId, msg.sender);
        } else {
            mintSuperTokens(orderAmount, orderId, msg.sender);
        }
    }

    // Function to mint tokens based on order price
    function mintTokens(
        uint256 price,
        string memory orderId,
        address recipient
    ) public {
        if (price > 20) {
            MealNFT(mealNFT).mintTo(recipient, orderId);
            emit TokensMinted(recipient, 1, orderId, true);
        } else {
            uint tokenAmount = price * 1e16;
            MealToken(mealToken).mintTo(recipient, tokenAmount);
            emit TokensMinted(recipient, tokenAmount, orderId, false);
        }
    }

    // Function to mint tokens based on order price
    function mintSuperTokens(
        uint256 price,
        string memory orderId,
        address recipient
    ) public {
        uint tokenAmount = price * 1e18;
        MealToken(mealToken).mintTo(recipient, tokenAmount);
        emit TokensMinted(recipient, tokenAmount, orderId, false);
    }

    // Function to delete an order by its ID
    function deleteOrder(string memory userId, string memory orderId) external {
        delete userOrders[userId][orderId];
    }

    // Function to update an order by its ID
    function updateOrder(
        string memory userId,
        string memory orderId,
        uint256 orderTime,
        string memory startPoint, // 商家地址
        string memory endPoint, // 用户地址
        uint256 orderAmount,
        string[] memory productIdList,
        string memory note
    ) external {
        Order storage orderToUpdate = userOrders[userId][orderId];
        orderToUpdate.orderTime = orderTime;
        orderToUpdate.startPoint = startPoint;
        orderToUpdate.endPoint = endPoint;
        orderToUpdate.orderAmount = orderAmount;
        orderToUpdate.productIdList = productIdList;
        orderToUpdate.note = note;
    }

    // Function to get batch orders for a user
    function getBatchOrdersForUser(
        string memory userId,
        string[] memory orderIds
    ) external view returns (Order[] memory) {
        uint256 orderCount = orderIds.length;
        Order[] memory userOrdersList = new Order[](orderCount);

        for (uint256 i = 0; i < orderCount; i++) {
            userOrdersList[i] = userOrders[userId][orderIds[i]];
        }

        return userOrdersList;
    }
}
