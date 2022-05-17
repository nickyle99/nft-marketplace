const ConutNFT1155 = artifacts.require("ConutNFT1155");

const {
    BN,
    constants,
    expectEvent,
    expectRevert,
} = require("@openzeppelin/test-helpers");

contract("ConutNFT1155", async (accounts) => {
    let conutNFT1155 = null;
    before(async () => {
        conutNFT1155 = await ConutNFT1155.deployed(
            25,
            0xb7e5f9e78e18b3f0df1e4ca0878c4d5001eabbaa,
            0xb7e5f9e78e18b3f0df1e4ca0878c4d5001eabbaa,
            0xb7e5f9e78e18b3f0df1e4ca0878c4d5001eabbaa
        );
    });

    it("Should be mint a token", async () => {
        const sender = accounts[0];
        const URI =
            "https://bafybeifty3noqyeyjrxpn6zbnhh6jjlcojkxtl3beczrajffly7gllge7m.ipfs.nftstorage.link/1.json";
        const amount = 1000;
        await conutNFT1155.mint(amount, URI, {
            from: sender,
            value: new BN(0),
        });
        // check amount copies of nft
        const nftItem = await conutNFT1155.nftItem(1, sender);
        assert.equal(nftItem.totalAmount.toNumber(), amount);

        // check token uri
        const tokenURI = await conutNFT1155.tokenURIs(1);
        assert.equal(tokenURI, URI);
    });

    it("should be post for sell a token", async () => {
        const sender = accounts[0];
        const id = 1;
        const sellAmount = 500;
        const price = 10 ** 10;
        const paymentToken = 1;
        await conutNFT1155.sell(id, sellAmount, price, paymentToken, {
            from: sender,
            value: new BN(0),
        });

        const nftItem = await conutNFT1155.nftItem(id, sender);
        assert.equal(nftItem.sellAmount.toNumber(), sellAmount);
        assert.equal(nftItem.price.toNumber(), price);
        assert.equal(nftItem.paymentToken.toNumber(), paymentToken);
    });

    it("should be cancel sell of a token", async () => {
        const sender = accounts[0];
        const id = 1;
        await conutNFT1155.cancelSell(id, {
            from: sender,
            value: new BN(0),
        });

        const nftItem = await conutNFT1155.nftItem(id, sender);
        assert.equal(nftItem.selling, false);
    });

    it("should be resell a token", async () => {
        // sell a token
        const sender = accounts[0];
        const id = 1;
        const sellAmount = 500;
        const price = 10 ** 10;
        const paymentToken = 1;
        await conutNFT1155.sell(id, sellAmount, price, paymentToken, {
            from: sender,
            value: new BN(0),
        });

        // resell the token
        const newSellAmount = 600;
        const newSellPrice = 10 ** 9;
        const newPaymentToken = 0;
        await conutNFT1155.resell(
            id,
            newSellAmount,
            newSellPrice,
            newPaymentToken,
            {
                from: sender,
                value: new BN(0),
            }
        );

        // check
        const nftItem = await conutNFT1155.nftItem(id, sender);
        assert.equal(nftItem.sellAmount.toNumber(), newSellAmount);
        assert.equal(nftItem.price.toNumber(), newSellPrice);
        assert.equal(nftItem.paymentToken.toNumber(), newPaymentToken);
    });

    it("should be buy a token", async () => {
        const id = 1;
        const seller = accounts[0];
        const buyer = accounts[1];

        // the token when unsold
        const nftItem = await conutNFT1155.nftItem(id, seller);

        // buy the token
        await conutNFT1155.buy(id, seller, {
            from: buyer,
            value: new BN(nftItem.sellAmount * nftItem.price),
        });

        const nftItemSeller = await conutNFT1155.nftItem(id, seller);
        const nftItemBuyer = await conutNFT1155.nftItem(id, buyer);

        //check
        assert.equal(nftItemSeller.selling, false);
        assert.equal(nftItemBuyer.selling, false);
        assert.equal(
            nftItemSeller.totalAmount.toNumber(),
            nftItem.totalAmount.toNumber() - nftItem.sellAmount.toNumber()
        );
        assert.equal(
            nftItemBuyer.totalAmount.toNumber(),
            nftItem.sellAmount.toNumber()
        );
    });
});
