// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import "forge-std/Script.sol";

interface IVaultSpawnerFacet {
    function createVault(
        address[] calldata _inheritors,
        uint256[] calldata _weiShare,
        uint256 _startingBal,
        address _backupAddress
    ) external payable returns (address addr);
}

contract CreateVaultScript is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address owner = vm.addr(deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);

        address vault1 = IVaultSpawnerFacet(
            0x3F79d8Fcb8F047fe4215c69D9d9Dc9Ed483558Eb
        ).createVault{value: 1 ether}(
            toSingletonAdd(0x162651d71aA9B5D97E9cb908139b38d4Ae433f2e),
            toSingletonUINT(10000),
            1e18,
            0x162651d71aA9B5D97E9cb908139b38d4Ae433f2e
        );
        vm.stopBroadcast();
    }
}

function toSingletonUINT(uint256 _no) pure returns (uint256[] memory) {
    uint256[] memory arr = new uint256[](1);
    arr[0] = _no;
    return arr;
}

function toSingletonAdd(address _no) pure returns (address[] memory) {
    address[] memory arr = new address[](1);
    arr[0] = _no;
    return arr;
}
