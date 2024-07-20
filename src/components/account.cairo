use starknet::account::Call;
#[starknet::component]
pub mod AccountComponent {

    use erc20::interfaces::isrc6::ISRC6;
    use erc20::components::src5::SRC5Component;

    #[storage]
    struct Storage {

        Account_public_key: felt252
    }

    pub mod Errors {

    }

    #[embeddable_as(SRC6Impl)]
    impl SRC6<
        TContractState, 
        +HasComponent<TContractState>,
        +SRC5Component::HasComponent<TcontractState>,
        +Drop<TContractState>
    > of ISRC6<ComponentState<TContractState>> {

        fn __execute__(self: @ComponentState<TcontractState>, mut calls: Array<Call>
        ) -> Array<Span<felt252>> {


        }
    }
}