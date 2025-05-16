// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "../interfaces/IBondingCurve.sol";
import "../interfaces/INFTCollection.sol";

contract BondingCurveNFTMarketplace is Ownable {
    IBondingCurve public bondingCurve;
    INFTCollection public nftCollection;
    
    constructor(address _bondingCurve, address _nftCollection) Ownable(msg.sender) {
        bondingCurve = IBondingCurve(_bondingCurve);
        nftCollection = INFTCollection(_nftCollection);
    }

    function buyNFT(uint256 amount) external payable {
        uint256 currentSupply = nftCollection.totalSupply();
        uint256 totalPrice = bondingCurve.getPrice(currentSupply, amount);
        
        require(msg.value >= totalPrice, "Insufficient funds");
        
        for (uint256 i = 0; i < amount; i++) {
            nftCollection.mint(msg.sender);
        }
        
        if (msg.value > totalPrice) {
            payable(msg.sender).transfer(msg.value - totalPrice);
        }
    }

    function sellNFT(uint256 amount) external {
        uint256 currentSupply = nftCollection.totalSupply();
        require(amount <= currentSupply, "Not enough supply");
        
        uint256 totalPrice = bondingCurve.getSellPrice(currentSupply, amount);
        
        for (uint256 i = 0; i < amount; i++) {
            nftCollection.burn(currentSupply - i);
        }
        
        payable(msg.sender).transfer(totalPrice);
    }

    function getBuyPrice(uint256 amount) external view returns (uint256) {
        return bondingCurve.getPrice(nftCollection.totalSupply(), amount);
    }

    function getSellPrice(uint256 amount) external view returns (uint256) {
        return bondingCurve.getSellPrice(nftCollection.totalSupply(), amount);
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}