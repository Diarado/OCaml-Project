(** Representation of Blackjack.

    This module represents an implementation of the card game Blackjack. 
    It defines necessary types for representing cards, decks, and hands, and
    functions for shuffling a deck, creating a new deck, calculating the score 
    of a hand, and simulating a player and dealer turn. *)

(**********************************************************************
 **********************************************************************)

(** The type [suit] represents the suits (clubs, diamonds, hearts, spades) 
    of cards. *)
type suit = Clubs | Diamonds | Hearts | Spades

(** The type [rank] represnts the 13 cards of each suit (without jokers). 
    There are 14 constructors because A is represented by both Ace and One. *)
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
(** The type [card] is represented by a tuple of rank and suit. Example :
    (Ace, Clubs) *)

type deck = card list
(** The type [deck] is represented by a card list. *)

type hand = card list
(** The type [hand] showing the hand of either player or dealer is represented 
    by a card list. *)

val shuffle : deck -> deck
(** [shuffle d] reorders the deck [d] in randomly. 
    Requires: d has 52 distinct cards with each combination of rank and suit. *)

val create_deck : unit -> deck
(** [create_deck] takes no argument and create a new deck by suffling a ordered 
    deck. Example:
    
    - [create_deck [c2; c3; c4; ... cA; d2; d3; ... h2; ... sA]] is 
    [ sA; d2; h4; ...] (any random order) *)

val string_of_rank : rank -> string
(** [string_of_rank r] is the string representation of [r]. Examples:

    - [string_of_rank Ace] is "A"
    - [string_of_rank One] is "A"
    - [string_of_rank Seven] is "7" 

    Requires: [r] is a valid rank. *)

val string_of_suit : suit -> string
(** [string_of_suit s] is the string representation of [s]. Examples:

    - [string_of_suit Clubs] is "Clubs"

    Requires: [s] is a valid suit. *)

val score : hand -> int
(** [score h] is the score of the hand [h]. It automatically count A as 1 when 
    the sum of cards exceeds 21. 
    Returns 0 if hand is empty. Examples: 
    
    - [score [Ace of Clubs; Ace of Spades]] is 12
    - [score [Ace of Hearts; Ten of Hearts]] is 21
    - [score [Ace of Clubs; Four of Hearts; Seven of Spades]] is 12
    - [score []] is 0

    Requires: [h] is a valid hand
*)

val player_turn : deck -> hand -> hand * deck
(** [player_turn d h] returns the player's hand after each turn. The function 
    will print statement asking hit or stand in the terminal and print outyour 
    current hand. Player loses and an empty hand [] will be returned if the 
    player's score is over 21. If the player's score is exactly 21, they win 
    immediately and the hand will be returned. If the player chooses to hit, 
    a new card from the top of the deck will be added to the player's hand.
    The player's hand will be returned until the player choose to stand. It 
    prints "Invalid input." and returns the current hand if a invalid argument 
    besides "hit" and "stand" is recieved. *)

val dealer_turn : deck -> hand -> hand
(** [dealer_turn d h] begins the dealer's turn after the player stands. The 
    dealer continues to hit (draw cards) until his/her score is at least 17. 
    However, if their score is greater than 21, then the dealer busts. The 
    dealer's hand is returned in the end.*)

val game_loop : deck -> hand -> hand -> Money.account -> float -> unit
(** [game_loop deck p_hand d_hand act bet] takes in a deck of 50 cards [deck], 
    player's hand [p_hand], which is initialized to [], dealer's hand [d_hand],
    which is initialized to the top 2 cards drawn from the deck, account [act],
    and amount of money to bet [bet]. It returns a unit and interacts with the 
    player by printing messages to the console and reading inputs of the player.
    
    The game proceeds as follows:
    - Player places a bet. If the bet is greater than the player's available 
      money, the player is assumed to bet all-in.
    - Player and dealer are each dealt two cards from the deck. 
      One of the dealer's cards is face down.
    - Player takes the turn. The player is prompt to hit (take another card) or 
      stand (keep their current hand). If the player's score exceeds 21, he/she
      busts and the game is over. Otherwise, wins.
    - If player has not won nor bust, the dealer takes the turn. The dealer hits 
      until their score is 17 or greater, or they bust.
    - If both the player and dealer have not busted, their hands are compared, 
      and the one with the higher score wins. If the scores are tied, 
      the game is a push (a tie), and the player gets the bet back.
    - If the deck runs out of cards during a game, a new shuffled deck is mode. 
    *)
