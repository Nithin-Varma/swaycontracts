library;

pub enum CommemeEvent {
    CommemeCreated: (Identity, str, u256, str, str, u256),
    PoolCreated: (Identity, Identity, Identity),
    TokenDeployed: (Identity, str, str, u256),
    LiquidityAdded: (Identity, Identity, u256, u256),
    Donation: (bool, u256, u256, u256, Identity, Identity),
}