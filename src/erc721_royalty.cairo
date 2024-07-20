use starknet::ContractAddress;

#[starknet::interface]
pub trait IBookkeeping<TContractState> {

        fn get_sold(self: @TContractState, account: ContractAddress) -> u128;
        fn get_sold_on_behalf(self: @TContractState, account: ContractAddress) -> u128;
        fn get_purchased(self: @TContractState, account: ContractAddress) -> u128;
}

#[starknet::contract]
pub mod NFT {
    use openzeppelin::token::erc721::{ERC721Component, ERC721Component::ERC721HooksTrait};
    use openzeppelin::upgrades::UpgradeableComponent;
    use openzeppelin::upgrades::interface::IUpgradeable;
    use openzeppelin::introspection::src5::SRC5Component;
    use starknet::ContractAddress;
    use core::num::traits::Zero;

    component!(path: UpgradeableComponent, storage: upgradeable, event: UpgradeableEvent);
    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);

    #[abi(embed_v0)]
    impl ERC721Impl = ERC721Component::ERC721Impl<ContractState>;

    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;
    impl UpgradeableInternalImpl = UpgradeableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {

        num_sold: LegacyMap<ContractAddress, u128>,
        num_purchased: LegacyMap<ContractAddress, u128>,
        num_sold_on_behalf: LegacyMap<ContractAddress, u128>,
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        upgradeable: UpgradeableComponent::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC721Event: ERC721Component::Event,
        #[flat]
        UpgradeableEvent: UpgradeableComponent::Event,
        #[flat]
        SRC5Event: SRC5Component::Event
    }

    #[constructor]
    fn constructor (
        ref self: ContractState,
        name: ByteArray,
        symbol: ByteArray,
        base_uri: ByteArray,
        recipient: ContractAddress,
        token_ids: Span<u256>,
        owner: ContractAddress
    ) {

        self.erc721.initializer(name, symbol, base_uri);
        self.mint_assets(recipient, token_ids);
    }

    #[generate_trait]
    pub(crate) impl InternalImpl of InternalTrait {
        /// Mints `token_ids` to `recipient`.
        fn mint_assets(
            ref self: ContractState, recipient: ContractAddress, mut token_ids: Span<u256>
        ) {
            loop {
                if token_ids.len() == 0 {
                    break;
                }
                let id = *token_ids.pop_front().unwrap();
                self.erc721.mint(recipient, id);
            }
        }
    }

    pub impl ERC721HooksImpl of ERC721HooksTrait<ContractState> {
    fn before_update(
        ref self: ERC721Component::ComponentState<ContractState>,
        to: ContractAddress,
        token_id: u256,
        auth: ContractAddress
    ) {

        let mut contract_state = ERC721Component::HasComponent::get_contract_mut(ref self);
        if !auth.is_zero()  {
            
            let present_owner = self._owner_of(token_id);
            if (auth == present_owner) {
                
                contract_state.num_sold.write(auth, contract_state.num_sold.read(auth)+1);
            }
            else {
                contract_state.num_sold_on_behalf.write(auth, contract_state.num_sold_on_behalf.read(auth)+1);
            }

        }

        if !to.is_zero() {

            contract_state.num_purchased.write(to, contract_state.num_purchased.read(to)+1);
        }
    }

    fn after_update(
        ref self: ERC721Component::ComponentState<ContractState>,
        to: ContractAddress,
        token_id: u256,
        auth: ContractAddress
    ) {}
}

    #[abi(embed_v0)]
    impl BookkeepingImpl of super::IBookkeeping<ContractState> {

        fn get_sold(self: @ContractState, account: ContractAddress) -> u128 {

            self.num_sold.read(account)
        }

        fn get_sold_on_behalf(self: @ContractState, account: ContractAddress) -> u128 {

            self.num_sold_on_behalf.read(account)
        }

        fn get_purchased(self: @ContractState, account: ContractAddress) -> u128 {

            self.num_purchased.read(account)
        }

    }
}
