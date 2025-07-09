module wallet::wallet;

use std::type_name::{Self, TypeName};
use sui::bag::{Self, Bag};
use sui::balance::{Self, Balance};
use sui::vec_set::{Self, VecSet};

public struct Wallet has store {
    balance_types: VecSet<TypeName>,
    balances: Bag,
}

public fun new(ctx: &mut TxContext): Wallet {
    Wallet {
        balance_types: vec_set::empty(),
        balances: bag::new(ctx),
    }
}

public fun destroy(self: Wallet) {
    let Wallet { balances, .. } = self;
    balances.destroy_empty();
}

public fun deposit<Currency>(self: &mut Wallet, balance: Balance<Currency>) {
    self.internal_deposit(balance);
}

public fun safe_deposit<Currency>(self: &mut Wallet, balance: Balance<Currency>) {
    if (!self.balance_types.contains(&type_name::get<Currency>())) {
        self.internal_initialize_balance<Currency>();
    };
    self.internal_deposit(balance);
}

public fun withdraw<Currency>(self: &mut Wallet, amount: u64): Balance<Currency> {
    let balance_type = type_name::get<Balance<Currency>>();
    let existing_balance = self.balances.borrow_mut<TypeName, Balance<Currency>>(balance_type);
    existing_balance.split(amount)
}

fun internal_deposit<Currency>(self: &mut Wallet, balance: Balance<Currency>) {
    let balance_type = type_name::get<Balance<Currency>>();
    let existing_balance = self.balances.borrow_mut<TypeName, Balance<Currency>>(balance_type);
    existing_balance.join(balance);
}

fun internal_initialize_balance<Currency>(self: &mut Wallet) {
    let balance_type = type_name::get<Balance<Currency>>();
    self.balance_types.insert(balance_type);
    self.balances.add<TypeName, Balance<Currency>>(balance_type, balance::zero());
}
