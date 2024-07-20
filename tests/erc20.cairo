use core::array::ArrayTrait;
use starknet::{ContractAddress, contract_address_const, 
        testing::{set_contract_address, pop_log_raw},
};
use starknet::syscalls::{deploy_syscall, call_contract_syscall};

use erc20::erc20::ERC20;
use erc20::interfaces::ierc20::{IERC20Dispatcher, IERC20DispatcherTrait};
use erc20::interfaces::isrc5::{ISRC5Dispatcher, ISRC5DispatcherTrait};

fn deploy(
        contract_class_hash: felt252, salt: felt252, calldata: Array<felt252>
    ) -> ContractAddress {
        let (address, _) = deploy_syscall(
            contract_class_hash.try_into().unwrap(), salt, calldata.span(), false
        )
            .unwrap();
        address
}

fn setup() -> (ContractAddress, ContractAddress) {
        let decimals: u8 = 18_u8;
        let owner: ContractAddress = contract_address_const::<1>();

        // Deploy ERC20 contract
        let mut erc20_calldata = ArrayTrait::<felt252>::new();
        
        let erc20_address = deploy(ERC20::TEST_CLASS_HASH, 100, erc20_calldata);

        // Set owner as default caller
        set_contract_address(owner);

        return (erc20_address, owner);
}

#[test]
fn test_basic() {

    let (erc20_address, owner) = setup();
    let mut erc20 = ISRC5Dispatcher { contract_address: erc20_address };
    let mut calldata = ArrayTrait::<felt252>::new();
    'ABCDE'.serialize(ref calldata);
    call_contract_syscall(erc20_address, selector!("register_interface_id"), calldata.span()).unwrap();
    assert_eq!(erc20.supports_interface('ABCD'), false);
    assert_eq!(erc20.supports_interface('ABCDE'), true);
    assert_eq!(true, true);
}