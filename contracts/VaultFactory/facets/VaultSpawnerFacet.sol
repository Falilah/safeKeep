pragma solidity 0.8.18;

import "../../Vault/VaultDiamond.sol";
import "../libraries/LibAppStorage.sol";
import "../../Vault/libraries/LibKeep.sol";
import "../../interfaces/IVaultDiamond.sol";

import "../../interfaces/IDiamondCut.sol";
import "../../interfaces/IVaultFacet.sol";

contract VaultSpawnerFacet is StorageLayout {
    event VaultCreated(
        address indexed newVault,
        address owner,
        address indexed backup,
        uint256 indexed startingBalance,
        uint256 vaultID
    );

    error BackupAddressError();

    function createVault(
        address[] calldata _inheritors,
        uint256[] calldata _weiShare,
        uint256 _startingBal,
        address _backupAddress
    ) external payable returns (address addr) {
        if (_backupAddress == msg.sender) {
            revert BackupAddressError();
        }
        if (_startingBal > 0) {
            assert(_startingBal == msg.value);
        }
        assert(_inheritors.length == _weiShare.length);
        //spawn contract
        bytes memory code = type(VaultDiamond).creationCode;
        bytes32 entropy = keccak256(
            abi.encode(msg.sender, block.timestamp, fs.VAULTID)
        );
        assembly {
            addr := create2(0, add(code, 0x20), mload(code), entropy)
            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }
        //init diamond with diamondCut facet
        //insert a constant cut facet...modular and reusable across diamonds
        IVaultDiamond(addr).init(fs.diamondCutFacet, _backupAddress);
        //assert diamond owner
        //confirm for EOA auth in same call frame
        assert(IVaultDiamond(addr).tempOwner() == tx.origin);
        //deposit startingBal
        (bool success, ) = addr.call{value: _startingBal}("");
        assert(success);

        //proceed to upgrade new diamond with default facets
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](5);
        cut[0] = IDiamondCut.FacetCut({
            facetAddress: fs.erc20Facet,
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: fs.ERC20SELECTORS
        });
        cut[1] = IDiamondCut.FacetCut({
            facetAddress: fs.erc721Facet,
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: fs.ERC721SELECTORS
        });
        cut[2] = IDiamondCut.FacetCut({
            facetAddress: fs.erc1155Facet,
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: fs.ERC1155SELECTORS
        });
        cut[3] = IDiamondCut.FacetCut({
            facetAddress: fs.diamondLoupeFacet,
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: fs.DIAMONDLOUPEFACETSELECTORS
        });
        cut[4] = IDiamondCut.FacetCut({
            facetAddress: fs.vaultFacet,
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: fs.VAULTFACETSELECTORS
        });
        //upgrade
        IDiamondCut(addr).diamondCut(cut, address(0), "");
        //add inheritors if any

        if (_inheritors.length > 0) {
            IVaultFacet(addr).addInheritors(_inheritors, _weiShare);
        }

        emit VaultCreated(
            addr,
            msg.sender,
            _backupAddress,
            _startingBal,
            fs.VAULTID
        );
        fs.VAULTID++;
    }
}
