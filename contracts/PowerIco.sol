// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.24;

import "./Power.sol";

contract PowerTokenIco {
    address payable owner;
    Power private powerToken;

    enum Phases {
        PreSale,
        SeedSale,
        FinalSale
    }

    enum Prices {
        PreSalePrice,
        SeedSalePrice,
        FinalSalePrice
    }
    uint256 public totalTokens;
    uint256 public tokenPrice;
    uint256 public tokenForSale;
    uint32 public icoPhase;

    Phases public phase;
    uint256 public constant TotalPresaleTokens = 30_000_000 * 10 ** 18;
    uint256 public seedSaleQuantity = 50_000_000 * 10 ** 18;
    uint256 public remainingTokens;
    mapping(Phases => uint256) phasePrices;
    mapping(address => mapping(address => uint256)) allowed;

    constructor(Power _powerToken) {
        owner = payable(msg.sender);
        powerToken = _powerToken;
        phasePrices[Phases.PreSale] = 12500000000000000;
        phasePrices[Phases.SeedSale] = 22500000000000000;
        phasePrices[Phases.FinalSale] = 32500000000000000;
        remainingTokens = TotalPresaleTokens;
        phase = Phases.PreSale; // Initialize phase to PreSale
    }

    function changePhase(Phases _phase) external {
        if (_phase == Phases.FinalSale) {
            revert("ico is in finalPhase");
        }
        phase = _phase;
    }

    // Setting Token according to ICO Phase
    function getPrice(Phases _icoPhase) external returns (uint256) {
        uint256 rate;

        uint16 ethPrice = 2870;
        if (_icoPhase == Phases.PreSale) {
            // for pre sale
            tokenPrice = 125;
            uint256 tokenInWei = 1 ether * tokenPrice;
            tokenForSale = 300000000 * (10 * 18);
            rate = tokenInWei / ethPrice / 1000;
        } else if (_icoPhase == Phases.SeedSale) {
            // for seed sale

            tokenPrice = 225;
            uint256 tokenInWei = 1 ether * tokenPrice;
            tokenForSale = totalTokens * tokenForSale;
            rate = tokenInWei / ethPrice / 1000;
        } else {
            tokenPrice = 400;
            uint256 tokenInWei = 1 ether * tokenPrice;
            tokenForSale = totalTokens - tokenForSale;
            rate = tokenInWei / ethPrice / 1000;
        }
        return rate;
    }

    function buyTokens() external payable {
        require(phase != Phases.FinalSale, "ICO is in the final phase.");
        uint256 price = phasePrices[phase];
        uint256 tokensToPurchase = (msg.value * 10 ** 18) / price; // Convert msg.value to wei
        require(
            tokensToPurchase <= remainingTokens,
            "Not enough tokens available for sale"
        );

        // Transfer tokens to the buyer
        powerToken.transferFrom(owner, msg.sender, tokensToPurchase);
        remainingTokens -= tokensToPurchase;
    }
}
