contract;

use std::storage::storage_vec::*;
use std::constants::ZERO_B256;
use std::storage::storage_string::*;
use std::string::*;
use std::{asset::transfer, call_frames::msg_asset_id, context::msg_amount, auth::msg_sender, hash::Hash};
use std::{storage::storage_string::*, string::String};



struct MemeDetails {
    name: str,
    symbol: str,
    total_supply: u256,
    token_address: Identity,
    owner: Identity,
}

abi Commeme{
    // #[storage(read, write)]
    fn constructor(_sender: Identity, _name: str, _symbol: str, _total_supply: u256, _legacy: Identity, _threshold: u256);
    // fn donators(amount:u256) -> Identity;
    // #[storage(read, write)]
    fn refund_if_not_active();
    // fn donators_amount(donator: Identity) -> u256;
    // fn total_donation_amount() -> u256;
    // fn is_donator(donator: Identity) -> bool;
    // fn is_active() -> bool;
    // fn time_to_close() -> u256;
    // fn threshold() -> u256;
    // fn legacy() -> Identity;
    // #[storage(read, write)]
    fn early_donations(_amount: u256);
}

storage {
    #[storage(read, write)]
    donators: StorageVec<Identity> = StorageVec {},
    #[storage(read, write)]
    donators_amount: StorageMap<Identity, u256> = StorageMap {},
    #[storage(read, write)]
    is_donator: StorageMap<Identity, bool> = StorageMap {},
    #[storage(read, write)]
    total_donation_amount: u256 = 0,
    #[storage(read, write)]
    is_active: bool = false,
    #[storage(read, write)]
    time_to_close: u256 = 0,
    #[storage(read, write)]
    threshold: u256 = 0,
    #[storage(read, write)]
    legacy: Identity = Identity::Address(Address::from(ZERO_B256)),
    #[storage(read, write)]
    commeme_constructor_called: bool = false,
    #[storage(read)]
    usdc_asset_id: b256 = b256::from_hex_str("0x8900c5bec4ca97d4febf9ceb4754a60d782abbf3cd815836c1872116f203f861");
}


impl Commeme for Contract {

    fn constructor(_sender: Identity, _name: str, _symbol: str, _total_supply: u256, _legacy: Identity,  _threshold: u256) {
        require(!storage.commeme_constructor_called.read(), "Constructor has called already");
        storage.legacy.write(_legacy);
        storage.time_to_close.write(std::block::timestamp().as_u256() + 1440);
        storage.threshold.write(_threshold);
        storage.is_active.write(true);
        storage.commeme_constructor_called.write(true);
    }

    fn refund_if_not_active() {
        require(!(storage.is_active.read()), "Commeme is active");
        let mut i = 0;
        while i < storage.donators.len() {
            let donator = storage.donators.get(i).unwrap().try_read().unwrap();
            let amount = storage.donators_amount.get(donator).try_read().unwrap();

            transfer(donator, AssetId::base(), amount);
            storage.is_donator.insert(donator, false);
            storage.donators_amount.insert(donator, 0);
            i += 1;
        }

        storage.donators.clear();
        storage.total_donation_amount.write(0);

    }

    fn early_donations(amount: u256) {
        require(storage.is_active.read(), "Commeme is not active");
        require(storage.total_donation_amount.read() < storage.threshold.read(), "Threshold has been reached");
        require(amount > 0, "Amount must be greater than 0");
        if(storage.total_donation_amount.read() < storage.threshold.read() && std::block::timestamp().as_u256() >= storage.time_to_close.read()) {
            refund_if_not_active();
            continue;
        }
        let donator = msg_sender().unwrap();
        let received_amount = msg_amount();

        if(!storage.is_donator.get(donator).read()) {
            storage.is_donator.insert(donator, true);
            storage.donators.insert(donator);
        }
        storage.donators_amount.insert(donator, amount);
        storage.total_donation_amount.write(storage.total_donation_amount.read() + amount);
        
    }



    // #[storage(read)]
    // fn donators_amount(donator: Identity) -> u256 {
    //     storage.donators_amount.get(donator).read();
    // }

    // #[storage(read)]
    // fn total_donation_amount() -> u256 {
    //     storage.total_donation_amount.read();
    // }

    // #[storage(read)]
    // fn is_donator(donator: Identity) -> bool {
    //     storage.is_donator.get(donator).read();
    // }

    // #[storage(read)]
    // fn is_active() -> bool {
    //     storage.is_active.read()
    // }

    // #[storage(read)]
    // fn time_to_close() -> u256 {
    //     storage.time_to_close.read()
    // }


    // #[storage(read)]
    // fn threshold() -> u256 {
    //     storage.threshold.read()
    // }

    // #[storage(read)]
    // fn legacy() -> Identity {
    //     storage.legacy.read()
    // }
}