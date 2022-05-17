require("dotenv").config();

const conutNFT1155 = artifacts.require("ConutNFT1155");
const bonusRate = process.env.BONUS_RATE;
const paymentAddress = process.env.PAYMENT_ADDRESS;
const busdContractAddress = process.env.BUSD_CONTRACT_ADDRESS;
const conutContractAddress = process.env.CONUT_CONTRACT_ADDRESS;

module.exports = async function (deployer) {
    deployer.deploy(
        conutNFT1155,
        bonusRate,
        paymentAddress,
        busdContractAddress,
        conutContractAddress
    );
};
