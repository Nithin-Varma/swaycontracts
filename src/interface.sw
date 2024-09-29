library;

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
    fn early_donations(_sender: Identity, _amount: u256);
}