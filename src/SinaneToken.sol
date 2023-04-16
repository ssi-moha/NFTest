// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error MaxSupplyReached();

contract SinaneToken is ERC721, Ownable {
    using Counters for Counters.Counter;

    uint256 public constant MAX_SUPPLY = 300;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("SinaneToken", "SIN") {}

    function safeMint(address to) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();

        if (tokenId >= MAX_SUPPLY) revert MaxSupplyReached();

        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }
}
