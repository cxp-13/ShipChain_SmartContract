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
        string memory id,
        uint256 createAt,
        string memory startPoint, // 商家地址
        string memory endPoint, // 用户地址
        uint256 amount,
        string[] memory mealIds,
        string memory note,
        bool isSuper
    ) external {
        // Check if createAt is earlier than the current block's timestamp
        if (createAt > block.timestamp) {
            revert InvalidOrderTime(createAt);
        }

        // Check if amount is greater than 0
        if (amount <= 0) {
            revert InvalidOrderAmount(amount);
        }

        // Check if mealIds is not an empty array
        if (mealIds.length == 0) {
            revert EmptyMealIdList();
        }
        Order memory newOrder = Order({
            owner: msg.sender,
            userId: userId,
            id: id,
            createAt: createAt,
            startPoint: startPoint,
            endPoint: endPoint,
            amount: amount,
            mealIds: mealIds,
            note: note
        });

        userOrders[msg.sender].push(newOrder);

        emit OrderStored(msg.sender, id, userId);

        // Mint tokens based on order price
        if (!isSuper) {
            mintTokens(amount, id, msg.sender);
        } else {
            mintSuperTokens(amount, id, msg.sender);
        }
    }

    // Function to mint tokens based on order price
    function mintTokens(
        uint256 price,
        string memory id,
        address recipient
    ) public {
        if (price > 20) {
            MealNFT(mealNFT).mintTo(recipient, id);
            emit TokensMinted(recipient, 1, id, true);
        } else {
            uint tokenAmount = price * 1e16;
            MealToken(mealToken).mintTo(recipient, tokenAmount);
            emit TokensMinted(recipient, tokenAmount, id, false);
        }
    }

    // Function to mint tokens based on order price
    function mintSuperTokens(
        uint256 price,
        string memory id,
        address recipient
    ) public {
        uint tokenAmount = price * 1e18;
        MealToken(mealToken).mintTo(recipient, tokenAmount);
        emit TokensMinted(recipient, tokenAmount, id, false);
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
        uint256 createAt,
        string memory startPoint, // 商家地址
        string memory endPoint, // 用户地址
        uint256 amount,
        string[] memory mealIds,
        string memory note
    ) external {
        if (index >= userOrders[msg.sender].length || index < 0) {
            revert InvalidIndex("index out of range");
        }

        Order storage orderToUpdate = userOrders[msg.sender][index];
        orderToUpdate.createAt = createAt;
        orderToUpdate.startPoint = startPoint;
        orderToUpdate.endPoint = endPoint;
        orderToUpdate.amount = amount;
        orderToUpdate.mealIds = mealIds;
        orderToUpdate.note = note;

        emit OrderUpdate(index);
    }

    // 获取当前用户的所有订单数组
    function getUserOrders() external view returns (Order[] memory) {
        return userOrders[msg.sender];
    }
}
