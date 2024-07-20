use core::array::ArrayTrait;
use starknet::{ContractAddress, contract_address_const, 
        testing::{set_contract_address, pop_log_raw},
};
use starknet::syscalls::{deploy_syscall, call_contract_syscall};

use erc20::erc721_royalty::NFT;
use erc20::interfaces::ierc20::{IERC20Dispatcher, IERC20DispatcherTrait};
use erc20::interfaces::isrc5::{ISRC5Dispatcher, ISRC5DispatcherTrait};
use openzeppelin::token::erc721::interface::{IERC721Dispatcher, IERC721DispatcherTrait};
use erc20::erc721_royalty::{IBookkeepingDispatcher, IBookkeepingDispatcherTrait};

fn deploy(
        contract_class_hash: felt252, salt: felt252, calldata: Array<felt252>
    ) -> ContractAddress {
        let (address, _) = deploy_syscall(
            contract_class_hash.try_into().unwrap(), salt, calldata.span(), false
        )
            .unwrap();
        address
}

fn setup() -> (ContractAddress, ContractAddress, ContractAddress) {
        
        let owner: ContractAddress = contract_address_const::<1>();
        let initial_recipient = contract_address_const::<2>();
        let token_ids:Span<u256> = array![1.into(),2.into(),3.into(),4.into(),5.into()].span();
        // Deploy ERC20 contract
        let name:ByteArray = "NAME";
        let symbol:ByteArray = "SYMBOL";
        let base_uri: ByteArray = "BASE_URI";
        let mut nft_calldata = ArrayTrait::<felt252>::new();
        name.serialize(ref nft_calldata);
        symbol.serialize(ref nft_calldata);
        base_uri.serialize(ref nft_calldata);
        initial_recipient.serialize(ref nft_calldata);
        token_ids.serialize(ref nft_calldata);
        owner.serialize(ref nft_calldata);
        let nft_address = deploy(NFT::TEST_CLASS_HASH, 100, nft_calldata);

        // Set owner as default caller
        set_contract_address(owner);

        return (nft_address, owner, initial_recipient);
}

#[test]
fn test_nft_functionality() {

    let (nft_address, owner, initial_recipient) = setup();
    
    //let mut calldata = ArrayTrait::<felt252>::new();
    //'ABCDE'.serialize(ref calldata);
    //call_contract_syscall(nft_address, selector!("register_interface_id"), calldata.span()).unwrap();
    let nft = IERC721Dispatcher { contract_address: nft_address};
    let alice = contract_address_const::<3>();
    let nft_stats = IBookkeepingDispatcher {contract_address: nft_address};
    assert_eq!(nft.owner_of(1.into()),initial_recipient, "incorrect owner");
    assert_eq!(nft_stats.get_purchased(initial_recipient), 5);
    assert_eq!(nft_stats.get_purchased(alice),0);
    assert_eq!(nft_stats.get_sold(initial_recipient), 0);
    set_contract_address(initial_recipient);
    nft.transfer_from(initial_recipient, alice, 1.into());
    assert_eq!(nft.owner_of(1.into()),alice, "incorrect owner");
    assert_eq!(nft_stats.get_purchased(initial_recipient), 5);
    assert_eq!(nft_stats.get_purchased(alice),1);
    assert_eq!(nft_stats.get_sold(initial_recipient), 1);
    
}