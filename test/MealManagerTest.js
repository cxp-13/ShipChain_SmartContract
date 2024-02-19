const { expect } = require('chai');
const { ethers } = require('hardhat');
const { Contract } = require("ethers");

describe('MealManager', function () {
    let mealManager;
    let mealToken;
    let mealNFT;
    let owner;

    beforeEach(async function () {
        // 获取签名者
        owner = await ethers.provider.getSigner(0);
        console.log("owner", owner);
        // 部署代币合约
        mealToken = await ethers.deployContract('MealToken', [owner.address, "LTLL", "LTLL"], owner)
        mealNFT = await ethers.deployContract('MealNFT', [owner.address, "LTLL", "LTLL", owner.address, 200n], owner)
        // 部署外卖管理合约
        mealManager = await ethers.deployContract('MealManager', [mealToken.target, mealNFT.target], owner)
        console.log("mealManager", mealManager);
        // 将控制权转移给管理合约
        mealToken.setOwner(mealManager.target);
        mealNFT.setOwner(mealManager.target);

        console.log("mealToken.owner()", await mealToken.owner());
        console.log("mealNFT.owner()", await mealNFT.owner());

        mealManager.on("TokensMinted", (...result) => {
            console.log("TokensMinted", result);
        })
    });

    it('should store a new order', async function () {

        // 执行一些操作来存储一个新订单
        const userId = "user123";
        const orderId = "order123";
        const orderTime = Math.floor(Date.now() / 1000) - 8888; // 当前时间戳
        const shippingAddress = "123 Main St";
        const orderAmountToNFT = 200n;
        const orderAmountToToken = 5n;

        const productIdList = ["pro1", "pro2"];
        const note = "This is a test order.";

        // 调用storeOrder函数
        await mealManager.storeOrder(
            userId,
            orderId,
            orderTime,
            shippingAddress,
            orderAmountToNFT,
            ["pro1", "pro2"],
            note
        );
        // 检查NFC是否铸造成功
        let nftInfo = await mealNFT.tokenURI(0);
        expect(nftInfo).to.equal(orderId);
        console.log("nftInfo", nftInfo);

        // 调用storeOrder函数
        await mealManager.storeOrder(
            userId,
            orderId + "x",
            orderTime,
            shippingAddress,
            orderAmountToToken,
            ["pro1", "pro2"],
            note
        );
        // 检查NFC是否铸造成功
        let balanceOf = await mealToken.balanceOf(owner.address);
        let balanceOfETH = Number(ethers.formatEther(balanceOf));
        expect(balanceOfETH).to.equal(Number(orderAmountToToken) / 100);
        console.log("balanceOfETH", balanceOfETH);

        // 断言结果
        // 该方式返回的productIdList为undefined
        // const storedOrder = await mealManager.userOrders(userId, orderId);
        let arr = await mealManager.getBatchOrdersForUser(userId, [orderId]);
        let storedOrder = arr[0];
        console.log("arr", arr);
        expect(storedOrder.userId).to.equal(userId);
        expect(storedOrder.orderTime).to.equal(orderTime);
        expect(storedOrder.shippingAddress).to.equal(shippingAddress);
        expect(storedOrder.productIdList).to.deep.equal(productIdList);
        expect(storedOrder.note).to.equal(note);

    });
});