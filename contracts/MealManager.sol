// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MealToken.sol";
import "./MealNFT.sol";
import "./IMealManager.sol";
import "./ISuperToken.sol";

contract MealManager is IMealManager, ISuperToken {
    // 存储订单信息 钱包地址 -》 订单数组

    mapping(address => Order[]) public userOrders;
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
        Order memory newOrder = Order({
            owner: msg.sender,
            userId: userId,
            orderId: orderId,
            orderTime: orderTime,
            startPoint: startPoint,
            endPoint: endPoint,
            orderAmount: orderAmount,
            productIdList: productIdList,
            note: note
        });

        userOrders[msg.sender].push(newOrder);

        emit OrderStored(msg.sender, orderId, userId);

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

    function deleteOrder(uint index) external {
        if (index >= userOrders[msg.sender].length || index < 0) {
            revert InvalidIndex("index out of range");
        }

        Order[] storage orders = userOrders[msg.sender];
        orders[index] = orders[orders.length - 1];
        orders.pop();

        emit OrderDeleted(msg.sender, index);
    }

    // Function to update an order by its index in the array
    function updateOrder(
        uint256 index,
        uint256 orderTime,
        string memory startPoint, // 商家地址
        string memory endPoint, // 用户地址
        uint256 orderAmount,
        string[] memory productIdList,
        string memory note
    ) external {
        if (index >= userOrders[msg.sender].length || index < 0) {
            revert InvalidIndex("index out of range");
        }

        Order storage orderToUpdate = userOrders[msg.sender][index];
        orderToUpdate.orderTime = orderTime;
        orderToUpdate.startPoint = startPoint;
        orderToUpdate.endPoint = endPoint;
        orderToUpdate.orderAmount = orderAmount;
        orderToUpdate.productIdList = productIdList;
        orderToUpdate.note = note;

        emit OrderUpdate(index);
    }

    // 获取当前用户的所有订单数组
    function getUserOrders() external view returns (Order[] memory) {
        return userOrders[msg.sender];
    }
}
