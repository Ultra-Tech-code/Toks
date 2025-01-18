use starknet::ContractAddress;
use toksproject::types::{UserInfo};

#[starknet::interface]
pub trait IToks<TContractState> {
    //read function

    fn get_all_deployed_contract(self: @TContractState) -> Array<ContractAddress>;
    fn get_all_deployed_contract(self: @TContractState, user_address: ContractAddress) -> Array<ContractAddress>;
    fn get_a_contract_details(self: @TContractState, deployed_address: ContractAddress) ->
    fn get_user_details(self: @TContractState, user_address : ContractAddress) -> 
 

    //write function
    fn deposit_collateral(ref self: TContractState, token: ContractAddress, amount: u256);
    fn withdraw_collateral(ref self: TContractState, token: ContractAddress, amount: u256);
    fn create_request(
        ref self: TContractState,
        amount: u256,
        interest_rate: u16,
        return_date: u64,
        loan_token: ContractAddress
    ); 

    fn deploy_token(ref self: TContractState, owner: ContractAddress, token_name: felt252, token_symbol: felt252, total_supply: u256);


}


#[starknet::contract]
pub mod Toks {

    use core::option::OptionTrait;
    use core::traits::TryInto;
    use core::traits::Into;
    use core::starknet::event::EventEmitter;
    use core::num::traits::Zero;
    use super::ContractAddress;
    use starknet::{get_caller_address, get_contract_address, contract_address_const};

    use openzeppelin::access::ownable::OwnableComponent;
    use openzeppelin::access::ownable::ownable::OwnableComponent::InternalTrait;
    use openzeppelin::token::erc20::interface::{ERC20ABIDispatcher, ERC20ABIDispatcherTrait};

    use toksproject::types::{UserDetails};

    #[storage]
    struct Storage {
        total_deployed_contract: u64,
        total_users: u16,
        all_deployed_address: Map<u64, ContractAddress>,
        user_info: Map<ContractAddress, UserDetails>,

    }


       #[abi(embed_v0)]
    impl IToksImpl of super::IToks<ContractState> {
        //read
        fn 



        fn get_owner(self: @ContractState) -> ContractAddress {
            self.ownable.owner()
        }

  
        //write
        fn deploy_token(ref self: TContractState, owner: ContractAddress, token_name: felt252, token_symbol: felt252, total_supply: u256){


        }





        fn deploy_token(
            ref self: ContractState,
            owner: ContractAddress,
            token_name: felt252,
            token_symbol: felt252,
            total_supply: u256,
            decimals: u32,

        ) {
            let caller = get_caller_address();
            assert(!caller.is_zero(), 'INVALID_CALLER');
            
            // Deploy new token contract
            // You'll need to implement the actual token deployment logic here
            let token_address = contract_address_const::<0>(); // Placeholder
            
            // Update storage
            let current_count = self.total_deployed_contract.read();
            self.all_deployed_address.write(current_count, token_address);
            self.total_deployed_contract.write(current_count + 1);
            
            // Store contract info
            self.contract_info.write(
                token_address,
                ContractInfo {
                    contract_address: token_address,
                    deployment_time: get_block_timestamp(),
                    deployer: owner,
                }
            );

            // Update or create user details
            let user_count = self.user_token_count.read(owner);
            self.user_deployed_tokens.write((owner, user_count), token_address);
            self.user_token_count.write(owner, user_count + 1);
            
            // Update user info if not exists
            if self.user_info.read(owner).user_address.is_zero() {
                self.user_info.write(
                    owner,
                    UserDetails {
                        user_address: owner,
                        all_deployed_sddress: Map::<u32, ContractAddress>,
                        addresses_len: 0,
                    }
                );
            }
            
            self.emit(TokenDeployed { 
                owner: owner,
                token_address: token_address,
                token_name: token_name,
                token_symbol: token_symbol,
                total_supply: total_supply
            });
        }









    }







}