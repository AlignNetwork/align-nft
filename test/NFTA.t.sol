// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";
import "../src/NFTA.sol";
import "align/src/AlignIdRegistry.sol";
import "align/src/InteractionStation.sol";
import "align/src/VerifyIPFS.sol";

import { NFTA } from "../src/NFTA.sol";

contract NFTATest is Test {
    NFTA public nfta;
    AlignIdRegistry public alignIdRegistry;
    InteractionStation public interactionStation;
    VerifyIPFS public verifyIPFS;

    address public owner = address(1);
    address public treasury = address(2);
    address public user = address(3);

    uint256 public issuerAlignId = 1;
    uint256 public userAlignId = 2;
    // badge CID
    string private iTypeCID = "bafyreib62ecdcatiu7sqx2moo4727vmxes6rwjxbgd6vrugkrjzxkt43p4";
    string private name = "Align Badge 1";
    // nft storage
    string private iTypeCID2 = "bafyreihdaunebldfovtrp6iykh6seyw4hlcnbof6k54djr2gmvd35zvawe";
    string private name2 = "NFT";
    bytes32 private metadataKey;
    // badge CID interaction
    string private badgeCID = "bafyreib62ecdcatiu7sqx2moo4727vmxes6rwjxbgd6vrugkrjzxkt43p4";
    bytes32 private badgeKey;
    // NFT CID: bafyreifex4lhktrwqrjgds3f5zj4a4quwtgvdonj3acrvrrkd54qddtxky
    string private nftCID = "bafyreifex4lhktrwqrjgds3f5zj4a4quwtgvdonj3acrvrrkd54qddtxky";

    uint256 alignIdPrice = 0.00029 ether;
    uint256 interactionPrice = 0.0000029 ether;

    function setUp() public {
        alignIdRegistry = new AlignIdRegistry(alignIdPrice, treasury);
        verifyIPFS = new VerifyIPFS();
        interactionStation =
            new InteractionStation(address(alignIdRegistry), address(verifyIPFS), interactionPrice, treasury);

        // Register AlignId for user
        vm.deal(user, 1 ether);
        vm.deal(owner, 1 ether);
        vm.startPrank(owner);
        alignIdRegistry.register{ value: alignIdPrice }();
        // store metadata
        metadataKey = interactionStation.createIType(true, false, name2, iTypeCID2, new bytes32[](0));
        vm.stopPrank();
        vm.startPrank(user);
        alignIdRegistry.register{ value: alignIdPrice }();
        vm.stopPrank();

        vm.startPrank(owner);
        badgeKey = interactionStation.createIType(false, true, name, iTypeCID, new bytes32[](0));
        // give myself the badge
        //interactionStation.interact{ value: interactionPrice }(issuerAlignId, key, badgeCID, bytes32(0));

        nfta = new NFTA(
            "Test NFT",
            "TNFT",
            "https://example.com/",
            treasury,
            address(alignIdRegistry),
            address(interactionStation),
            issuerAlignId,
            badgeKey
        );
        // register metadata
        interactionStation.interact{ value: interactionPrice }(issuerAlignId, metadataKey, nftCID, bytes32(0));
        vm.deal(user, 1 ether);
        vm.stopPrank();
    }

    function testMint() public {
        // Set up Badge IType and interact with it

        vm.startPrank(user);
        vm.expectRevert(NFTA.MintPriceNotPaid.selector);
        nfta.mint{ value: 0.00005 ether }(); // Incorrect mint price
        vm.stopPrank();

        //vm.expectRevert(NFTA.NoBadgeMinted.selector);
        //nfta.mint{ value: nfta.MINT_PRICE() }(); // No badge interaction yet

        // Mint Badge
        vm.startPrank(owner);
        interactionStation.interact{ value: interactionPrice }(userAlignId, badgeKey, badgeCID, bytes32(0));
        vm.stopPrank();

        vm.startPrank(user);
        // Mint should succeed now
        nfta.mint{ value: nfta.MINT_PRICE() }();
        console2.log(nfta.ownerOf(0));
        assertEq(nfta.totalSupply(), 1);
        assertEq(nfta.ownerOf(0), user);
        console2.log(nfta.mintedCount(user));
        vm.stopPrank();

        uint256 treasuryBalanceBefore = treasury.balance;

        vm.prank(owner);
        nfta.withdraw();

        uint256 treasuryBalanceAfter = treasury.balance;
        assertEq(treasuryBalanceAfter, treasuryBalanceBefore + nfta.MINT_PRICE());
    }

    function testSetBaseURI() public {
        vm.startPrank(owner);
        console2.log(nfta.owner());
        nfta.setBaseURI("https://newexample.com/");
        assertEq(nfta.baseURI(), "https://newexample.com/");
        vm.stopPrank();
    }

    function testFailMintWhenMaxSupplyReached() public {
        for (uint256 i = 0; i < nfta.MAX_SUPPLY(); i++) {
            vm.prank(user);
            nfta.mint{ value: nfta.MINT_PRICE() }();
        }

        vm.prank(user);
        vm.expectRevert(NFTA.MaxSupply.selector);
        nfta.mint{ value: nfta.MINT_PRICE() }();
    }
}
