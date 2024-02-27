// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMealManager {
    struct Order {
        address owner; // 购买人的钱包地址
        string startPoint; // 商家地址
        string endPoint; // 用户地址
        uint256 createAt;//创建时间
        uint256 amount; // 订单的总金额
        string[] mealIds; // 存储在 MongoDB 中商品的 _id
        string userId; // 存储在 MongoDB 中用户的 _id
        string id;//订单ID
        string note; // 用户订单的额外备注或要求
    }

    event OrderStored(
        address indexed owner,
        string id,
        string userId
    );

    event TokensMinted(
        address indexed recipient,
        uint256 amount,
        string id,
        bool isNFT
    );

    event OrderDeleted(address indexed user, uint index);
    event OrderUpdate(uint256 indexed index);

    error InvalidOrderAmount(uint256 amount);
    error EmptyMealIdList();
    error InvalidIndex(string message);

    function storeOrder(
        string memory userId,
        string memory id,
        string memory startPoint, // 商家地址
        string memory endPoint, // 用户地址
        uint256 amount,
        string[] memory mealIds,
        string memory note,
        bool isSuper
    ) external;

    function deleteOrder(uint256 index) external;

    function updateOrder(
        uint256 index,
        string memory startPoint, // 商家地址
        string memory endPoint, // 用户地址
        string memory note
    ) external;

    function getUserOrders() external view returns (Order[] memory);
}
