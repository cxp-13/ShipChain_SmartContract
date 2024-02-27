const { expect } = require('chai');
const { ethers } = require('hardhat');
const { Contract } = require("ethers");
const isTimeZone = require("../utils/time")

describe('MealManager', function () {
    let mealManager;
    let mealNFT;
    let owner;

    beforeEach(async function () {
        // 获取签名者
        owner = await ethers.provider.getSigner(0);
        console.log("owner", owner);
        // 部署NFT合约
        mealNFT = await ethers.deployContract('MealNFT', [owner.address, "LTLL", "LTLL", owner.address, 200n], owner)
        // 部署外卖管理合约
        mealManager = await ethers.deployContract('MealManager', [mealNFT.target, owner.address, "LTLL", "LTLL"], owner)
        mealNFT.setOwner(mealManager.target);
        
        console.log("mealNFT.owner()", await mealNFT.owner());

        mealManager.on("TokensMinted", (...result) => {
            console.log("TokensMinted", result);
        })
    });

    it('test store order and mint token', async function () {
        // 执行一些操作来存储一个新订单
        const userId = "user123";
        const id = "order123";
        const startPoint = "猪脚饭店";
        const endPoint = "新围仔";
        const orderAmountToToken = 5n;
        const mealIds = ["pro1", "pro2"];
        const note = "This is a test order.";

        // 调用storeOrder函数
        await mealManager.storeOrder(
            userId,
            id,
            startPoint,
            endPoint,
            orderAmountToToken,
            mealIds,
            note,
            false
        );
        // 检查Token是否铸造成功
        let balanceOf = await mealManager.balanceOf(owner.address);
        let balanceOfETH = Number(ethers.formatEther(balanceOf));
        expect(balanceOfETH).to.equal(Number(orderAmountToToken) / 100);
        console.log("balanceOfETH", balanceOfETH);
        // 断言结果
        let myOrders = await mealManager.getUserOrders();
        let storedOrder = myOrders[0];
        console.log("mint token myOrders", myOrders);
        expect(storedOrder.userId).to.equal(userId);
        expect(storedOrder.startPoint).to.equal(startPoint);
        expect(storedOrder.endPoint).to.equal(endPoint);
        expect(storedOrder.mealIds).to.deep.equal(mealIds);
        expect(storedOrder.note).to.equal(note);
    });

    it('test store order and mint NFT', async function () {

        // 执行一些操作来存储一个新订单
        const userId = "user123";
        const id = "order123";
        const startPoint = "猪脚饭店";
        const endPoint = "新围仔";
        const orderAmountToNFT = 200n;
        const mealIds = ["pro1", "pro2"];
        const note = "This is a test order.";

        // 调用storeOrder函数
        await mealManager.storeOrder(
            userId,
            id,
            startPoint,
            endPoint,
            orderAmountToNFT,
            mealIds,
            note,
            false
        );

        // 检查NFC是否铸造成功
        let nftInfo = await mealNFT.tokenURI(0);
        expect(nftInfo).to.equal(id);
        console.log("nftInfo", nftInfo);
        // 断言结果
        // 该方式返回的mealIds为undefined
        // const storedOrder = await mealManager.userOrders(userId, id);
        let myOrders = await mealManager.getUserOrders();
        let storedOrder = myOrders[0];
        console.log("mint NFT myOrders", myOrders);
        expect(storedOrder.userId).to.equal(userId);
        expect(storedOrder.startPoint).to.equal(startPoint);
        expect(storedOrder.endPoint).to.equal(endPoint);
        expect(storedOrder.mealIds).to.deep.equal(mealIds);
        expect(storedOrder.note).to.equal(note);
    });

    it("delete a order", async function () {
        // 执行一些操作来存储一个新订单
        const userId = "user";
        const id = "order123";
        const startPoint = "猪脚饭店";
        const endPoint = "新围仔";
        const orderAmountToNFT = 200n;
        const mealIds = ["pro1", "pro2"];
        const note = "This is a test order.";
        // 调用storeOrder函数
        for (let index = 0; index < 5; index++) {
            await mealManager.storeOrder(
                userId + index,
                id,
                startPoint,
                endPoint,
                orderAmountToNFT,
                mealIds,
                note,
                false
            );
        }

        // 删除该order, 将最后一个元素与被删除元素互换。
        await mealManager.deleteOrder(0);
        const myOrders = await mealManager.getUserOrders();
        const firstOrder = myOrders[0];
        console.log("deletedOrder myOrders", myOrders);
        // 其他属性类似
        expect(myOrders.length).to.equal(4);
        expect(firstOrder.userId).to.equal("user4");
    })

    it("update a order", async function () {
        // 执行一些操作来存储一个新订单
        const userId = "user123";
        const id = "order123";
        const startPoint = "猪脚饭店";
        const endPoint = "新围仔";
        const orderAmountToNFT = 200n;
        const mealIds = ["pro1", "pro2"];
        const note = "This is a test order.";
        const index = 0;
        // 调用storeOrder函数
        await mealManager.storeOrder(
            userId,
            id,
            startPoint,
            endPoint,
            orderAmountToNFT,
            mealIds,
            note,
            false
        );
        // 更新该order的mealIds
        const newNote = "test new node";
        await mealManager.updateOrder(
            index,
            startPoint,
            endPoint,
            newNote
        );
        const myOrders = await mealManager.getUserOrders();
        console.log("updateOrders myOrders", myOrders);
        let updateOrder = myOrders[0];
        // 其他属性类似
        expect(updateOrder.note).to.deep.equal(newNote);
    })

    it("test super mode", async function () {
        // 执行一些操作来存储一个新订单
        const userId = "user123";
        const id = "order123";
        const startPoint = "猪脚饭店";
        const endPoint = "新围仔";
        const orderAmount = 200n;
        const mealIds = ["pro1", "pro2"];
        const note = "This is a test order.";
        const selectTimeZone = 8;
        const isSuper = isTimeZone(selectTimeZone);
        console.log("isSuper", isSuper);
        // 调用storeOrder函数
        await mealManager.storeOrder(
            userId,
            id,
            startPoint,
            endPoint,
            orderAmount,
            mealIds,
            note,
            isSuper
        );

        // 检查Token是否铸造成功
        let balanceOf = await mealManager.balanceOf(owner.address);
        let balanceOfETH = Number(ethers.formatEther(balanceOf));
        expect(balanceOfETH).to.equal(Number(orderAmount));
        console.log("balanceOfETH", balanceOfETH);
    })
});


