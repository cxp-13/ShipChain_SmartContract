// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISuperToken {
    // Function to mint tokens based on order price
    function mintSuperTokens(
        uint256 price,
        string memory orderId,
        address recipient
    ) external;

    function mintTokens(
        uint256 price,
        string memory orderId,
        address recipient
    ) external;
}