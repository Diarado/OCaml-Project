open Money

type suit = Clubs | Diamonds | Hearts | Spades

type rank =
  | Ace
  | King
  | Queen
  | Jack
  | Ten
  | Nine
  | Eight
  | Seven
  | Six
  | Five
  | Four
  | Three
  | Two

type card = rank * suit
type hand = card list
type deck = card list

let string_of_suit (suit : suit) : string =
  match suit with
  | Clubs -> "Clubs"
  | Diamonds -> "Diamonds"
  | Hearts -> "Hearts"
  | Spades -> "Spades"

let string_of_card card =
  match fst card with
  | Ace -> "A"
  | King -> "K"
  | Queen -> "Q"
  | Jack -> "J"
  | Ten -> "10"
  | Nine -> "9"
  | Eight -> "8"
  | Seven -> "7"
  | Six -> "6"
  | Five -> "5"
  | Four -> "4"
  | Three -> "3"
  | Two -> "2"

let string_of_card_and_suit card =
  string_of_card card ^ " of " ^ string_of_suit (snd card)

let string_of_hand hand =
  List.map string_of_card_and_suit hand |> String.concat ", "

let make_deck () =
  let suits = [ Clubs; Diamonds; Hearts; Spades ] in
  let ranks =
    [
      Ace;
      King;
      Queen;
      Jack;
      Ten;
      Nine;
      Eight;
      Seven;
      Six;
      Five;
      Four;
      Three;
      Two;
    ]
  in
  (*52 cards in order*)
  let rec order acc suits ranks =
    match suits with
    | [] -> acc
    | h :: t ->
        let cards = List.map (fun r -> (r, h)) ranks in
        let acc' = cards @ acc in
        order acc' t ranks
  in
  order [] suits ranks

let shuffle_deck (deck : deck) : deck =
  let len = List.length deck in
  let rec aux acc n deck =
    if n <= 0 then acc
    else
      let i = Random.int n in
      let card = List.nth deck i in
      let deck' = List.filter (fun x -> x <> card) deck in
      aux (card :: acc) (n - 1) deck'
  in
  aux [] len deck

let rec deal_cards (num_cards : int) (deck : deck) (acc : card list) :
    deck * card list =
  match num_cards with
  | 0 -> (deck, List.rev acc)
  | n ->
      let card = List.hd deck in
      let remaining_deck = List.tl deck in
      deal_cards (n - 1) remaining_deck (card :: acc)

let score_card card =
  match card with
  | Ace -> 1
  | King -> 0
  | Queen -> 0
  | Jack -> 0
  | Ten -> 0
  | Nine -> 9
  | Eight -> 8
  | Seven -> 7
  | Six -> 6
  | Five -> 5
  | Four -> 4
  | Three -> 3
  | Two -> 2

let score_hand (h : hand) : int =
  let total =
    List.fold_left (fun acc card -> acc + score_card (fst card)) 0 h
  in
  if total >= 10 then total mod 10 else total

