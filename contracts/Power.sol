// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Power is ERC20 {
    address public owner;

    constructor() ERC20("Power", "Pwr") {
        owner = msg.sender;
    }

    function mint() external onlyOwner {
        _mint(msg.sender, 100000000000000000000 * (10 ** 18));
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can call this function");
        _;
    }
}
