let print_wheel () : unit =
  print_endline
    "This is a visualization of Roulette table, where R, B stand for Red and \
     Black \n";
  print_endline "  | 3R 6B 9R 12R | 15B 18R 21R 24B | 27R 30R 33B 36R | 2to1";
  print_endline "0 | 2B 5R 8B 11B | 14R 17B 20B 23R | 26B 29B 32R 35B | 2to1";
  print_endline "  | 1R 4B 7R 10B | 13B 16R 19R 22B | 25R 28B 31B 34R | 2to1";
  print_endline "  |   1st 12     |     2nd 12      |      3rd 12     |";
  print_endline "  | 1-18 | EVEN  |  RED  |  BLACK  |  ODD  |  19-36  |"

let spin_wheel () : int =
  Random.self_init ();
  Random.int 37

let rec eval_single (win_num : int) (n : int) : int =
  print_endline "Single: please enter an int between 0 and 36.";
  match read_int_opt () with
  | Some num ->
      if num > 36 || num < 0 then (
        print_endline "Invalid single.";
        eval_single win_num n)
      else if num = win_num then 36 * n
      else 0
  | None ->
      print_endline "Invalid single.";
      eval_single win_num n

let rec eval_dbl_street (win_num : int) (n : int) : int =
  print_endline
    "Double street: please enter any 6 numbers from 2 adjacent rows using ~. \
     (i.e. 1~6)";
  let input = read_line () in
  match String.split_on_char '~' input with
  | [ row1; row2 ] -> (
      match (int_of_string_opt row1, int_of_string_opt row2) with
      | Some r1, Some r2 ->
          if r1 < 1 || r1 > 34 || r2 - r1 <> 5 || r1 mod 3 <> 1 then (
            print_endline "Invalid double street.";
            eval_dbl_street win_num n)
          else if win_num >= r1 && win_num <= r2 then 6 * n
          else 0
      | _ ->
          print_endline "Invalid double street.";
          eval_dbl_street win_num n)
  | _ ->
      print_endline "Invalid double street.";
      eval_dbl_street win_num n

let rec eval_corner (win_num : int) (n : int) : int =
  print_endline
    "Corner: please enter any 4 adjoining numbers ascendingly separated by \
     spaces. (i.e. 1 2 4 5)";
  let input =
    read_line () |> String.split_on_char ' ' |> List.map int_of_string
  in
  match input with
  | [ n1; n2; n3; n4 ] ->
      let nums = [| n1; n2; n3; n4 |] in
      if
        Array.exists (fun x -> x < 1 || x > 36) nums
        || n2 - n1 <> 1
        || n3 - n2 <> 2
        || n4 - n3 <> 1
      then (
        print_endline "Invalid corner.";
        eval_corner win_num n)
      else if Array.exists (fun x -> x = win_num) nums then 9 * n
      else 0
  | _ ->
      print_endline "Invalid corner.";
      eval_corner win_num n

let rec eval_street (win_num : int) (n : int) : int =
  print_endline
    "Street: please enter any 3 numbers on the same row ascendingly separated \
     by spaces. (i.e. 1 2 3)";
  let input =
    read_line () |> String.split_on_char ' ' |> List.map int_of_string
  in
  match input with
  | [ n1; n2; n3 ] ->
      let nums = [| n1; n2; n3 |] in
      if
        Array.exists (fun x -> x < 1 || x > 36) nums
        || n2 - n1 <> 1
        || n3 - n2 <> 1
        || n1 mod 3 <> 1
      then (
        print_endline "Invalid street.";
        eval_street win_num n)
      else if Array.exists (fun x -> x = win_num) nums then 12 * n
      else 0
  | _ ->
      print_endline "Invalid street.";
      eval_street win_num n

let rec eval_split (win_num : int) (n : int) : int =
  print_endline
    "Split: please enter any 2 adjoining numbers ascendingly separated by \
     spaces. (i.e. 2 3 or 5 8)";
  let input =
    read_line () |> String.split_on_char ' ' |> List.map int_of_string
  in
  match input with
  | [ n1; n2 ] ->
      let nums = [| n1; n2 |] in
      if
        Array.exists (fun x -> x < 1 || x > 36) nums
        || (n2 - n1 <> 3 && n2 - n1 <> 1)
      then (
        print_endline "Invalid split.";
        eval_split win_num n)
      else if Array.exists (fun x -> x = win_num) nums then 18 * n
      else 0
  | _ ->
      print_endline "Invalid split.";
      eval_split win_num n

