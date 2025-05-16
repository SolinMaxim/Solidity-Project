// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IBondingCurve.sol";

contract ExponentialBondingCurve is IBondingCurve {
    uint256 public constant BASE_PRICE = 0.01 ether;
    uint256 public constant PRICE_INCREMENT = 0.001 ether;
    uint256 public constant SCALE = 1e18;

    function getPrice(uint256 currentSupply, uint256 amount) external pure returns (uint256) {
        uint256 totalPrice;
        for (uint256 i = 0; i < amount; i++) {
            totalPrice += _calculatePrice(currentSupply + i);
        }
        return totalPrice;
    }

    function getSellPrice(uint256 currentSupply, uint256 amount) external pure returns (uint256) {
        uint256 totalPrice;
        for (uint256 i = 1; i <= amount; i++) {
            totalPrice += _calculatePrice(currentSupply - i);
        }
        return totalPrice * 90 / 100;
    }

    function _calculatePrice(uint256 supply) internal pure returns (uint256) {
        if (supply == 0) return BASE_PRICE;
        
        uint256 result = BASE_PRICE;
        for (uint256 i = 0; i < supply; i++) {
            result += (result * PRICE_INCREMENT) / SCALE;
        }
        return result;
    }
}