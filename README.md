# 1. Go
```
git clone https://github.com/QuanLe161199/nft-marketplace.git
cd nft-marketplace
npm install
```
# 2. Edit .env file
```
PRIVATE_KEY=PRIVATE_KEY_OF_OWNER_WALLET
BUSD_CONTRACT_ADDRESS=PAYMENT_TOKEN_ADDRESS_1
CONUT_CONTRACT_ADDRESS=PAYMENT_TOKEN_ADDRESS_2
BONUS_RATE=BONUS_RATE_OF_YOUR_MARKETPLACE
PAYMENT_ADDRESS=PAYMENT_WALLET_ADDRESS
BSC_SCAN_API_KEY=YOUR_API_KEY
```
# 3. Compile smart contract
```
truffle compile
```
# 4. Test smart contract
Open another terminal:
```
ganache-cli
```
At the project root directory:
```
truffle test --network development
```
# 5. Deploy smart contract
Deploy on testnet:
```
truffle migrate --network testnet
```

Deploy on mainnet:
```
truffle migrate --network bsc
```
# 6. Verify  smart contract
Verify on testnet:
```
truffle run verify ConutNFT1155@{contract-address} --network testnet
```
Verify on mainnet:
```
truffle run verify ConutNFT1155@{contract-address} --network bsc
```
