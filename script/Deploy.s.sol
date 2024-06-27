// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { NFTA } from "../src/NFTA.sol";
import { Script } from "forge-std/src/Script.sol";
import { console2 } from "forge-std/src/console2.sol";
import { InteractionStation } from "align/src/InteractionStation.sol";
import { AlignIdRegistry } from "align/src/AlignIdRegistry.sol";

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract Deploy is Script {
    function run() public returns (NFTA nfta) {
        vm.startBroadcast();
        address treasury = vm.envOr({ name: "TREASURY", defaultValue: address(0) });
        address alignIdContract = vm.envOr({ name: "ALIGNID_CONTRACT", defaultValue: address(0) });
        address interactionStationAddress = vm.envOr({ name: "INTERACTIONSTATION_CONTRACT", defaultValue: address(0) });
        uint256 issuerAlignId = 3; // 3 for testnet, 5 for mainnet
        // Testnet: 0xf373c5b20c8ba9171752bcba5df2f0720fa3ea7ce9938ce8b5fd62288f0e3f61
        //bytes32 badgeITypeKey = 0xf373c5b20c8ba9171752bcba5df2f0720fa3ea7ce9938ce8b5fd62288f0e3f61; // testnet
        // Mainnet: 0x104fd5fa991e82dbef8bbab47e4596f1c5a14817f4c929ce36cfca0682080849
        bytes32 badgeITypeKey = 0x104fd5fa991e82dbef8bbab47e4596f1c5a14817f4c929ce36cfca0682080849; // mainnet
        nfta = new NFTA(
            "Align Founders",
            "AFNFT", // symbol
            "ipfs.align.network/ipfs/",
            treasury,
            alignIdContract,
            interactionStationAddress,
            issuerAlignId,
            badgeITypeKey
        );
        InteractionStation ints = InteractionStation(interactionStationAddress);
        // Pin metadata to IPFS
        ints.interact{ value: 0.0000029 ether }(
            issuerAlignId,
            0xa1b79868ca9899a72250bee77b0fae11fa916612624db2f9314a606857b486de, //NFT iTypeKey
            "bafyreifex4lhktrwqrjgds3f5zj4a4quwtgvdonj3acrvrrkd54qddtxky",
            0x0000000000000000000000000000000000000000000000000000000000000000
        );
        vm.stopBroadcast();
    }
}
