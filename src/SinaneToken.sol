// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/utils/Counters.sol";

error MaxSupplyReached();
error PresaleMaxSupplyReached();
error PresaleClosed();
error PresaleMintLimitReached(address);
error InvalidAmount(address);

contract SinaneToken is ERC721, Ownable {
    using Counters for Counters.Counter;
    
    bool activePresale = false;
    uint256 timeFromPresaleDebut;
    
    uint256 public constant presalePrice = 0.003 ether;
    uint256 public constant salePrice = 0.005 ether;

    uint256 public constant MAX_SUPPLY = 300;
    uint256 public constant MAX_PRESALE_SUPPLY = 300;
    mapping(address => uint256) public mintCounter;

    Counters.Counter private _tokenIdCounter;
    Counters.Counter private _presaleCounter;

    constructor() ERC721("SinaneToken", "SIN") {}

    function setActivePresale () external onlyOwner {
        activePresale = true;
        timeFromPresaleDebut = block.timestamp;
    }

    function isPresaleExpired() public view returns (bool) {
        return block.timestamp - timeFromPresaleDebut > 1 days;
    }

    function presale() payable external {
        address to = msg.sender;
        if(!activePresale || isPresaleExpired()) revert PresaleClosed();
        if(msg.value != presalePrice) revert InvalidAmount(to);
        if(mintCounter[to] >= 2) revert PresaleMintLimitReached(to);
        if(_tokenIdCounter.current() == 100) revert PresaleMaxSupplyReached();

        _presaleCounter.increment();
        safeMint(to);
    }

    function safeMint(address to) internal {
        uint256 tokenId = _tokenIdCounter.current();

        if (tokenId >= MAX_SUPPLY) revert MaxSupplyReached();

        _tokenIdCounter.increment();
        mintCounter[to]++;
        _safeMint(to, tokenId);
    }
}
