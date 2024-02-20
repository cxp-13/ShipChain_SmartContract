# ShipChain

ShipChain 是一个基于 Web3 技术的去中心化应用（DApp），旨在为用户提供方便的外卖点餐信息记录服务，并通过区块链技术实现代币铸造与奖励机制。
### 特别提醒：该项目使用hardhat初始化项目。只是使用thirdweb sdk中的contract部分代码，具体部署详情请参考thirdweb官方教程https://portal.thirdweb.com/contracts。

## 功能

1. **记录外卖信息**
   - 用户每天可通过填写表单记录自己的三餐外卖数据。
     - 早餐（Breakfast）：通常在早上7点到10点之间，是一天中的第一顿主要饭食。
     - 午餐（Lunch）：通常在中午11点到下午2点之间，是一天中的第二顿主要饭食。
     - 晚餐（Dinner）：通常在下午5点到晚上8点之间，是一天中的第三顿主要饭食。
   - 如果用户所填写的外卖订单价格超过 20，系统将铸造一个非同质化代币（NFT）。
   - 如果用户填写的外卖订单价格在 20 以下，系统将根据订单价格铸造对应数量 * 0.01 eth 单位的 LTLL 代币。

2. **每日时区增强**
   - 每天选定一个时区作为铸造代币增强，即直接铸造对应订单价格的 LTLL 代币。

## 技术栈

- **智能合约**：
  - 使用 Solidity 和 Hardhat 框架开发，实现 NFT 和代币铸造、订单信息管理、时区增强等功能。
  - 使用 Chai、Mocha 等编写单元测试。
  - 使用 Thirdweb SDK 部署至测试网。

- **前端 + 后端**：
  - 使用 Next.js + TypeScript + React.js，实现填写订单信息和外卖订单数据展示。
  - Clerk 存储登录的用户信息，uploadthing 存储订单图片，MongoDB 存储商品和用户数据。

- **区块链交互**：
  - 使用 Thirdweb React SDK 与智能合约进行交互，调用智能合约实现数据记录和代币铸造。

## 安装

1. 克隆该仓库:
   ```bash
   git clone https://github.com/cxp-13/ShipChain_SmartContract.git
   ```

2. 安装依赖:
   ```bash
   cd shipchain
   npm install
   ```

3. 运行应用:
详情查看hardhat官网教程https://hardhat.org/hardhat-runner/docs/getting-started#quick-start

## 贡献

欢迎贡献！请随意提交 pull request。

## 许可证

本项目使用 [MIT License](LICENSE) 许可证。
