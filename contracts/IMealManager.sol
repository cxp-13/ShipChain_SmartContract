// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMealManager {
    struct Order {
        address owner; // 购买人的钱包地址
        uint256 createAt; // 订单创建的时间戳
        string startPoint; // 商家地址
        string endPoint; // 用户地址
        uint256 amount; // 订单的总金额
        string[] mealIds; // 存储在 MongoDB 中商品的 _id
        string userId; // 存储在 MongoDB 中用户的 _id
        string id;//订单ID
        string note; // 用户订单的额外备注或要求
    }

    // Event emitted when an order is stored
    event OrderStored(
        address indexed owner,
        string id,
        string userId
    );

    // Event emitted when tokens are minted
    event TokensMinted(
        address indexed recipient,
        uint256 amount,
        string id,
        bool isNFT
    );

    event OrderDeleted(address indexed user, uint index);
    event OrderUpdate(uint256 indexed index);


    // Custom error for invalid order time
    error InvalidOrderTime(uint256 createAt);

    // Custom error for invalid order amount
    error InvalidOrderAmount(uint256 amount);

    // Custom error for empty product ID list
    error EmptyMealIdList();
    error InvalidIndex(string message);

    // Function to store an order and mint tokens
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
    ) external;

    // Function to delete an order by its ID
    function deleteOrder(uint256 index) external;

    // Function to update an order by its ID
    function updateOrder(
        uint256 index,
        uint256 createAt,
        string memory startPoint, // 商家地址
        string memory endPoint, // 用户地址
        uint256 amount,
        string[] memory mealIds,
        string memory note
    ) external;

    // Function to get all orders for a user
    function getUserOrders() external view returns (Order[] memory);
}
