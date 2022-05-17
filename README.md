# 1. Go
```
git clone git@github.com:QuanLe161199/NFT-Marketplace.git
cd NFT-Marketplace
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
# 3. Compile and test smart contract
```
truffle compile
truffle test
```
# 4. Deploy the smart contract
Deploy on testnet:
```
truffle migrate --network testnet
```

Deploy on mainnet:
```
truffle migrate --network bsc
```
# 5. Verify the smart contract
Verify on testnet:
```
truffle run verify ConutNFT1155@{contract-address} --network testnet
```
Verify on mainnet:
```
truffle run verify ConutNFT1155@{contract-address} --network bsc
```
