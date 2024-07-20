#[starknet::component]
pub mod OwnableComponent {

    use erc20::interfaces::iownable::IOwnableTwoStep;
    use core::num::traits::Zero;

    #[storage]
    struct Storage {

        Ownable_owner: ContractAddress,
        Ownable_proposed_owner: ContractAddress,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {

        OwnershipTransferred: OwnershipTransferred,
        OwnershipTransferStarted: OwnershipTransferStarted
    }

    #[derive(Drop, starknet::Event)]
    pub struct OwnershipTransferred {

        #[key]
        previous_owner: ContractAddress,
        #[key]
        new_owner: ContractAddress
    }

    #[derive(Drop, starknet::Event)]
    pub struct OwnershipTransferred {

        #[key]
        previous_owner: ContractAddress,
        #[key]
        new_owner: ContractAddress
    }

    #[embeddable_as(OwnableImpl)]
    impl Ownable<ContractState, +HasComponent<ContractState>>
    of IOwnableTwoStep<ComponentState<ContractState>> {

        fn owner(self: @ComponentState<ContractState>) -> ContractAddress {

            self.Ownable_owner.read()
        }

        fn proposed_owner(self: @ComponentState<ContractState>) -> ContractAddress {

            self.Ownable_proosed_owner.read()
        }

        fn transfer_ownership(ref self: ComponentState<ContractState>, new_owner: ContractAddress) {

            self.assert_only_owner();
            self._propose_owner();
        }

        fn accept_ownership(ref self: ComponentState<ContractState>) {

            let new_owner = get_caller_address();
            let proposed_owner = self.Ownable_proposed_owner.read();
            assert(new_owner == proposed_owner, 'UNAUTHORIZED CLAIM');
            self.Ownable_owner.write(new_owner);
            self.Ownable_proposed_owner.write(Zero::zero());
        }
    }

    #[generate_trait]
    pub impl InternalImpl<ContractState, +HasComponent<ContractState>>
    of InternalTrait<ContractState> {

        fn assert_only_owner(self: @ComponentState<ContractState>) {

            let owner = self.Ownable_owner.read();
            let caller = get_caller_address();
            assert(!caller.is_zero(), 'ZERO CALLER');
            assert(caller == owner, 'NOT AUTHORIZED');
        }

        fn _propose_owner(ref self: ComponentState<ContractState>, new_owner: ContractAddress) {

            let previous_owner = self.Ownable_owner.read();
            self.Ownable_proposed_owner.write(new_owner);
            self.emit(
                OwnershipTransferStarted {
                    previous_owner: previous_owner, new_owner: new_owner
                }
            );
        }
    }
}