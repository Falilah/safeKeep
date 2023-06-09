// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

/**
 * \
 * Author: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen)
 * EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
 *
 * Implementation of a diamond.
 * /*****************************************************************************
 */

import {LibFactoryDiamond} from "./libraries/LibFactoryDiamond.sol";
import {IDiamondCut} from "../interfaces/IDiamondCut.sol";

import "./libraries/LibAppStorage.sol";

contract VaultFactoryDiamond {
    constructor(address _contractOwner, address _diamondCutFacet) payable {
        LibFactoryDiamond.setContractOwner(_contractOwner);

        // Add the diamondCut external function from the diamondCutFacet
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);
        bytes4[] memory functionSelectors = new bytes4[](1);
        functionSelectors[0] = IDiamondCut.diamondCut.selector;
        cut[0] = IDiamondCut.FacetCut({
            facetAddress: _diamondCutFacet,
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: functionSelectors
        });
        LibFactoryDiamond.diamondCut(cut, address(0), "");
    }

    function setAddresses(address[] calldata _addresses) external {
        LibFactoryDiamond.enforceIsContractOwner();
        FactoryAppStorage storage s = LibAppStorage.factoryAppStorage();
        s.diamondCutFacet = _addresses[0];
        s.erc20Facet = _addresses[1];
        s.erc721Facet = _addresses[2];
        s.erc1155Facet = _addresses[3];
        s.diamondLoupeFacet = _addresses[4];
        s.vaultFacet = _addresses[5];
    }

    function setSelectors(bytes4[][] calldata _selectors) external {
        LibFactoryDiamond.enforceIsContractOwner();
        FactoryAppStorage storage fs = LibAppStorage.factoryAppStorage();
        assert(_selectors.length == 5);
        fs.ERC20SELECTORS = _selectors[0];
        fs.ERC721SELECTORS = _selectors[1];
        fs.ERC1155SELECTORS = _selectors[2];
        fs.DIAMONDLOUPEFACETSELECTORS = _selectors[3];
        fs.VAULTFACETSELECTORS = _selectors[4];
    }

    function owner() public view returns (address owner_) {
        LibFactoryDiamond.DiamondStorage storage ds = LibFactoryDiamond
            .diamondStorage();
        owner_ = ds.contractOwner;
    }

    // Find facet for function that is called and execute the
    // function if a facet is found and return any value.
    fallback() external payable {
        LibFactoryDiamond.DiamondStorage storage ds;
        bytes32 position = LibFactoryDiamond.DIAMOND_STORAGE_POSITION;
        // get diamond storage
        assembly {
            ds.slot := position
        }
        // get facet from function selector
        address facet = ds.selectorToFacetAndPosition[msg.sig].facetAddress;
        require(facet != address(0), "Diamond: Function does not exist");
        // Execute external function from facet using delegatecall and return any value.
        assembly {
            // copy function selector and any arguments
            calldatacopy(0, 0, calldatasize())
            // execute function call using the facet
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            // get any return value
            returndatacopy(0, 0, returndatasize())
            // return any return value or error back to the caller
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    receive() external payable {}
}
