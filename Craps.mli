(** Representation of Craps.

    This module represents an implementation of the dice game Craps. *)

(**********************************************************************
 **********************************************************************)

val roll_dice : unit -> int * int
(** [roll_dice ()] returns the sum of the two numbers between 1 and 6 as a 
    tuple of two integers. *)

val print_state : int option -> int list -> unit
(** [print_state point rolls] prints the current game state, where [point] is an 
    integer option representing the point and [rolls] is an integer list 
    representing the rolls so far. If the player's first roll is 2, 3, 7, 11, 
    or 12, the game ends immediately. Otherwise, if the player's first roll is 
    4, 5, 6, 8, 9, or 10, that number becomes their "point", and they need to 
    roll that number again before rolling a 7 in order to win. If they roll a 7 
    before rolling their point, they lose.
        
    Examples:
    - [print_state None, []] prints "Rolling for the first time.".
    - [print_state (Some 5), [2; 5; 6; 4]] prints "Point is 5"
      "Rolls so far: 2, 5, 6, 4". *)

val play_craps : Money.account -> unit
(** [play_craps account] is the main function that handles Craps. It prompts the 
    player to place a bet, rolls two dice to determine the point, and applies 
    the rules to determine the winner.
    
    The rule of Craps is shown below:
    - Player places a bet before the roll.
    - The first roll, aka "come out roll". If this roll is a 7 or 11, the player 
      wins. If this roll is a 2, 3, or 12, the player loses (pass line).
    - If the come out roll is any other number (4, 5, 6, 8, 9, 10), then that 
      number becomes the "point" and the player must roll that number again 
      before rolling a 7 to win.
    - If player rolls the "point" before rolling a 7, he/she wins. 
      If he/she rolls a 7 before rolling the "point", he/she loses.
    
    Payouts: 
    - In the case of the "pass line" bet, the odds of winning is higher than the 
      odds of losing, so the payout is at 1:1.5.
    - If the player rolls a point (4, 5, 6, 8, 9, or 10) on the first roll, then 
      the game continues until either the point is rolled again (wins), or a 7 
      is rolled(loses). The odds of winning a "pass line" bet in this case are 
      not as high as the odds of losing, so the payout is higher, at 1:2.

    Requires: [account] is a valid Money.account representing the player's 
    account. *)
