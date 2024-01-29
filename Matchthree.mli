(** This module provides the implementation for a match three game where the
    player aims to match balls of the same color by swapping them with adjacent
    balls. *)

type item = { color : string; x : int; y : int }
(** An item on the game board *)

type board = item array array
(** A game board, represented as a 2D array of items *)

val init_board : int -> int -> item array array
(** [init_board width height] initializes a new game board with the specified
width and height. Returns the newly initialized game board.

Requires: width and height are positive integers *)

val check_empty : item array array -> int -> int -> bool
(** [check_empty board x y] checks whether a specific item on the board is empty.
Returns true if it is empty, and false otherwise. *)

val print_board : item array array -> unit
(** [print_board board] prints the specified board to the console. *)

val swap_items : 'a array array -> int -> int -> int -> int -> unit
(** [swap_items board x1 y1 x2 y2] swaps the items at (x1,y1) and (x2,y2) on the
specified board. *)

val vertical_shift : int -> int -> int -> item array array -> unit
(** [vertical_shift shift_by x y board] shifts all items in the specified column
up by [shift_by] on the specified board, starting at (x,y). The bottom
[shift_by] items in the column will be replaced with empty items. *)

val check_matches :
  item array array -> item -> int -> (item * item * item) option
(** [check_matches board origin pointer] checks if there is a match of 3 or more
balls with the same color in the game board starting from the origin
and return the matched balls if there is any.

[board] is a matrix that represents the game board.
[origin] is a ball in the game board.
[pointer] is an integer that indicates the direction of the search.
- 0: search in all directions.
- 1: search vertically down.
- 2: search vertically up.
- 3: search horizontally left and right.
- 4: search horizontally right.
- 5: search horizontally left.
- 6: search horizontally both left and right.

Returns:
- None if there is no match found.
- Some (z1, z2, z3) if there is a match found. z1, z2, and z3 are balls 
  in the game board with the same color. 
*)

val io_location : string -> int * int
(** This function takes a prompt string and prompts the user to enter the location
   of a ball on the board. It then converts the user input into two integer values,
   which are returned as a tuple. If the user types "quit" instead of a valid location
   , (-1, -1) is returned. *)

val game_loop : item array array -> int -> unit
(** This function is the main game loop. It takes a board and a round number as input,
   and recursively calls itself until there are no more matches on the board. At the start
   of each round, it prints the round number and the current state of the board. It then
    prompts the user to enter the locations of two balls to swap. If the user types "quit"
   instead of a valid location, the function returns. Otherwise, it swaps the balls and
    checks for matches. If there are matches, the function calls itself with the updated
    board and round number. If there are no matches, it calls itself with the original
    board and the same round number. *)

val play_game : unit -> unit
(** This function initializes the game by creating an 8x8 board and calling game_loop
   with the board and round number 1. *)
