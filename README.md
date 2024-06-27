# Example NFT Repo

This is an example NFT repo that uses Align Network to act as a whitelist for the NFT

### Deployments

| Name       | Address                                                                                                                                   | abi                      | network           | version |
| ---------- | ----------------------------------------------------------------------------------------------------------------------------------------- | ------------------------ | ----------------- | ------- |
| NFTA       | [0x17dA2156E659110A2FeeBE2849C8c192caAE7571](https://optimistic.etherscan.io/address/0x17dA2156E659110A2FeeBE2849C8c192caAE7571)          | [abi](/abi/nftaAbi.json) | Optimisim         | v1.0.0  |
| VerifyIPFS | [0xfA8af692dEa7713f0d8F266CfE91C919ABF66832](https://sepolia-optimistic.etherscan.io/address/0xfA8af692dEa7713f0d8F266CfE91C919ABF66832)( | [abi](/abi/nftaAbi.json) | Optimisim Sepolia | v1.0.0  |

### Usage:

1. Ensure you have an Align Id
2. Ensure your badge was created as an interactionType

```solidity

function checkInteractions() internal view {
        // get Align Id - will revert if no id
        uint256 alignId = alignIdContract.readId(msg.sender);
        // check to ensure the user has the Badge: Align Badge 1
        bool badgeMinted = interactionStation.getICIDNonFungible(issuerAlignId, alignId, badgeITypeKey);
        if (!badgeMinted) revert NoBadgeMinted();
    }

```
