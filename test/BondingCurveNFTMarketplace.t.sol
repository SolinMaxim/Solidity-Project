// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/contracts/ExponentialBondingCurve.sol";
import "../src/contracts/NFTCollection.sol";
import "../src/contracts/BondingCurveNFTMarketplace.sol";

contract BondingCurveNFTMarketplaceTest is Test {
    ExponentialBondingCurve bondingCurve;
    NFTCollection nftCollection;
    BondingCurveNFTMarketplace marketplace;
    
    address user1 = address(1);
    address user2 = address(2);
    
    function setUp() public {
        bondingCurve = new ExponentialBondingCurve();
        nftCollection = new NFTCollection("TestNFT", "TNFT", address(this));
        marketplace = new BondingCurveNFTMarketplace(address(bondingCurve), address(nftCollection));
        
        nftCollection.transferOwnership(address(marketplace));
        
        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);
    }

    function testBuyNFT() public {
        vm.startPrank(user1);
        
        uint256 price = marketplace.getBuyPrice(1);
        marketplace.buyNFT{value: price}(1);
        
        assertEq(nftCollection.totalSupply(), 1);
        assertEq(nftCollection.ownerOf(1), user1);
        
        vm.stopPrank();
    }

    function testSellNFT() public {
        vm.startPrank(user1);
        
        uint256 buyPrice = marketplace.getBuyPrice(1);
        marketplace.buyNFT{value: buyPrice}(1);
        
        uint256 sellPrice = marketplace.getSellPrice(1);
        marketplace.sellNFT(1);
        
        assertEq(nftCollection.totalSupply(), 0);
        assertEq(user1.balance, 100 ether - buyPrice + sellPrice);
        
        vm.stopPrank();
    }

    function testPriceCalculation() public {
        uint256 price1 = marketplace.getBuyPrice(1);
        console.log("Price for 1 NFT:", price1);
        
        uint256 price5 = marketplace.getBuyPrice(5);
        console.log("Price for 5 NFTs:", price5);
        
        assertGt(price5, price1);
    }

    function testBuyMultipleNFTs() public {
        vm.startPrank(user1);
        
        uint256 price3 = marketplace.getBuyPrice(3);
        marketplace.buyNFT{value: price3}(3);
        
        assertEq(nftCollection.totalSupply(), 3);
        assertEq(nftCollection.ownerOf(1), user1);
        assertEq(nftCollection.ownerOf(2), user1);
        assertEq(nftCollection.ownerOf(3), user1);
        
        vm.stopPrank();
    }
}