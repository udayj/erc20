use starknet::ContractAddress;
#[starknet::interface]
pub trait IOwnableTwoStep<TContractState> {

    fn owner(self: @TContractState) -> ContractAddress;
    fn proposed_owner(self: @TContractState) -> ContractAddress;
    fn accept_ownership(ref self: TContractState);
    fn transfer_ownership(ref self: TContractState, new_owner: ContractAddress);
}