let compare_hands (p_hand : hand) (b_hand : hand) (deck : deck) :
    string * hand * hand =
  let p_score = ref (score_hand p_hand) in
  let b_score = ref (score_hand b_hand) in
  let p_hand' = ref p_hand in
  let b_hand' = ref b_hand in

  (* player draws first if he/she gets score of 0, 1, 2, 3, 4, 5 *)
  if !p_score >= 0 && !p_score <= 5 then (
    p_hand' := deal_cards 1 deck p_hand |> snd;
    p_score := score_hand !p_hand';
    let deck' = deal_cards 1 deck p_hand |> fst in
    let p_third_card = score_card (List.hd !p_hand' |> fst) in
    let banker_draw () : unit =
      b_hand' := deal_cards 1 deck' b_hand |> snd;
      b_score := score_hand !b_hand'
    in
    (* check if banker needs to draw *)
    (* if b_score = 0, 1, 2, draw one card*)
    match !b_score with
    | 0 | 1 | 2 -> banker_draw ()
    | 3 -> (
        (* if b_score = 3, if player's third card is 8, no need to draw else
           draw one card*)
        match p_third_card with 8 -> () | _ -> banker_draw ())
    | 4 -> (
        (* if b_score = 4, if player's third card is 0, 1, 8, 9, no need to
           draw else draw one card*)
        match p_third_card with 0 | 1 | 8 | 9 -> () | _ -> banker_draw ())
    | 5 -> (
        (* if b_score = 5, if player's third card is 0, 1, 2, 3, 8, 9, no need
           to draw else draw one card*)
        match p_third_card with
        | 0 | 1 | 2 | 3 | 8 | 9 -> ()
        | _ -> banker_draw ())
    | 6 -> (
        (* if b_score = 6, if player's third card is 6, 7, no need to draw else
           draw one card*)
        match p_third_card with 6 | 7 -> banker_draw () | _ -> ())
    | _ -> ())
  else if
    (* if player doesn't need to draw,
        banker draws if he/she gets score of 0, 1, 2, 3, 4, 5*)
    !b_score >= 0 && !b_score <= 5
  then (
    b_hand' := deal_cards 1 deck b_hand |> snd;
    b_score := score_hand !b_hand');

  (* determine the winner based on the final scores *)
  if !p_score > !b_score then ("Player wins!", !p_hand', !b_hand')
  else if !b_score > !p_score then ("Banker wins!", !p_hand', !b_hand')
  else ("Tie!", !p_hand', !b_hand')

let rec place_bet (m : Money.account) : string * float =
  print_endline
    ("Place your bet: (banker/player/tie)"
   ^ "\n payout ratio of banker = 1: 0.95" ^ "\n payout ratio of player = 1: 1"
   ^ "\n payout ratio of tie = 1: 8\n");
  let bet = read_line () |> String.lowercase_ascii in
  let place_bet_aux (bet_type : string) : string * float =
    print_endline "Enter your bet amount: ";
    print_endline ("Your balance is " ^ string_of_float (Money.get_balance m));
    match float_of_string_opt (read_line ()) with
    | None ->
        print_endline "Please enter an valid amount!";
        place_bet m
    | Some n ->
        let blc = Money.get_balance m in
        if n > blc then (
          print_endline "Not enough balance; all-in";
          Money.process_transaction m (Withdrawal blc);
          print_endline
            ("You've placed " ^ string_of_float blc ^ " on " ^ bet_type ^ ".\n");
          (bet_type, blc))
        else (
          Money.process_transaction m (Withdrawal n);
          print_endline
            ("You've placed " ^ string_of_float n ^ " on " ^ bet_type ^ ".\n");
          (bet_type, n))
  in
  match bet with
  | "banker" -> place_bet_aux "banker"
  | "player" -> place_bet_aux "player"
  | "tie" -> place_bet_aux "tie"
  | _ ->
      print_endline "Invalid input. Please enter 'banker', 'player', or 'tie'.";
      place_bet m

let rec play_baccarat (m : Money.account) : unit =
  Random.self_init ();
  let deck = make_deck () |> shuffle_deck in
  let p_1 = deal_cards 1 deck [] |> snd in
  let deck' = deal_cards 1 deck [] |> fst in
  let b_1 = deal_cards 1 deck' [] |> snd in
  let deck'' = deal_cards 1 deck' [] |> fst in
  let p_hand = deal_cards 1 deck'' p_1 |> snd in
  let deck''' = deal_cards 1 deck'' [] |> fst in
  let b_hand = deal_cards 1 deck''' b_1 |> snd in
  (* pass the deck with top 4 cards drawn to compare_hands *)
  let res = compare_hands p_hand b_hand (deal_cards 1 deck''' [] |> fst) in
  let new_p_hand = match res with _, ph, _ -> ph in
  let new_b_hand = match res with _, _, bh -> bh in
  let p_hand_str = string_of_hand new_p_hand in
  let banker_hand_str = string_of_hand new_b_hand in
  let p_score_str = new_p_hand |> score_hand |> string_of_int in
  let banker_score_str = new_b_hand |> score_hand |> string_of_int in
  let result_str =
    match res with
    | "Player wins!", _, _ -> (
        match place_bet m with
        | "player", n ->
            Money.process_transaction m (Deposit (n +. n));
            "Player wins! You won " ^ string_of_float (n +. n) ^ " ! 🎉"
        | _ -> "Player wins. ")
    | "Banker wins!", _, _ -> (
        match place_bet m with
        | "banker", n ->
            Money.process_transaction m (Deposit (n +. (0.95 *. n)));
            "Banker wins! You won "
            ^ string_of_float (n +. (0.95 *. n))
            ^ " ! 🎉"
        | _ -> "Banker wins. ")
    | "Tie!", _, _ -> (
        match place_bet m with
        | "tie", n ->
            Money.process_transaction m (Deposit (n +. (8.0 *. n)));
            "Tie! You won " ^ string_of_float (n +. (8.0 *. n)) ^ " ! 🎉"
        | _ -> "Tie. ")
    | _ -> "Something went wrong."
  in
  print_endline
    ("Player's hand: " ^ p_hand_str ^ "\n" ^ "Banker's hand: " ^ banker_hand_str
   ^ "\n" ^ "Player's score: " ^ p_score_str ^ "\n" ^ "Banker's score: "
   ^ banker_score_str ^ "\n" ^ "Result: " ^ result_str);
  print_endline "Play again? (y/n)";
  match read_line () with
  | "y" | "Y" -> play_baccarat m
  | "n" | "N" -> ()
  | _ -> print_endline "Invalid input."
