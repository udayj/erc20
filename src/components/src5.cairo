#[starknet::component]
pub mod SRC5Component {

    use erc20::interfaces::isrc5::ISRC5;
    use erc20::interfaces::isrc5::ISRC5_ID;
    
    #[storage]
    struct Storage {
        SRC5_supported_interfaces: LegacyMap<felt252, bool>
    }

    pub mod Errors {
        pub const INVALID_ID:felt252 = 'SRC5: Invalid id';
    }

    #[embeddable_as(SRC5Impl)]
    pub impl SRC5<TContractState, +HasComponent<TContractState>>
        of ISRC5<ComponentState<TContractState>> {

        fn supports_interface(
            self: @ComponentState<TContractState>,
            interface_id: felt252
        ) -> bool {

            if interface_id == ISRC5_ID {
                return true;
            }

            self.SRC5_supported_interfaces.read(interface_id)
        }
    }

    #[generate_trait]
    pub impl InternalImpl<TContractState, +HasComponent<TContractState>>
    of InternalTrait<TContractState> {

        fn register_interface(ref self: ComponentState<TContractState>, interface_id: felt252) {
            self.SRC5_supported_interfaces.write(interface_id, true);
        }

        fn deregister_interface(ref self: ComponentState<TContractState>, interface_id: felt252) {
            assert(interface_id != ISRC5_ID, Errors::INVALID_ID);                
            self.SRC5_supported_interfaces.write(interface_id, false);
        }
    }
}