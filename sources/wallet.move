module wallet::wallet;

use std::type_name::{Self, TypeName};
use sui::bag::Bag;
use sui::balance::{Self, Balance};
use sui::vec_set::VecSet;

public struct Wallet has store {
    balance_types: VecSet<TypeName>,
    balances: Bag,
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
