// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { NFTA } from "../src/NFTA.sol";
import { Script } from "forge-std/src/Script.sol";
import { console2 } from "forge-std/src/console2.sol";
import { InteractionStation } from "align/src/InteractionStation.sol";
import { AlignIdRegistry } from "align/src/AlignIdRegistry.sol";

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract Deploy is Script {
    function run() public {
        vm.startBroadcast();
        //NFTA nfta = NFTA(0xC3a127947E9581531f1717d46761dc39fE6c2687);
        //nfta.mint();
        address alignIdContract = vm.envOr({ name: "ALIGNID_CONTRACT", defaultValue: address(0) });
        address interactionStationAddress = vm.envOr({ name: "INTERACTIONSTATION_CONTRACT", defaultValue: address(0) });
        bytes32 badgeITypeKey = 0xf373c5b20c8ba9171752bcba5df2f0720fa3ea7ce9938ce8b5fd62288f0e3f61; // testnet
        InteractionStation interactionStation = InteractionStation(interactionStationAddress);
        AlignIdRegistry alignIdRegistry = AlignIdRegistry(alignIdContract);
        uint256 toAlignId = alignIdRegistry.readId(msg.sender);
        bool badgeMinted = interactionStation.getICIDNonFungible(3, toAlignId, badgeITypeKey);
        console2.log(badgeMinted);

        NFTA nfta = NFTA(0xC3a127947E9581531f1717d46761dc39fE6c2687);
        nfta.mint{ value: 0.01 ether }();
        vm.stopBroadcast();
    }
}
