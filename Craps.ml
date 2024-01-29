let roll_dice () = (1 + Random.int 6, 1 + Random.int 6)

let print_state (point : int option) (rolls : int list) =
  match point with
  | None -> print_endline "Rolling for the first time."
  | Some p ->
      print_endline ("Point is " ^ string_of_int p);
      print_endline
        ("Rolls so far: " ^ String.concat ", " (List.map string_of_int rolls))

let rec play_craps (m : Money.account) : unit =
  print_state None [];
  print_string "Place your bet: ";
  print_endline ("Your balance is " ^ string_of_float (Money.get_balance m));
  let bet_amount = read_float () in
  let blc = Money.get_balance m in
  if bet_amount > blc then (
    print_endline "Not enough balance; all-in";
    place_bet m blc)
  else place_bet m bet_amount;
  let point, first_roll_sum = roll_dice () in
  print_state (Some point) [ first_roll_sum ];
  match first_roll_sum with
  | 7 | 11 ->
      let payout = int_of_float (1.5 *. bet_amount) in
      print_endline
        ("You rolled "
        ^ string_of_int first_roll_sum
        ^ ". Congratulations, you won " ^ string_of_int payout ^ "!");
      Money.process_transaction m (Deposit (float_of_int payout))
  | 2 | 3 | 12 ->
      print_endline
        ("You rolled " ^ string_of_int first_roll_sum ^ ". Sorry, you lost.")
  | _ -> (
      print_endline ("Your point is " ^ string_of_int point ^ ". Roll again!");
      let rec roll_until_point_or_7 (point : int) (rolls : int list) : unit =
        let die1, die2 = roll_dice () in
        let sum = die1 + die2 in
        print_state (Some point) (rolls @ [ sum ]);
        if sum = 7 then
          print_endline
            ("You rolled " ^ string_of_int sum ^ ". Sorry, you lost.")
        else if sum = point then (
          let payout = int_of_float (2.0 *. bet_amount) in
          print_endline
            ("You rolled " ^ string_of_int sum ^ ". Congratulations, you won "
           ^ string_of_int payout ^ "!");
          Money.process_transaction m (Deposit (float_of_int payout)))
        else (
          print_endline ("You rolled " ^ string_of_int sum ^ ". Roll again!");
          roll_until_point_or_7 point (rolls @ [ sum ]))
      in
      roll_until_point_or_7 point [ first_roll_sum ];
      print_endline ("Your balance is " ^ string_of_float (Money.get_balance m));
      print_endline "Play again? (y/n): ";
      match String.lowercase_ascii (read_line ()) with
      | "y" -> play_craps m
      | "n" -> ()
      | _ -> print_endline "Invalid input.")

and place_bet (m : Money.account) (amount : float) : unit =
  Money.process_transaction m (Withdrawal amount);
  print_endline ("You placed a bet of " ^ string_of_float amount ^ ".")
