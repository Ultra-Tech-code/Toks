use starknet::ContractAddress;

#[derive(Copy, Drop, Serde, PartialEq, starknet::Store)]
pub struct UserDetails {
    pub user_address: ContractAddress,
    pub addresses_len: u32,
}

#[derive(Copy, Drop, Serde, PartialEq, starknet::Store)]
pub struct ContractInfo{
    pub contract_address: ContractAddress,
    pub deployment_time: u64,
    pub deployer: ContractAddress,
}


