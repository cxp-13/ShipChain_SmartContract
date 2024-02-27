// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MealNFT.sol";
import "./IMealManager.sol";
import "./ISuperToken.sol";
import "@thirdweb-dev/contracts/base/ERC20Base.sol";

contract MealManager is IMealManager, ISuperToken, ERC20Base {
    // 存储订单信息 钱包地址 -》 订单数组

    mapping(address => Order[]) public userOrders;
    // Address of MealNFT contract
    address public mealNFT;

    constructor(
        address _mealNFT,
        address _defaultAdmin,
        string memory _name,
        string memory _symbol
    ) ERC20Base(_defaultAdmin, _name, _symbol) {
        mealNFT = _mealNFT;
    }

    // Function to store order message and mint tokens
    function storeOrder(
        string memory userId,
        string memory id,
        string memory startPoint, // 商家地址
        string memory endPoint, // 用户地址
        uint256 amount,
        string[] memory mealIds,
        string memory note,
        bool isSuper
    ) external {
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
            createAt: block.timestamp,
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
            mintTo(recipient, tokenAmount);
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
        mintTo(recipient, tokenAmount);
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
        string memory startPoint, // 商家地址
        string memory endPoint, // 用户地址
        string memory note
    ) external {
        if (index >= userOrders[msg.sender].length || index < 0) {
            revert InvalidIndex("index out of range");
        }

        Order storage orderToUpdate = userOrders[msg.sender][index];
        orderToUpdate.startPoint = startPoint;
        orderToUpdate.endPoint = endPoint;
        orderToUpdate.note = note;

        emit OrderUpdate(index);
    }

    // 获取当前用户的所有订单数组
    function getUserOrders() external view returns (Order[] memory) {
        return userOrders[msg.sender];
    }
}
