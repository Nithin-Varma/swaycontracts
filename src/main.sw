contract;

use std::storage::storage_vec::*;
use std::hash::Hash;
use std::constants::ZERO_B256;
use std::storage::storage_string::*;
use std::string::*;

struct MemeDetails {
    name: str,
    symbol: str,
    total_supply: u256,
    token_address: Identity,
    owner: Identity,
}

enum CommemeEvent {
    CommemeCreated: (Identity, str, u256, str, str, u256),
    PoolCreated: (Identity, Identity, Identity),
    TokenDeployed: (Identity, str, str, u256),
    LiquidityAdded: (Identity, Identity, u256, u256),
    Donation: (bool, u256, u256, u256, Identity, Identity),
}

abi Commeme {
    fn constructor(_sender: Identity, _name: str, _symbol: str, _total_supply: u256, _token_address: Identity, _threshold: u256);
    fn donators(amount:u256) -> Identity;
    fn donators_amount(donator: Identity) -> u256;
    fn total_donation_amount() -> u256;
    fn is_donator(donator: Identity) -> bool;
    fn is_active() -> bool;
    fn time_to_close() -> u256;
    fn threshold() -> u256;
    // fn pool_created() -> bool;
    fn legacy() -> Identity;
    fn early_donations(_sender: Identity, _amount: u256);
    fn receive();
}

storage {
    donators: StorageVec<Identity> = StorageVec {},
    donators_amount: StorageMap<Identity, u256> = StorageMap {},
    total_donation_amount: u256 = 0,
    is_active: bool = false,
    time_to_close: u256 = 0,
    threshold: u256 = 0,
    legacy: Identity = Identity::Address(Address::from(ZERO_B256)),
    price: u256 = 0,
    meme_details: MemeDetails = MemeDetails {
        name: '',
        symbol: '',
        total_supply: 0,
        token_address: Identity::Address(Address::from(ZERO_B256)),
        owner: Identity::Address(Address::from(ZERO_B256)),
    },
}

impl Commeme for Contract {

    fn constructor(_sender: Identity, _name: str, _symbol: str, _metadata: str, _total_supply: u256, _threshold: u256, _legacy: Identity, _price: u256) {
        require(!storage.commeme_constructor_called.read(), "Constructor has called already");
        storage.legacy.write(_legacy);
        storage.time_to_close.write(std::block::timestamp().as_u256() + 1440);
        storage.threshold.write(_threshold);
        storage.router.write(_router);
        storage.price.write(_price);
        storage.is_active.write(true);
        storage.commeme_constructor_called.write(true);
    }

    fn donators_amount(donator: Identity) -> u256 {
        storage.donators_amount.get(donator).read();
    }

    fn total_donation_amount() -> u256 {
        storage.total_donation_amount.read();
    }

    fn is_donator(donator: Identity) -> bool {
        storage.is_donator.get(donator).read();
    }

    fn is_active() -> bool {
        storage.is_active.read()
    }

    fn time_to_close() -> u256 {
        storage.time_to_close.read()
    }

    fn threshold() -> u256 {
        storage.threshold.read()
    }

    fn price() -> u256 {
        storage.price.read()
    }

    fn legacy() -> Identity {
        storage.legacy.read()
    }

    #[storage(read)]
    fn meme_details() -> MemeDetails {
        storage.meme_details.read()
    }
}
