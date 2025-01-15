use starknet::{ContractAddress, contract_address_const, get_contract_address};
use core::option::OptionTrait;
use core::traits::Into;
use core::array::ArrayTrait;
use core::result::ResultTrait;
use starknet::class_hash::ClassHash;
use starknet::syscalls::deploy_syscall;

use toksproject::toks::{Toks, IToksDispatcher, IToksDispatcherTrait};
use toksproject::types::{UserDetails, ContractInfo};

use starknet::testing::set_contract_address;

use snforge_std::{
    declare, ContractClassTrait, spy_events, SpyOn, EventSpy, EventAssertions, CheatSpan,
    cheat_caller_address, stop_cheat_caller_address, cheat_caller_address_global,
    stop_cheat_caller_address_global
};

// Helper function to get a constant contract address for testing
fn owner() -> ContractAddress {
    contract_address_const::<'owner'>()
}

// Deploy the contract and return its dispatcher.
fn deploy_contract(name: ByteArray) -> ContractAddress {
    let owner: ContractAddress = owner();
    let contract = declare(name).unwrap();

    let constructor_calldata = array![owner.into()];

    let (contract_address, _) = contract.deploy(@constructor_calldata).unwrap();
    contract_address
}

#[test]
fn test_constructor() {
    let contract_address = deploy_contract("Toks");
    let dispatcher = IToksDispatcher { contract_address: contract_address };

    //let user_address: ContractAddress = 0xbeef.try_into().unwrap();

    let owner: ContractAddress = dispatcher.get_owner();
    assert(owner == owner(), 'Invalid owner');
}

#[test]
fn test_deploy_token() {
    // Setup    
    let contract_address = deploy_contract("Toks");
    let dispatcher = IToksDispatcher { contract_address: contract_address };

   // let owner: ContractAddress = dispatcher.get_owner();
    let token_owner = contract_address_const::<2>();


    
    // Test token deployment
    let name: felt252 = 'TestToken';
    let symbol: felt252 = 'TST';
    let total_supply: u32 = 1000000;
    let decimals: u32 = 18;
    
    // Deploy token as owner
    //cheat_caller_address_global(token_owner);
    dispatcher.deploy_token(
        token_owner,
        name,
        symbol,
        total_supply,
        decimals
    );
    
    // Verify deployment
    let deployed_contracts = dispatcher.get_all_deployed_contract();
    assert(deployed_contracts.len() == 1, 'Wrong number of contracts');
    
    let user_contracts = dispatcher.get_all_deployed_contract_by_user(token_owner);
    assert(user_contracts.len() == 1, 'Wrong number of user contracts');
    
    // Check user details
    let user_details = dispatcher.get_user_details(token_owner);
    assert(user_details.addresses_len == 1, 'Wrong addresses length');
    assert(user_details.user_address == token_owner, 'Wrong user address');
}
