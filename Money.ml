type transaction = Deposit of float | Withdrawal of float
type account = { mutable balance : float }

let get_balance m = match m with { balance = i } -> i
let create_account () = { balance = 1000.0 }

let process_transaction (acc : account) (txn : transaction) =
  match txn with
  | Deposit amount ->
      acc.balance <- acc.balance +. amount;
      Printf.printf "Deposited %.2f. New balance: %.2f\n" amount acc.balance
  | Withdrawal amount ->
      if amount > acc.balance then
        Printf.printf "Insufficient funds. Current balance: %.2f\n" acc.balance
      else (
        acc.balance <- acc.balance -. amount;
        Printf.printf "Withdrew %.2f. New balance: %.2f\n" amount acc.balance)

let rec bet (m : account) =
  print_endline "How much to bet?";
  print_endline ("Your balance is " ^ string_of_float (get_balance m));
  match read_line () with
  | x ->
      let n =
        try float_of_string x
        with Failure _ ->
          print_endline "Invalid amount!";
          0.
      in
      if n > 0. then (
        process_transaction m (Withdrawal n);
        n)
      else bet m

let fixed_bet (m : account) (x : float) (n : int) =
  print_endline ("You will bet " ^ string_of_float x ^ " for each round");
  print_endline ("You will play " ^ string_of_int n ^ " rounds");
  print_endline ("Your balance is " ^ string_of_float (get_balance m));
  process_transaction m (Withdrawal (float_of_int n *. x));
  float_of_int n *. x
