use starknet::ContractAddress;
use toksproject::types::{UserDetails, ContractInfo};
use core::starknet::storage;

#[starknet::interface]
pub trait IToks<TContractState> {
    //read functions
    fn get_all_deployed_contract(self: @TContractState) -> Array<ContractAddress>;
    fn get_all_deployed_contract_by_user(self: @TContractState, user_address: ContractAddress) -> Array<ContractAddress>;
    fn get_a_contract_details(self: @TContractState, deployed_address: ContractAddress) -> ContractInfo;
    fn get_user_details(self: @TContractState, user_address: ContractAddress) -> UserDetails;
    fn get_owner(self: @TContractState) -> ContractAddress;

    //write functions
    fn deploy_token(
        ref self: TContractState, 
        owner: ContractAddress, 
        token_name: felt252, 
        token_symbol: felt252, 
        total_supply: u32,
        decimals: u32,
    );
}

#[starknet::contract]
pub mod Toks {
    use core::option::OptionTrait;
    use core::traits::TryInto;
    use core::traits::Into;
    use core::array::ArrayTrait;
    use core::starknet::event::EventEmitter;
    use core::num::traits::Zero;
    use super::ContractAddress;
    use starknet::{
        syscalls::deploy_syscall,
        ClassHash,
        get_caller_address, 
        get_contract_address, 
        contract_address_const, 
        get_block_timestamp
    };
    use core::starknet::storage;
    
    use toksproject::types::{UserDetails, ContractInfo};

    #[storage]
    struct Storage {
        owner: ContractAddress,
        total_deployed_contract: u64,
        total_users: u16,
        all_deployed_address: LegacyMap<u64, ContractAddress>,
        user_info: LegacyMap<ContractAddress, UserDetails>,
        contract_info: LegacyMap<ContractAddress, ContractInfo>,
        user_deployed_tokens: LegacyMap<(ContractAddress, u32), ContractAddress>, // Changed u64 to u32
        user_token_count: LegacyMap<ContractAddress, u32>, // Changed u64 to u32
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        TokenDeployed: TokenDeployed,
    }

    #[derive(Drop, starknet::Event)]
    struct TokenDeployed {
        #[key]
        owner: ContractAddress,
        #[key]
        token_address: ContractAddress,
        #[key]
        token_name: felt252,
        token_symbol: felt252,
        total_supply: u32,
    }   

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        self.owner.write(owner);
        self.total_deployed_contract.write(0);
        self.total_users.write(0);
    }

    #[generate_trait]
    impl InternalFunctions of InternalFunctionsTrait {
        fn _deploy_erc20(
            ref self: ContractState,
            owner: ContractAddress,
            token_name: felt252,
            token_symbol: felt252,
            total_supply: u32,
            decimals: u32,
        ) -> ContractAddress {
            let erc20_class_hash: ClassHash = 0x02c6bd298f6115dc4366cac75e26de68fd487c94bdfea523b7c9f296cf515a26.try_into().unwrap();
            
            let mut constructor_calldata = ArrayTrait::new();
            constructor_calldata.append(token_name);
            constructor_calldata.append(token_symbol);
            constructor_calldata.append(decimals.into());
            constructor_calldata.append(total_supply.into());
            constructor_calldata.append(owner.into());
            
            let (contract_address, _) = deploy_syscall(
                erc20_class_hash.try_into().unwrap(),
                0,
                constructor_calldata.span(),
                false
            ).unwrap();
            
            contract_address
        }

        fn _add_user_if_not_exists(ref self: ContractState, user: ContractAddress) {
            let existing_user = self.user_info.read(user);
            if existing_user.user_address.is_zero() {
                self.user_info.write(
                    user,
                    UserDetails { 
                        user_address: user,
                        addresses_len: 0,
                    }
                );
                self.total_users.write(self.total_users.read() + 1);
            }
        }
    }

    #[abi(embed_v0)]
    impl IToksImpl of super::IToks<ContractState> {
        fn get_all_deployed_contract(self: @ContractState) -> Array<ContractAddress> {
            let mut result: Array<ContractAddress> = ArrayTrait::new();
            let total = self.total_deployed_contract.read();
            let mut i: u64 = 0;
            
            loop {
                if i >= total {
                    break;
                }
                result.append(self.all_deployed_address.read(i));
                i += 1;
            };
            
            result
        }

        fn get_all_deployed_contract_by_user(
            self: @ContractState, 
            user_address: ContractAddress
        ) -> Array<ContractAddress> {
            let mut result: Array<ContractAddress> = ArrayTrait::new();
            let user_details = self.user_info.read(user_address);
            let mut i: u32 = 0;
            
            loop {
                if i >= user_details.addresses_len {
                    break;
                }
                result.append(self.user_deployed_tokens.read((user_address, i)));
                i += 1;
            };
            
            result
        }

        fn get_a_contract_details(
            self: @ContractState, 
            deployed_address: ContractAddress
        ) -> ContractInfo {
            self.contract_info.read(deployed_address)
        }

        fn get_user_details(
            self: @ContractState, 
            user_address: ContractAddress
        ) -> UserDetails {
            self.user_info.read(user_address)
        }

        fn get_owner(self: @ContractState) -> ContractAddress {
            self.owner.read()
        }

        fn deploy_token(
            ref self: ContractState,
            owner: ContractAddress,
            token_name: felt252,
            token_symbol: felt252,
            total_supply: u32,
            decimals: u32,
        ) {
            let caller = get_caller_address();
            assert(!caller.is_zero(), 'INVALID_CALLER');
            //assert(caller == self.owner.read(), 'CALLER_NOT_OWNER');
            
            // Deploy the token contract
            let token_address = self._deploy_erc20(
                owner,
                token_name,
                token_symbol,
                total_supply,
                decimals
            );
            
            // Add user if not exists
            self._add_user_if_not_exists(owner);
            
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

            // Update user's deployed tokens count and mapping
            let mut user_details = self.user_info.read(owner);
            let current_user_count = user_details.addresses_len;
            
            self.user_deployed_tokens.write((owner, current_user_count), token_address);
            user_details.addresses_len += 1;
            self.user_info.write(owner, user_details);
            
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