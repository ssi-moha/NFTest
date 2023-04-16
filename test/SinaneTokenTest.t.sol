// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/SinaneToken.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";

contract SinaneTokenTest is Test, IERC721Receiver {
    SinaneToken token;
    address owner;

    receive() external payable {}

    fallback() external payable {}

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function setUp() public {
        token = new SinaneToken();
        owner = address(this);
    }

    function testReachMaxSupply() public {
        token.setActivePresale();
        vm.warp(block.timestamp + 1 days + 1 seconds);

        for (uint256 supply = 0; supply < 300; supply++) {
            token.sale{value: 0.005 ether}();
        }

        vm.expectRevert(MaxSupplyReached.selector);
        token.sale{value: 0.005 ether}();
    }

    function testPresaleReachMintLimit() public {
        token.setActivePresale();
        token.presale{value: 0.003 ether}();
        token.presale{value: 0.003 ether}();

        vm.expectRevert(
            abi.encodeWithSelector(
                PresaleMintLimitReached.selector,
                address(this)
            )
        );
        token.presale{value: 0.003 ether}();
    }

    function testPresaleInvalidAmount() public {
        token.setActivePresale();

        vm.expectRevert(
            abi.encodeWithSelector(InvalidAmount.selector, address(this))
        );
        token.presale{value: 0.001 ether}();
    }

    function testPresaleClosed() public {
        vm.expectRevert(PresaleClosed.selector);
        token.presale();
    }

    function testPresaleExpired() public {
        token.setActivePresale();
        vm.warp(block.timestamp + 1 days + 1 seconds);

        vm.expectRevert(PresaleClosed.selector);
        token.presale();
    }

    function testPresaleMaxSupplyReached() public {
        token.setActivePresale();

        for (uint256 supply = 0; supply < 100; supply++) {
            hoax(vm.addr(supply + 1));
            token.presale{value: 0.003 ether}();
        }

        vm.expectRevert(PresaleMaxSupplyReached.selector);
        token.presale{value: 0.003 ether}();
    }

    function testPresaleSuccess() public {
        token.setActivePresale();
        token.presale{value: 0.003 ether}();
        token.presale{value: 0.003 ether}();
    }

    function testSaleClosed() public {
        token.setActivePresale();

        vm.expectRevert(SaleClosed.selector);
        token.sale{value: 0.005 ether}();

        vm.warp(block.timestamp + 3 days + 1 seconds);
        vm.expectRevert(SaleClosed.selector);
        token.sale{value: 0.005 ether}();
    }

    function testSaleSuccess() public {
        token.setActivePresale();
        vm.warp(block.timestamp + 1 days + 1 seconds);

        token.sale{value: 0.005 ether}();
    }

    function testWithdraw() public {
        token.setActivePresale();
        token.presale{value: 0.003 ether}();
        token.presale{value: 0.003 ether}();
        hoax(owner);
        token.withdraw();
    }
}
