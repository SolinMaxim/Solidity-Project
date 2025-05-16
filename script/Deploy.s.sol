// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/contracts/ExponentialBondingCurve.sol";
import "../src/contracts/NFTCollection.sol";
import "../src/contracts/BondingCurveNFTMarketplace.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";

contract DeployScript is Script {
    function run() external {
        address deployer = vm.envAddress("DEPLOYER_ADDRESS");
        vm.startBroadcast(deployer);
        
        ExponentialBondingCurve bondingCurve = new ExponentialBondingCurve();
        
        ProxyAdmin admin = new ProxyAdmin(deployer);
        
        NFTCollection nftCollection = new NFTCollection(
            "BondingNFT", 
            "BNFT",
            deployer
        );
        
        BondingCurveNFTMarketplace marketplaceImpl = new BondingCurveNFTMarketplace(
            address(bondingCurve),
            address(nftCollection)
        );
        
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(marketplaceImpl),
            address(admin),
            abi.encodeWithSelector(
                Ownable.transferOwnership.selector,
                deployer
            )
        );
        
        BondingCurveNFTMarketplace marketplace = BondingCurveNFTMarketplace(address(proxy));
        
        nftCollection.transferOwnership(address(marketplace));
        
        vm.stopBroadcast();
        
        console.log("BondingCurve deployed at:", address(bondingCurve));
        console.log("NFTCollection deployed at:", address(nftCollection));
        console.log("Marketplace deployed at:", address(marketplace));
        console.log("ProxyAdmin deployed at:", address(admin));
    }
}