let calculate_payout (bet_type : string) (n : int) (win_num : int) : int =
  match bet_type with
  | "single" -> eval_single win_num n
  | "even" -> if win_num mod 2 = 0 then 2 * n else 0
  | "odd" -> if win_num mod 2 <> 0 then 2 * n else 0
  | "red" -> (
      match win_num with
      | 3 | 9 | 12 | 18 | 21 | 27 | 30 | 36 | 5 | 14 | 23 | 32 | 1 | 7 | 16 | 19
      | 25 | 34 ->
          2 * n
      | _ -> 0)
  | "black" -> (
      match win_num with
      | 2 | 4 | 6 | 8 | 10 | 11 | 13 | 15 | 17 | 20 | 22 | 24 | 26 | 28 | 29
      | 31 | 33 | 35 ->
          2 * n
      | _ -> 0)
  | "1to18" -> if win_num <= 18 then 2 * n else 0
  | "19to36" -> if win_num > 18 then 2 * n else 0
  | "1st12" -> if win_num > 0 && win_num <= 12 then 3 * n else 0
  | "2nd12" -> if win_num >= 13 && win_num <= 24 then 3 * n else 0
  | "3rd12" -> if win_num >= 25 && win_num <= 36 then 3 * n else 0
  | "1stcol" -> if win_num mod 3 = 1 then 3 * n else 0
  | "2ndcol" -> if win_num mod 3 = 2 then 3 * n else 0
  | "3rdcol" -> if win_num mod 3 = 0 then 3 * n else 0
  | "doublestreet" -> eval_dbl_street win_num n
  | "corner" -> eval_corner win_num n
  | "street" -> eval_street win_num n
  | "split" -> eval_split win_num n
  | _ -> print_endline "Invalid bet type; bet is returned."; n

let rec play_roulette (m : Money.account) : unit =
  print_wheel ();
  print_endline
    "\n\
     Place your bets: enter one or more type below followed by amount to bet:\n\
    \     (even, odd, red, black, 1to18, 19to36,\n\
    \     1st12, 2nd12, 3rd12, 1stcol, 2ndcol, 3rdcol,\n\
    \     doublestreet, corner, street, split, single) ";
  print_endline
    "Examples: red 50 | odd 20, split 30 | red 10, even 30, even 50";
  print_endline ("Your balance is " ^ string_of_float (Money.get_balance m));
  let bets_str = read_line () in
  let bets_lst = String.split_on_char ',' bets_str in
  let bets =
    List.map
      (fun bet_str ->
        let bet_lst = String.split_on_char ' ' (String.trim bet_str) in
        match bet_lst with
        | [ bet_type; bet_amount_str ] ->
            let bet_amount = float_of_string bet_amount_str in
            (bet_type, bet_amount)
        | _ ->
            print_endline "Invalid input.";
            ("", 0.0))
      bets_lst
  in
  let total_bet_amount =
    List.fold_left (fun acc (_, bet_amount) -> acc +. bet_amount) 0.0 bets
  in
  let balance = Money.get_balance m in
  if total_bet_amount > balance then (
    print_endline "Not enough balance; all-in";
    List.iter (fun (bet_type, _) -> place_bet m balance bet_type) bets)
  else
    List.iter
      (fun (bet_type, bet_amount) -> place_bet m bet_amount bet_type)
      bets;
  let winning_number = spin_wheel () in
  let total_payout =
    List.fold_left
      (fun acc (bet_type, bet_amount) ->
        let payout =
          calculate_payout bet_type (int_of_float bet_amount) winning_number
        in
        if payout > 0 then
          Money.process_transaction m (Deposit (float_of_int payout));
        acc + payout)
      0 bets
  in
  print_endline ("\nThe winning number is: " ^ string_of_int winning_number);
  if total_payout > 0 then
    print_endline ("Congratulations, you won: " ^ string_of_int total_payout)
  else print_endline "Sorry, you lost.\n";
  print_endline "Play again? (y/n): ";
  match String.lowercase_ascii (read_line ()) with
  | "y" -> play_roulette m
  | "n" -> ()
  | _ -> print_endline "Invalid input."

and place_bet (m : Money.account) (amount : float) (bet_type : string) : unit =
  Money.process_transaction m (Withdrawal amount);
  print_endline
    ("You've placed " ^ string_of_float amount ^ " on " ^ bet_type ^ ".\n")
