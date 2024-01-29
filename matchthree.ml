type item = { color : string; x : int; y : int }
type board = item array array

let init_board width height =
  let aux = Array.make_matrix width height { color = "⬜️"; x = 0; y = 0 } in
  for x = 0 to 7 do
    for y = 0 to 7 do
      let rand_int = Random.int 6 in
      let symbols = [ "⚽️"; "🏀"; "🏈"; "⚾️"; "🎾"; "🏉" ] in
      aux.(x).(y) <- { color = List.nth symbols rand_int; x; y }
    done
  done;
  aux

let rec check_empty board x y : bool =
  match (x, y) with
  | 7, 7 -> if board.(x).(y).color = "⬜️" then true else false
  | 7, _ ->
      if board.(x).(y).color = "⬜️" then check_empty board 0 (y + 1) else false
  | _ ->
      if board.(x).(y).color = "⬜️" then check_empty board (x + 1) y else false

let print_board board =
  let indices = [ "0️⃣"; "1️⃣"; "2️⃣"; "3️⃣"; "4️⃣"; "5️⃣"; "6️⃣"; "7️⃣" ] in
  Printf.printf "%s  " " ";
  for i = 0 to 7 do
    Printf.printf "%s  " (List.nth indices i)
  done;
  print_newline ();
  let counter = ref 0 in
  Array.iter
    (fun row ->
      Printf.printf "%s  " (List.nth indices !counter);
      counter := !counter + 1;
      Array.iter (fun item -> Printf.printf "%s " item.color) row;
      print_newline ())
    board

let swap_items board x1 y1 x2 y2 =
  let temp = board.(x1).(y1) in
  board.(x1).(y1) <- board.(x2).(y2);
  board.(x2).(y2) <- temp

let vertical_shift shift_by x y board =
  for i = x - shift_by downto 0 do
    board.(i + shift_by).(y) <- board.(i).(y)
  done;
  for i = shift_by - 1 downto 0 do
    board.(i).(y) <- { color = "⬜️"; x = i; y }
  done

let rec check_matches board origin pointer =
  match (pointer, origin) with
  | case, { color = "⬜️"; x = _; y = _ } when case <= 0 -> None
  | case, { color = _; x; y } when case <= 1 && y <= 5 ->
      let z1 = board.(x).(y) in
      let z2 = board.(x).(y + 1) in
      let z3 = board.(x).(y + 2) in
      if z1.color = z2.color && z2.color = z3.color then (
        vertical_shift 1 x y board;
        vertical_shift 1 x (y + 1) board;
        vertical_shift 1 x (y + 2) board;
        Some (z1, z2, z3))
      else check_matches board origin 2
  | case, { color = _; x; y } when case <= 2 && y >= 2 ->
      let z1 = board.(x).(y) in
      let z2 = board.(x).(y - 1) in
      let z3 = board.(x).(y - 2) in
      if z1.color = z2.color && z2.color = z3.color then (
        vertical_shift 1 x y board;
        vertical_shift 1 x (y - 1) board;
        vertical_shift 1 x (y - 2) board;
        Some (z1, z2, z3))
      else check_matches board origin 3
  | case, { color = _; x; y } when case <= 3 && y >= 1 && y <= 6 ->
      let z1 = board.(x).(y - 1) in
      let z2 = board.(x).(y) in
      let z3 = board.(x).(y + 1) in
      if z1.color = z2.color && z2.color = z3.color then (
        vertical_shift 1 x y board;
        vertical_shift 1 x (y - 1) board;
        vertical_shift 1 x (y + 1) board;
        Some (z1, z2, z3))
      else check_matches board origin 4
  | case, { color = _; x; y } when case <= 4 && x <= 5 ->
      let z1 = board.(x).(y) in
      let z2 = board.(x + 1).(y) in
      let z3 = board.(x + 2).(y) in
      if z1.color = z2.color && z2.color = z3.color then (
        vertical_shift 3 (x + 2) y board;
        Some (z1, z2, z3))
      else check_matches board origin 5
  | case, { color = _; x; y } when case <= 5 && x >= 2 ->
      let z1 = board.(x - 2).(y) in
      let z2 = board.(x - 1).(y) in
      let z3 = board.(x).(y) in
      if z1.color = z2.color && z2.color = z3.color then (
        vertical_shift 3 x y board;
        Some (z1, z2, z3))
      else check_matches board origin 6
  | case, { color = _; x; y } when case <= 6 && x >= 1 && x <= 6 ->
      let z1 = board.(x + 1).(y) in
      let z2 = board.(x - 1).(y) in
      let z3 = board.(x).(y) in
      if z1.color = z2.color && z2.color = z3.color then (
        vertical_shift 3 (x + 1) y board;
        Some (z1, z2, z3))
      else check_matches board origin 7
  | _ -> None

let io_location prompt =
  print_endline prompt;
  match read_line () with
  | x -> (
      try
        let location = int_of_string x in
        (location / 10, location mod 10)
      with Failure _ -> (-1, -1))

let rec game_loop board round_num : unit =
  Printf.printf "%s: %i\n%!" "Round" round_num;
  print_board board;
  let x1, y1 =
    io_location
      "Type the location of the first ball. To quit, type quit. (For example: \
       13 stands for the ball at row 1 and column 3. All indices start from 0)"
  in
  if x1 = -1 && y1 = -1 then ()
  else
    let x2, y2 =
      io_location
        "Type the location of the second ball. To quit, type quit. (For \
         example: 13 stands for the ball at row 1 and column 3. All indices \
         start from 0)"
    in
    if x2 = -1 && y2 = -1 then ()
    else (
      swap_items board x1 y1 x2 y2;
      match check_matches board board.(x1).(y1) 0 with
      | Some _ -> game_loop board (round_num + 1)
      | None -> (
          match check_matches board board.(x2).(y2) 0 with
          | Some _ -> game_loop board (round_num + 1)
          | None -> game_loop board round_num))

let play_game () =
  let board = init_board 8 8 in
  game_loop board 1
