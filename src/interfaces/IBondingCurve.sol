// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IBondingCurve {
    function getPrice(uint256 currentSupply, uint256 amount) external view returns (uint256);
    function getSellPrice(uint256 currentSupply, uint256 amount) external view returns (uint256);
}