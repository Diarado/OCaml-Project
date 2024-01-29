(** Representation of Roulette.

    This module implements the European Roulette game, which includes a 
    roulette wheel with 37 slots (0 to 36) and a betting table with various 
    bet types and payouts. *)

(**********************************************************************
 **********************************************************************)

val print_wheel : unit -> unit
(** [print_wheel ()] prints the roulette wheel with its numbers and colors in 
    a table form. *)

val spin_wheel : unit -> int
(** [spin_wheel ()] returns a random integer between 0 and 36, representing
    the slot where the ball landed on the roulette wheel. *)

val calculate_payout : string -> int -> int -> int
(** [calculate_payout bet_type amt win_num] returns the payout for a given bet
    based on the bet type [bet_type], the amount bet [amt], and the spinned 
    number [win_num].

    The payout rule of Roulette is shown below:
    
Bet Type	       Payout Odds	               Description
Single              35:1	      Betting on a single number.
Split	            17:1	      Betting on two adjacent numbers.
Street	            11:1	      Betting on three numbers in a horizontal line.
Corner	            8:1	          Betting on four numbers that meet at a corner.
Double Street	    5:1	          Betting on six numbers in two adjacent horizontal lines.
Column              2:1	          Betting on all 12 numbers in one of the three vertical columns.
Dozen	            2:1	          Betting on the first, second, or third group of 12 numbers (1-12, 13-24, or 25-36).
Red/Black, Odd/Even	1:1           Betting on all red or black numbers, or all odd or even numbers.
High/Low            1:1	          Betting on the first 18 numbers (low) or the last 18 numbers (high).
    
    Examples:
    - [calculate_payout "even" 20 2] is 40

    Requires: win_num is between 0 and 36. *)

val play_roulette : Money.account -> unit
(** [play_roulette act] allows the user to play a game of roulette with their 
    [act]. It prints the betting options, accepts the user's bet, and determines 
    the payout if the bet is successful. 
    
    Requires: act is a valid account

*)
