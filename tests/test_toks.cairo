use starknet::{ContractAddress, contract_address_const, get_contract_address};

use toksproject::toks::{Toks, IToksDispatcher, IToksDispatcherTrait};
use toksproject::types::{UserDetails, ContractInfo};

use snforge_std::{
    declare, ContractClassTrait, DeclareResultTrait, start_cheat_caller_address,
    stop_cheat_caller_address
};


// Helper function to get a constant contract address for testing
fn owner() -> ContractAddress {
    contract_address_const::<'owner'>()
}

// Deploy the contract and return its dispatcher.
fn deploy_contract(name: ByteArray) -> ContractAddress {
    let owner: ContractAddress = owner();
    let contract = declare(name).unwrap().contract_class();

    let constructor_calldata = array![owner.into()];

    let (contract_address, _) = contract.deploy(@constructor_calldata).unwrap();
    contract_address
}

// #[test]
// #[fork("SEPOLIA_LATEST")]fn 
// test_constructor() {
//     let contract_address = deploy_contract("Toks");
//     let dispatcher = IToksDispatcher { contract_address: contract_address };

//     let owner: ContractAddress = dispatcher.get_owner();
//     assert(owner == owner(), 'Invalid owner');
// }

#[test]
#[fork("SEPOLIA_LATEST")]
fn test_deploy_token() {
    // Setup    
    // let contract_address = deploy_contract("Toks");
    let contract_address: felt252 = 0x035b2d9d3d92d1c6f7a6b0b5423412ec31abbc2c06f12295b04563f00e0eddd0;
    let token_owner:felt252 = 0x0179556e1b4ac08D85738E3AC1342b639A7f62ABEC1A71C92F75Fad44236711D;


    start_cheat_caller_address(contract_address.try_into().unwrap(), token_owner.try_into().unwrap());
    let dispatcher = IToksDispatcher { contract_address: contract_address.try_into().unwrap() };

   // let owner: ContractAddress = dispatcher.get_owner();

    // Test token deployment
    let name: felt252 = 'TestToken';
    let symbol: felt252 = 'TST';
    let total_supply: u256 = 1000000;
    let decimals: u8 = 18;
    
    // Deploy token as owner
    dispatcher.deploy_token(
        token_owner.try_into().unwrap(),
        name,
        symbol,
        total_supply,
        decimals
    );
    
    // Verify deployment
    let deployed_contracts = dispatcher.get_all_deployed_contract();
    assert(deployed_contracts.len() == 1, 'Wrong number of contracts');
    
    let user_contracts = dispatcher.get_all_deployed_contract_by_user(token_owner.try_into().unwrap());
    assert(user_contracts.len() == 1, 'Wrong number of user contracts');
    
    // Check user details
    let user_details = dispatcher.get_user_details(token_owner.try_into().unwrap());
    assert(user_details.addresses_len == 1, 'Wrong addresses length');
    assert(user_details.user_address == token_owner.try_into().unwrap(), 'Wrong user address');
}
