// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract ConutNFT1155 is ERC1155 {
    using SafeMath for uint256;

    uint256 private _tokenIds;
    uint256 private _bonusRate; // per thousand
    address private _paymentAddress;
    address private _owner;
    IERC20 public busdContractAddress;
    IERC20 public conutContractAddress;

    // enter the billing address and bonus rate when creating the smart contract
    constructor(
        uint256 _originalBonusRate,
        address _originalPaymentAddress,
        address _busdContractAddress,
        address _conutContractAddress
    ) ERC1155("") {
        require(
            _originalPaymentAddress != address(0),
            "Payment address is the zero address"
        );
        require(
            _busdContractAddress != address(0),
            "BUSD contract address is the zero address"
        );
        require(
            _conutContractAddress != address(0),
            "CONUT contract address is the zero address"
        );
        require(
            _originalBonusRate > 0,
            "The bonus rate must be greater than 0"
        );
        require(
            _originalBonusRate < 1000,
            "The bonus rate must be less than 1000"
        );

        _paymentAddress = _originalPaymentAddress;
        _bonusRate = _originalBonusRate;
        busdContractAddress = ERC20(_busdContractAddress);
        conutContractAddress = ERC20(_conutContractAddress);

        // set owner
        _owner = _msgSender();
    }

    enum PaymentToken {
        BNB,
        BUSD,
        CONUT
    }

    struct NftItem {
        uint256 totalAmount;
        uint256 sellAmount;
        uint256 price;
        PaymentToken paymentToken;
        bool selling;
    }

    mapping(uint256 => mapping(address => NftItem)) public nftItem;
    mapping(uint256 => string) public tokenURIs;

    // list of nft owners
    mapping(uint256 => uint256) public lengthHolderList;
    mapping(uint256 => mapping(uint256 => address)) public holders;

    /*╔═════════════════════════════╗
      ║           EVENTS            ║
      ╚═════════════════════════════╝*/

    event MintToken(
        address indexed _creator,
        uint256 _tokenId,
        string _tokenURI,
        uint256 _amount
    );
    event Sell(
        address _seller,
        uint256 _tokenId,
        uint256 _sellAmount,
        uint256 _price,
        PaymentToken _paymentToken
    );
    event ReSell(
        address _seller,
        uint256 _tokenId,
        uint256 _sellAmount,
        uint256 _price,
        PaymentToken _paymentToken
    );
    event CancelSell(address _seller, uint256 _tokenId);
    event Buy(
        address _buyer,
        address _seller,
        uint256 _tokenId,
        uint256 _sellAmount,
        uint256 _price,
        PaymentToken _paymentToken
    );

    modifier onlyOwner() {
        require(msg.sender == _owner, "You aren't owner");
        _;
    }

    /*╔══════════════════════════════╗
      ║          FUNCTIONS           ║
      ╚══════════════════════════════╝*/

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function transferOwnerShip(address _newOwner) public {
        require(
            _newOwner != address(0),
            "New owner address is the zero address"
        );
        _owner = _newOwner;
    }

    function getBonusRate() public view onlyOwner returns (uint256) {
        return _bonusRate;
    }

    function setBonusRate(uint256 _newBonusRate) public onlyOwner {
        require(_newBonusRate > 0, "The bonus rate must be greater than 0");
        require(_newBonusRate < 1000, "The bonus rate must be less than 1000");
        require(
            _newBonusRate != _bonusRate,
            "The bonus rate will not be change"
        );
        _bonusRate = _newBonusRate;
    }

    function getPaymentAddress() public view onlyOwner returns (address) {
        return _paymentAddress;
    }

    function setPaymentAddress(address _newAddress) public onlyOwner {
        require(
            _newAddress != address(0),
            "New payment address is the zero address"
        );
        _paymentAddress = _newAddress;
    }

    function mint(uint256 _amount, string memory _tokenURI) public {
        require(_amount > 0, "The number of copies must be greater than 0");
        _tokenIds = _tokenIds.add(1);
        _mint(msg.sender, _tokenIds, _amount, "");
        tokenURIs[_tokenIds] = _tokenURI;

        // save the nft's properties to the map
        nftItem[_tokenIds][msg.sender] = NftItem(
            _amount,
            0,
            0,
            PaymentToken.BNB,
            false
        );

        // add creator to the owner lists
        holders[_tokenIds][0] = msg.sender;
        lengthHolderList[_tokenIds] = lengthHolderList[_tokenIds].add(1);

        emit MintToken(msg.sender, _tokenIds, _tokenURI, _amount);
    }

    function sell(
        uint256 _id,
        uint256 _sellAmount,
        uint256 _price,
        PaymentToken _paymentToken
    ) public {
        NftItem memory item = nftItem[_id][msg.sender];

        require(item.selling == false, "Item is on sale");
        require(
            _sellAmount > 0,
            "The number of copies for sale must be greater than 0 "
        );
        require(
            _sellAmount <= item.totalAmount,
            "The number of copies for sale must be less than or equal to the total number of copies available"
        );
        require(_price > 0, "The price must be greater than 0");
        require(
            _paymentToken == PaymentToken.BNB ||
                _paymentToken == PaymentToken.BUSD ||
                _paymentToken == PaymentToken.CONUT,
            "Payment token id must be 0 or 1 or 2"
        );

        nftItem[_id][msg.sender] = NftItem(
            item.totalAmount,
            _sellAmount,
            _price,
            _paymentToken,
            true
        );

        emit Sell(msg.sender, _id, _sellAmount, _price, _paymentToken);
    }

    function cancelSell(uint256 _id) public {
        NftItem memory item = nftItem[_id][msg.sender];

        require(item.selling == true, "Item has not been listed for sale");

        nftItem[_id][msg.sender] = NftItem(
            item.totalAmount,
            0,
            0,
            PaymentToken.BNB,
            false
        );

        emit CancelSell(msg.sender, _id);
    }

    function resell(
        uint256 _id,
        uint256 _sellAmount,
        uint256 _price,
        PaymentToken _paymentToken
    ) public {
        NftItem memory item = nftItem[_id][msg.sender];

        require(item.selling == true, "Item has not been listed for sale");
        require(
            _sellAmount > 0,
            "The number of copies for sale must be greater than 0 "
        );
        require(
            _sellAmount <= item.totalAmount,
            "The number of copies for sale must be less than or equal to the total number of copies available"
        );
        require(_price > 0, "The price must be greater than 0");
        require(
            _paymentToken == PaymentToken.BNB ||
                _paymentToken == PaymentToken.BUSD ||
                _paymentToken == PaymentToken.CONUT,
            "Payment token id must be 0 or 1 or 2"
        );

        nftItem[_id][msg.sender] = NftItem(
            item.totalAmount,
            _sellAmount,
            _price,
            _paymentToken,
            true
        );

        emit ReSell(msg.sender, _id, _sellAmount, _price, _paymentToken);
    }

    function buy(uint256 _id, address _seller) public payable {
        require(_seller != address(0), "Seller address is the zero address");

        NftItem memory item = nftItem[_id][_seller];

        require(item.selling == true, "The item is not for sale yet");
        require(msg.sender != _seller, "can't buy your own");

        // payment to seller
        if (item.paymentToken == PaymentToken.BNB) {
            require(
                msg.value >= item.sellAmount.mul(item.price),
                "Insufficient account balance"
            );

            payable(_seller).transfer(
                msg.value.mul(1000 - _bonusRate).div(1000)
            );
            payable(_paymentAddress).transfer(
                msg.value.mul(_bonusRate).div(1000)
            );
        } else if (item.paymentToken == PaymentToken.BUSD) {
            require(
                busdContractAddress.balanceOf(msg.sender) >=
                    item.sellAmount.mul(item.price),
                "Insufficient account balance"
            );

            busdContractAddress.transferFrom(
                msg.sender,
                _seller,
                item.sellAmount.mul(item.price).mul(1000 - _bonusRate).div(1000)
            );
            busdContractAddress.transferFrom(
                msg.sender,
                _paymentAddress,
                item.sellAmount.mul(item.price).mul(_bonusRate).div(1000)
            );
        } else {
            require(
                busdContractAddress.balanceOf(msg.sender) >=
                    item.sellAmount.mul(item.price),
                "Insufficient account balance"
            );

            conutContractAddress.transferFrom(
                msg.sender,
                _seller,
                item.sellAmount.mul(item.price).mul(1000 - _bonusRate).div(1000)
            );
            conutContractAddress.transferFrom(
                msg.sender,
                _paymentAddress,
                item.sellAmount.mul(item.price).mul(_bonusRate).div(1000)
            );
        }

        // delivering things to the rainy people
        _safeTransferFrom(_seller, msg.sender, _id, item.sellAmount, "");

        // change information on the map
        nftItem[_id][_seller] = NftItem(
            item.totalAmount.sub(item.sellAmount),
            0,
            0,
            PaymentToken.BNB,
            false
        );

        if (nftItem[_id][msg.sender].totalAmount != 0) {
            NftItem memory availableItem = nftItem[_id][msg.sender];
            nftItem[_id][msg.sender] = NftItem(
                item.sellAmount.add(availableItem.totalAmount),
                availableItem.sellAmount,
                availableItem.price,
                PaymentToken.BNB,
                availableItem.selling
            );
        } else {
            nftItem[_id][msg.sender] = NftItem(
                item.sellAmount,
                0,
                0,
                PaymentToken.BNB,
                false
            );
        }

        // add buyer to the holder lists
        holders[_id][lengthHolderList[_id]] = msg.sender;
        lengthHolderList[_id] = lengthHolderList[_id].add(1);

        emit Buy(
            msg.sender,
            _seller,
            _id,
            item.sellAmount,
            item.price,
            item.paymentToken
        );
    }
}
