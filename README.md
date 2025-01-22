# Toks - Starknet Token Deployment Platform

A decentralized platform built on Starknet that enables users to deploy and manage ERC20 tokens with advanced features including pausability, ownership controls, and upgradability.

## Overview

Toks is a comprehensive token deployment solution that combines the power of OpenZeppelin components with Starknet's scalability. The platform allows users to:

- Deploy customizable ERC20 tokens
- Track all deployed tokens
- Manage token ownership and permissions
- View detailed contract and user information

## Features

### Token Functionality
- **ERC20 Standard Implementation**: Full ERC20 compatibility with additional features
- **Pausable Operations**: Ability to pause/unpause token transfers
- **Ownable Control**: Restricted access for sensitive operations
- **Upgradeable Design**: Support for contract upgrades
- **Burning Capability**: Token holders can burn their tokens
- **Minting Control**: Owner-restricted token minting

### Platform Capabilities
- **Token Deployment**: One-click token deployment with customizable parameters
- **Token Tracking**: Comprehensive tracking of all deployed tokens
- **User Management**: Detailed user profiles and deployment history
- **Contract Information**: Metadata storage for all deployed contracts

## Contract Architecture

### Main Components

1. **ERC20 Contract**
   - Implements core token functionality
   - Integrates OpenZeppelin components:
     - ERC20Component
     - PausableComponent
     - OwnableComponent
     - UpgradeableComponent

2. **Toks Platform Contract**
   - Manages token deployment
   - Tracks user and contract information
   - Handles platform-wide operations

## Technical Details

### Storage Structure

#### ERC20 Token Storage
```cairo
#[storage]
struct Storage {
    #[substorage(v0)]
    erc20: ERC20Component::Storage,
    #[substorage(v0)]
    pausable: PausableComponent::Storage,
    #[substorage(v0)]
    ownable: OwnableComponent::Storage,
    #[substorage(v0)]
    upgradeable: UpgradeableComponent::Storage,
}
```

#### Platform Storage
```cairo
#[storage]
struct Storage {
    owner: ContractAddress,
    total_deployed_contract: u64,
    total_users: u16,
    all_deployed_address: Map<u64, ContractAddress>,
    user_info: Map<ContractAddress, UserDetails>,
    contract_info: Map<ContractAddress, ContractInfo>,
    user_deployed_tokens: Map<ContractAddress, Map<u32, ContractAddress>>, 
    user_token_count: Map<ContractAddress, u32>, 
}
```

## Usage

### Deploying a New Token

To deploy a new token:

```cairo
fn deploy_token(
    ref self: TContractState, 
    owner: ContractAddress, 
    token_name: ByteArray, 
    token_symbol: ByteArray, 
    total_supply: u256,
);
```

### Querying Platform Information

Available query functions:
```cairo
fn get_all_deployed_contract(self: @TContractState) -> Array<ContractAddress>;
fn get_all_deployed_contract_by_user(self: @TContractState, user_address: ContractAddress) -> Array<ContractAddress>;
fn get_a_contract_details(self: @TContractState, deployed_address: ContractAddress) -> ContractInfo;
fn get_user_details(self: @TContractState, user_address: ContractAddress) -> UserDetails;
```

### Managing Token Operations

Token management functions:
```cairo
fn pause(ref self: ContractState);
fn unpause(ref self: ContractState);
fn burn(ref self: ContractState, value: u256);
fn mint(ref self: ContractState, recipient: ContractAddress, amount: u256);
```

## Events

The platform emits events for important operations:

```cairo
#[event]
struct TokenDeployed {
    #[key]
    owner: ContractAddress,
    #[key]
    token_address: ContractAddress,
    #[key]
    token_name: ByteArray,
    token_symbol: ByteArray,
    total_supply: u256,
}
```

## Security Considerations

- Owner-restricted operations for sensitive functions
- Pausable functionality for emergency situations
- Upgradeable architecture for future improvements
- Built on tested OpenZeppelin components

## Development

### Prerequisites
- Starknet development environment
- Cairo 2.8.4 or higher
- OpenZeppelin components




