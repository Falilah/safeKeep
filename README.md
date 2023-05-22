# SAFEKEEP

# front-end link ==> [safekeep-Frontend](https://github.com/Falilah/safeKeep-frontend)

## Overview

SafeKeep is a web blockchain application that provides easy back-up and recovery of crypto assets. It also allows for legacy inheritor(s) to be assigned crypto assets kept in the Safekeep vault, in the case of unforeseen circumstances or even death.

## Objectives

1. To be a platform that guarantees safe recovery of crypto assets if access to your default wallet or device used in accessing your assets is lost .
2. Ensure safe and secure transfer of crypto assets to an assigned legacy inheritor in case of unforeseen accidents or death.
3. Serve as a back-up vault for user’s crypto assets
4. Acts as a smart contract wallet

## Scenarios

A Trader Who Lost Access To His Assets
Tunde is a crypto trader with more than five years trading experience under his belt. He got more than eight million in DogeCoin during Airdrop but he lost his mobile with the secret phrase stored in the phone and therefore was unable to access his crypto wallets.
Tunde has learnt his lesson and decided to find a safer way to back up his crypto assets to avoid another terrible loss.

```
tech stack
Solidity
diamond standard (EIP2535)
foundry

Nextjs
Connectkit
Wagmi
Mongodb

```

Safekeep utilizes the EIP2535 DiamondFactory contract, which has been deployed on the Sepolia network. Users are able to create their own vaults, which also adhere to the EIP2535 standard, by accessing this network. Here is the address where the Daimond factory contract was deployed: [0x0beb2aC4c8409D6211a5c90f842230277110114d](https://sepolia.etherscan.io/address/0x0beb2aC4c8409D6211a5c90f842230277110114d#code)
