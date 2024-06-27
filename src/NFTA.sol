// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "solmate/src/tokens/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "align/src/InteractionStation.sol";
import "align/src/AlignIdRegistry.sol";

contract NFTA is ERC721, Ownable {
    error MintPriceNotPaid();
    error MaxSupply();
    error NonExistentTokenURI();
    error WithdrawTransfer();
    error NoTreasurySet();
    error NoBadgeMinted();
    error NoMemeCreated();

    using Strings for uint256;

    string public baseURI;
    uint256 private _totalSupply;
    uint256 public constant MAX_SUPPLY = 3000;
    uint256 public constant MINT_PRICE = 0.01 ether;
    // Treasury
    address public treasury;
    uint256 public issuerAlignId;
    bytes32 public badgeITypeKey;

    AlignIdRegistry public alignIdContract;
    InteractionStation public interactionStation;

    mapping(address => uint256) private _mintedCount; // Mapping to track number of NFTs minted by an address

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI,
        address _treasury,
        address _alignIdContract,
        address _interactionStation,
        uint256 _issuerAlignId,
        bytes32 _badgeITypeKey
    )
        ERC721(_name, _symbol)
    {
        _initializeOwner(msg.sender);
        baseURI = _baseURI;
        treasury = _treasury;
        issuerAlignId = _issuerAlignId;
        badgeITypeKey = _badgeITypeKey;
        alignIdContract = AlignIdRegistry(_alignIdContract);
        interactionStation = InteractionStation(_interactionStation);
        // register an alignid if none provided
    }

    function checkInteractions() internal view {
        // get Align Id - will revert if no id
        uint256 alignId = alignIdContract.readId(msg.sender);
        // check to ensure the user has the Badge: Align Badge 1
        bool badgeMinted = interactionStation.getICIDNonFungible(issuerAlignId, alignId, badgeITypeKey);
        if (!badgeMinted) revert NoBadgeMinted();
    }

    function mint() external payable {
        if (msg.value != MINT_PRICE) {
            revert MintPriceNotPaid();
        }
        if (_totalSupply > MAX_SUPPLY) {
            revert MaxSupply();
        }
        // check to Align Id Interactions
        checkInteractions();

        _safeMint(msg.sender, _totalSupply);
        _totalSupply++;
        _mintedCount[msg.sender]++; // Increment the minted count for this address
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) {
            revert NonExistentTokenURI();
        }
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI)) : "";
    }

    function setBaseURI(string memory newBaseURI) external onlyOwner {
        baseURI = newBaseURI;
    }

    /// @notice Allows the owner to withdraw collected fees
    function withdraw() public onlyOwner {
        if (treasury == address(0)) {
            revert NoTreasurySet();
        }
        uint256 balance = address(this).balance;
        (bool success,) = payable(treasury).call{ value: balance }("");
        if (!success) revert WithdrawTransfer();
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return ownerOf(tokenId) != address(0);
    }

    /// @notice Check how many NFTs an address has minted
    function mintedCount(address account) external view returns (uint256) {
        return _mintedCount[account];
    }
}
