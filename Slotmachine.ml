type symbol = string
type slot_machine = symbol list list

let spin_slot_machine () : symbol list =
  let symbols = [ "🍒"; "🍇"; "🍊"; "🍉"; "🔔" ] in
  List.map
    (fun _ -> List.nth symbols (Random.int (List.length symbols)))
    [ 0; 1; 2 ]

let print_spin_result (result : symbol list) : unit =
  List.iter
    (fun symbol ->
      print_string symbol;
      print_string " ")
    result;
  print_newline ()

let is_win (result : symbol list) : bool =
  let check_row row =
    match row with [ a; b; c ] -> a = b && b = c | _ -> false
  in
  check_row result (* check if any row is a win *)

let main () =
  let result = spin_slot_machine () in
  print_spin_result result

let () = main ()
