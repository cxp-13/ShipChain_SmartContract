// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMealManager {
    struct Order {
        address owner; // 购买人的钱包地址
        uint256 orderTime; // 订单创建的时间戳
        string startPoint; // 商家地址
        string endPoint; // 用户地址
        uint256 orderAmount; // 订单的总金额
        string[] productIdList; // 存储在 MongoDB 中商品的 _id
        string userId; // 存储在 MongoDB 中用户的 _id
        string orderId;//订单ID
        string note; // 用户订单的额外备注或要求
    }

    // Event emitted when an order is stored
    event OrderStored(
        address indexed owner,
        string orderId,
        string userId
    );

    // Event emitted when tokens are minted
    event TokensMinted(
        address indexed recipient,
        uint256 amount,
        string orderId,
        bool isNFT
    );

    event OrderDeleted(address indexed user, uint index);
    event OrderUpdate(uint256 indexed index);


    // Custom error for invalid order time
    error InvalidOrderTime(uint256 orderTime);

    // Custom error for invalid order amount
    error InvalidOrderAmount(uint256 orderAmount);

    // Custom error for empty product ID list
    error EmptyProductIdList();
    error InvalidIndex(string message);

    // Function to store an order and mint tokens
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
    ) external;

    // Function to delete an order by its ID
    function deleteOrder(uint256 index) external;

    // Function to update an order by its ID
    function updateOrder(
        uint256 index,
        uint256 orderTime,
        string memory startPoint, // 商家地址
        string memory endPoint, // 用户地址
        uint256 orderAmount,
        string[] memory productIdList,
        string memory note
    ) external;

    // Function to get all orders for a user
    function getUserOrders() external view returns (Order[] memory);
}
