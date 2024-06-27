# Example NFT Repo

This is an example NFT repo that uses Align Network to act as a whitelist for the NFT

```solidity

function checkInteractions() internal view {
        // get Align Id - will revert if no id
        uint256 alignId = alignIdContract.readId(msg.sender);
        // check to ensure the user has the Badge: Align Badge 1
        bool badgeMinted = interactionStation.getICIDNonFungible(issuerAlignId, alignId, badgeITypeKey);
        if (!badgeMinted) revert NoBadgeMinted();
    }

```
