// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";

error MaxSupplyReached();
error PresaleMaxSupplyReached();
error PresaleClosed();
error SaleClosed();
error PresaleMintLimitReached(address);
error InvalidAmount(address);

contract SinaneToken is ERC721Enumerable, Ownable, ReentrancyGuard {
    bool activePresale = false;
    uint256 timeFromPresaleDebut;

    uint256 public constant presalePrice = 0.003 ether;
    uint256 public constant salePrice = 0.005 ether;

    uint256 public constant PRESALE_DURATION = 1 days;
    uint256 public constant SALE_DURATION = 3 days;

    uint256 public constant MAX_SUPPLY = 300;
    uint256 public constant MAX_PRESALE_SUPPLY = 100;

    mapping(address => uint256) public mintCounter;

    constructor() ERC721("SinaneToken", "SIN") {}

    function setActivePresale() external onlyOwner {
        activePresale = true;
        timeFromPresaleDebut = block.timestamp;
    }

    function getSecondBetweenPresaleDebutAndNow()
        public
        view
        returns (uint256)
    {
        return block.timestamp - timeFromPresaleDebut;
    }

    function isPresaleExpired() public view returns (bool) {
        return getSecondBetweenPresaleDebutAndNow() > 1 days;
    }

    function isSaleOpen() public view returns (bool) {
        if (
            isPresaleExpired() && getSecondBetweenPresaleDebutAndNow() < 3 days
        ) {
            return true;
        }

        return false;
    }

    function presale() external payable nonReentrant {
        address to = msg.sender;

        if (!activePresale || isPresaleExpired()) revert PresaleClosed();
        if (msg.value != presalePrice) revert InvalidAmount(to);
        if (mintCounter[to] >= 2) revert PresaleMintLimitReached(to);
        if (totalSupply() == MAX_PRESALE_SUPPLY) revert PresaleMaxSupplyReached();

        safeMint(to);
    }

    function sale() external payable nonReentrant {
        address to = msg.sender;

        if (!isSaleOpen()) revert SaleClosed();
        if (msg.value != salePrice) revert InvalidAmount(to);

        safeMint(to);
    }

    function safeMint(address to) internal {
        uint256 tokenId = totalSupply();

        if (totalSupply() >= MAX_SUPPLY) revert MaxSupplyReached();

        mintCounter[to]++;
        _safeMint(to, tokenId);
    }

    function withdraw() external onlyOwner nonReentrant {
        payable(msg.sender).transfer(address(this).balance);
    }
}
