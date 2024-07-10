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

        nfta = NFTA(0x17dA2156E659110A2FeeBE2849C8c192caAE7571);
        nfta.setBaseURI("https://ipfs.align.network/ipfs/bafyreidqleygnncsajzoilbci5ay47lbqldxzof6faxvz6kdmgxfckcixq/");
        vm.stopBroadcast();
    }
}
