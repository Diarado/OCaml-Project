open Money

type suit = Clubs | Diamonds | Hearts | Spades

type rank =
  | Ace
  | One
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
type deck = card list
type hand = card list

let shuffle (deck : deck) : deck =
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

let create_deck () : deck =
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
  shuffle (order [] suits ranks)

let string_of_suit (suit : suit) : string =
  match suit with
  | Clubs -> "Clubs"
  | Diamonds -> "Diamonds"
  | Hearts -> "Hearts"
  | Spades -> "Spades"

let string_of_rank (rank : rank) : string =
  match rank with
  | Ace -> "A"
  | One -> "A"
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

(** Helper: the raw score that the hand has *)
let raw_score (hand : hand) : int =
  let get_rank (card : card) : int =
    match fst card with
    | Ace -> 11
    | King | Queen | Jack | Ten -> 10
    | Nine -> 9
    | Eight -> 8
    | Seven -> 7
    | Six -> 6
    | Five -> 5
    | Four -> 4
    | Three -> 3
    | Two -> 2
    | One -> 1
  in
  let hand_ranks = List.map (fun x -> get_rank x) hand in
  List.fold_left ( + ) 0 hand_ranks

let rec score (hand : hand) : int =
  let num_aces = List.length (List.filter (fun x -> fst x = Ace) hand) in
  if raw_score hand > 21 && num_aces > 0 then
    (* let the first A equal 1*)
    let rec map_first_ace f = function
      | [] -> []
      | (Ace, v) :: tl -> f (Ace, v) :: tl
      | hd :: tl -> hd :: map_first_ace f tl
    in
    map_first_ace (fun x -> if fst x = Ace then (One, snd x) else x) hand
    |> score
  else raw_score hand

let rec player_turn (deck : deck) (hand : hand) : hand * deck =
  print_endline "Your hand: ";
  List.iter
    (fun card ->
      print_endline
        (string_of_rank (fst card) ^ " of " ^ string_of_suit (snd card)))
    hand;
  let score = score hand in
  if score > 21 then (
    print_endline "\nYou bust!";
    ([], deck))
  else if score = 21 then (
    print_endline "\nYou win!";
    (hand, deck))
  else (
    print_endline "\nHit or stand? (hit or stand)";
    match read_line () with
    | "hit" ->
        let card = List.hd deck in
        print_endline
          ("\nYou drew "
          ^ string_of_rank (fst card)
          ^ " of "
          ^ string_of_suit (snd card));
        player_turn (List.tl deck) (card :: hand)
    | "stand" -> (hand, deck)
    | _ ->
        print_endline "Invalid input.";
        player_turn deck hand)

let rec dealer_turn (deck : deck) (hand : hand) : hand =
  print_endline "Dealer's hand: ";
  List.iter
    (fun card ->
      print_endline
        (string_of_rank (fst card) ^ " of " ^ string_of_suit (snd card)))
    hand;
  let score = score hand in
  if score > 21 then (
    print_endline "\nDealer busts!";
    [])
  else if score >= 17 then (
    print_endline "\nDealer stands.";
    hand)
  else
    let card = List.hd deck in
    print_endline "\nDealer hits.";
    print_endline
      ("\nDealer drew "
      ^ string_of_rank (fst card)
      ^ " of "
      ^ string_of_suit (snd card));
    dealer_turn (List.tl deck) (card :: hand)

let rec game_loop (deck : deck) (player_hand : hand) (dealer_hand : hand)
    (m : Money.account) (b : float) : unit =
  match player_turn deck player_hand with
  | x, y -> (
      let player_hand' = x in
      let deck = y in
      let dealer_hand' = dealer_turn deck dealer_hand in
      match (player_hand', dealer_hand') with
      | [], _ -> (
          print_endline "\nYou lose!";
          print_endline
            ("Your balance is " ^ string_of_float (Money.get_balance m));
          print_endline "Play again? (yes or no)";
          match read_line () with
          | "yes" ->
              let deck' =
                if List.length deck < 10 then create_deck () else deck
              in
              let b = Money.bet m in
              game_loop
                (deck |> List.tl |> List.tl)
                []
                [ List.hd deck'; List.nth deck' 1 ]
                m b
          | "no" -> ()
          | _ -> print_endline "Invalid input.")
      | _, [] -> (
          print_endline "\nYou win!";
          Money.process_transaction m (Deposit (b +. b));
          print_endline "Play again? (yes or no)";
          match read_line () with
          | "yes" ->
              let deck' =
                if List.length deck < 10 then create_deck () else deck
              in
              let b = Money.bet m in
              game_loop
                (deck |> List.tl |> List.tl)
                []
                [ List.hd deck'; List.nth deck' 1 ]
                m b
          | "no" -> ()
          | _ -> print_endline "Invalid input.")
      | _, _ -> (
          let player_score = score player_hand' in
          let dealer_score = score dealer_hand' in
          if player_score > dealer_score then (
            print_endline "You win!";
            Money.process_transaction m (Deposit (b +. b)))
          else if player_score < dealer_score then (
            print_endline "You lose!";
            print_endline
              ("Your balance is " ^ string_of_float (Money.get_balance m)))
          else print_endline "Tie!";
          print_endline ("Your score: " ^ string_of_int player_score);
          print_endline ("Dealer's score: " ^ string_of_int dealer_score);
          print_endline "Play again? (yes or no)";
          match read_line () with
          | "yes" ->
              let deck' =
                if List.length deck < 10 then create_deck () else deck
              in
              let b = Money.bet m in
              game_loop
                (deck |> List.tl |> List.tl)
                []
                [ List.hd deck'; List.nth deck' 1 ]
                m b
          | "no" -> ()
          | _ -> print_endline "Invalid input."))
