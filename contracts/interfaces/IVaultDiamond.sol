pragma solidity 0.8.18;

interface IVaultDiamond {
    function init(address _diamondCutFacet, address _backupAddress) external;

    //via delegatecall on diamond
    function vaultOwner() external view returns (address);

    function tempOwner() external view returns (address owner_);
}
