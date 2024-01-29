(** Representation of Blackjack.

    This module implements a basic bank account that allows for deposit and 
    withdrawal transactions. It provides functions for creating a new account, 
    getting the current balance, and processing transactions. *)

(** A transaction type for deposits and withdrawals *)
type transaction = Deposit of float | Withdrawal of float

type account = { mutable balance : float }
(** An account record with a mutable balance field *)

val get_balance : account -> float
(** Returns the current balance of an account. *)

val create_account : unit -> account
(** Creates a new account with a zero balance. *)

val process_transaction : account -> transaction -> unit
(** This function processes a transaction on an account. If the transaction is a deposit, the amount is added to the account balance. If the transaction is a withdrawal, the amount is subtracted from the account balance if there are sufficient funds. If there are not sufficient funds, an error message is printed to the console. *)

val bet : account -> float
(**This function prompts the user to enter an amount to bet, reads the input, and attempts to convert it to a float. If the input is invalid or zero, it prints an error message and prompts the user again. If the input is a positive number, it processes a Withdrawal transaction on the provided account with the amount and returns it.*)

val fixed_bet : account -> float -> int -> float
(**This function takes in an account, a float representing the fixed amount to bet for each round, and an int representing the number of rounds to play. It prints out the bet amount, the number of rounds, and the current balance of the account. It then processes a Withdrawal transaction on the provided account with the product of x and n. The function returns the product of x and n.*)
