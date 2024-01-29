(** Representation of Baccarat.

    This module represents an implementation of the card game Baccarat. 
    It defines necessary types for representing cards, decks, and hands, and
    functions for shuffling a deck, creating a new deck, calculating the score 
    of a hand, and simulating a player and banker turn. *)

(**********************************************************************
 **********************************************************************)

(** The type [suit] represents the suits (clubs, diamonds, hearts, spades) 
    of cards. *)
type suit = Clubs | Diamonds | Hearts | Spades

(** The type [rank] represnts the 13 cards of each suit (without jokers). *)
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
(** The type [card] is represented by a tuple of rank and suit. Example :
    (Ace, Clubs) *)

type hand = card list
(** The type [hand] showing the hand of either player or banker is represented 
    by a card list. *)

type deck = card list
(** The type [deck] is represented by a card list. *)

val string_of_suit : suit -> string
(** [string_of_suit s] is the string representation of [s]. Examples:

    - [string_of_suit Clubs] is "Clubs"

    Requires: [s] is a valid suit. *)

val string_of_card : rank * 'a -> string
(** [string_of_rank c] is the string representation of [c]'s rank. Examples:

    - [string_of_rank (Ace, Spades)] is "A"
    - [string_of_rank (Seven, Clubs)] is "7" 

    Requires: [c] is a valid card. *)

val string_of_card_and_suit : rank * suit -> string
(** [string_of_card_and_suit c] is the string representation of [c]. Examples:

    - [string_of_card_and_suit (Ace, Spades)] is "A of Spades"
    - [string_of_card_and_suit (Seven, Clubs)] is "7 of Clubs" 

    Requires: [c] is a valid card. *)

val string_of_hand : (rank * suit) list -> string
(** [string_of_hand h] is the string representation of [h]. Examples:

    - [string_of_hand [(Ace, Spades); (Seven, Clubs)]] is 
    "A of Spades, 7 of Clubs"

    Requires: [h] is a valid hand. *)

val make_deck : unit -> (rank * suit) list
(** [make_deck ()] is a unshuffled deck of 52 cards.*)

val shuffle_deck : deck -> deck
(** [shuffle_deck d] shuffles the deck [d]. 
    Requires: [d] is a valid deck. *)

val deal_cards : int -> deck -> card list -> deck * card list
(** [deal_cards n d h] deals [n] cards from the top of the deck [d] to the hand 
    [h], and returns a tuple of the remaining deck and updated hand. 
    Requires: [n] is a positive integer less or equal to 52, [d] is a valid 
    deck, and [h] is a valid hand. *)

val score_card : rank -> int
(** [score_card c] is the score value of [c]. Jack, Queen, King are worth 0 
    points. Ace is worth 1 point. Cards 2 through 9 are worth their face value. 
    Requires: [c] is a valid card. *)

val score_hand : hand -> int
(** [score_hand h] is the total score of the hand [h]. If the total score is 
    greater than or equal to 10, only the right digit is used as the score. 
    Examples:

    - [score_hand [(Ace, Spades); (Two, Clubs)]] is 3
    - [score_hand [(Ace, Spades); (Nine, Diamonds)]] is 0
    - [score_hand [(Six, Hearts); (Eight, Spades)]] is 4

    Requires: [h] is a valid hand. *)

val compare_hands : hand -> hand -> deck -> string * hand * hand
(** [compare_hands h1 h2 d] draws the third card for player or banker if needed 
    based on the rule specified below and compares player's hand [h1] and 
    banker's hand [h2] based on scores of hands, and returns a triple of strings
    representing the outcome of the comparison, updated player's hand and 
    banker's hand.
    
    Rules of drawing the third card:
    For player: 
    - player draws first if his/her score of hand is 0, 1, 2, 3, 4, 5,
      else doesn't
    For banker:
    - if player doesn't draw, banker draws based on the same rule above
    - if player draws
      - banker draws if his/her score of hand is 0, 1, 2
      - if banker's score of hand is 3 and player's third card is 8, doesn't 
        draw, else does
      - if banker's score of hand is 4 and player's third card is 0, 1, 8, 9, 
        doesn't draw, else does 
      - if banker's score of hand is 5 and player's third card is 0, 1, 2, 3, 8,
        9, doesn't draw, else does
      - if banker's score of hand is 6 and player's third card is 6, 7, draws, 
        else doesn't 
      - else doesn't draw

    Returns:
    - [("Player wins!", h1', h2')] if [h1] has a higher score than [h2]
    - [("Banker wins!", h1', h2')] if [h2] has a higher score than [h1]
    - [("Tie!", h1', h2')] if [h1] and [h2] have the same score

    Requires: 
    - [h1] and [h2] are valid hands
    - [d] is a shuffled deck
*)

val place_bet : Money.account -> string * float
(** [place_bet account] prompts the player to enter a bet amount. The function 
    returns a tuple of a string representing the bet type (banker, player, tie) 
    and the amount of the bet. If the bet amount is valid, i.e. a positive float
    not exceeding the balance of the account [m], it updates the balance.
    If the bet amount is invalid, the function asks the user to re-enter the bet 
    amount. If the bet type is invalid, i.e. not 'banker', 'player', or 'tie', 
    it asks the user to re-enter the bet type.

    Raises:
    [Failure "float_of_string"] if user input is not a valid float.

    Requires: [account] is a valid Money.account
*)

val play_baccarat : Money.account -> unit
(** [play_baccarat account] is the main function that handles the 
    gameplay for baccarat. The function prompts the player to place a bet,
    and then deals the initial hands to the player and banker. The function
    applies the baccarat game rules to determine the winner. 
    It calls place_bet account to display the result of the game and 
    updates the player's account balance accordingly.

    Requires: [account] is a valid Money.account
*)
