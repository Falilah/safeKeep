// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import "forge-std/Script.sol";
import "../contracts/Vault/facets/ERC1155Facet.sol";
import "../contracts/Vault/facets/ERC20Facet.sol";
import "../contracts/Vault/facets/ERC721Facet.sol";
import "../contracts/Vault/facets/DiamondCutFacet.sol";
import "../contracts/Vault/facets/DiamondLoupeFacet.sol";
import "../contracts/Vault/facets/VaultFacet.sol";
import "../contracts/VaultFactory/facets/VaultSpawnerFacet.sol";
import "../contracts/VaultFactory/facets/DiamondCutFactoryFacet.sol";
import "../contracts/VaultFactory/facets/DiamondLoupeFactoryFacet.sol";
import "../contracts/Vault/VaultDiamond.sol";
import "../contracts/VaultFactory/VaultFactoryDiamond.sol";

contract safeKeepScript is Script, IDiamondCut {
    //separate script to deploy all diamonds and expose them for interaction

    ERC1155Facet erc1155Facet;
    ERC721Facet erc721Facet;
    ERC20Facet erc20Facet;
    VaultSpawnerFacet spawner;
    VaultFacet vFacet;
    //VaultDiamond VDiamond;
    VaultFactoryDiamond vFactoryDiamond;
    DiamondCutFacet dCutFacet;
    DiamondLoupeFacet dLoupeFacet;

    DiamondCutFactoryFacet dCutFactoryFacet;
    DiamondLoupeFactoryFacet dloupeFactoryFacet;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address owner = vm.addr(deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);

        //deploy Vault facets
        erc1155Facet = new ERC1155Facet();
        erc721Facet = new ERC721Facet();
        erc20Facet = new ERC20Facet();
        vFacet = new VaultFacet();
        dCutFacet = new DiamondCutFacet();
        dLoupeFacet = new DiamondLoupeFacet();

        //deploy factory facets
        spawner = new VaultSpawnerFacet();
        dCutFactoryFacet = new DiamondCutFactoryFacet();
        dloupeFactoryFacet = new DiamondLoupeFactoryFacet();

        vFactoryDiamond = new VaultFactoryDiamond(
            owner,
            address(dCutFactoryFacet)
        );

        //upgrade factory diamond
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](2);
        cut[0] = IDiamondCut.FacetCut({
            facetAddress: address(spawner),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: generateSelectors("VaultSpawnerFacet")
        });
        cut[1] = IDiamondCut.FacetCut({
            facetAddress: address(dloupeFactoryFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: generateSelectors("DiamondLoupeFactoryFacet")
        });
        IDiamondCut(address(vFactoryDiamond)).diamondCut(cut, address(0), "");

        //add facet addresses and selectors to Appstorage
        address[] memory vaultFacetAddresses = new address[](6);
        vaultFacetAddresses[0] = address(dCutFacet);
        vaultFacetAddresses[1] = address(erc20Facet);
        vaultFacetAddresses[2] = address(erc721Facet);
        vaultFacetAddresses[3] = address(erc1155Facet);
        vaultFacetAddresses[4] = address(dLoupeFacet);
        vaultFacetAddresses[5] = address(vFacet);

        vFactoryDiamond.setAddresses(vaultFacetAddresses);

        //set selectors
        bytes4[][] memory _selectors = new bytes4[][](5);
        _selectors[0] = generateSelectors("ERC20Facet");
        _selectors[1] = generateSelectors("ERC721Facet");
        _selectors[2] = generateSelectors("ERC1155Facet");
        _selectors[3] = generateSelectors("DiamondLoupeFacet");
        _selectors[4] = generateSelectors("VaultFacet");
        vFactoryDiamond.setSelectors(_selectors);

        vm.stopBroadcast();
    }

    function generateSelectors(
        string memory _facetName
    ) internal returns (bytes4[] memory selectors) {
        string[] memory cmd = new string[](3);
        cmd[0] = "node";
        cmd[1] = "scripts/genSelectors.js";
        cmd[2] = _facetName;
        bytes memory res = vm.ffi(cmd);
        selectors = abi.decode(res, (bytes4[]));
    }

    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {}
}
