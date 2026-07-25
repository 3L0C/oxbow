open! Ocdwm_core
open! Ocdwm_state
open! Ocdwm_layout

let with_focused_column ?(scroll_required = true) (seat : Seat.t) f =
  match seat.output with
  | None -> Error Messages.seat_missing_output
  | Some o when scroll_required && Output.current_layout o <> Scrolling ->
    Error Messages.not_scrolling
  | Some o ->
    (match Output.focused_window o with
     | None -> Error Messages.no_focused_window
     | Some w ->
       let cols =
         Strip.columns
           ~consumes:(fun (w : Window.t) -> w.scrolling.consumes)
           (Output.tiled_windows o)
       in
       (match List.find_opt (List.memq w) cols with
        | None -> Error "focused window is not in the strip"
        | Some col -> f o w cols col))
;;

let consume seat =
  with_focused_column seat
  @@ fun _o _w cols col ->
  let rec next_exists = function
    | c :: _ :: _ when c == col -> true
    | _ :: rest -> next_exists rest
    | [] -> false
  in
  if not @@ next_exists cols
  then Error "no next column to consume"
  else (
    let last = List.rev col |> List.hd in
    Window.set_consumes last true;
    Ok None)
;;

let release seat =
  with_focused_column seat
  @@ fun o w _cols col ->
  match col with
  | [ _ ] -> Error "focused window is alone in its column"
  | _ ->
    let head = List.hd col in
    let remaining = List.filter (( != ) w) col in
    let stack' = Ring.hop_left (( == ) w) (( == ) head) o.wm_stack in
    Output.set_wm_stack o stack';
    Window.set_consumes w false;
    (List.rev remaining |> List.hd |> fun w -> Window.set_consumes w false);
    Ok None
;;

let move seat (dir : Direction.Logical.t) =
  with_focused_column seat
  @@ fun o _w cols col ->
  match cols with
  | [ _ ] -> Error "no other column"
  | _ ->
    let hop =
      match dir with
      | Next -> Ring.hop_right
      | Prev -> Ring.hop_left
    in
    let order = hop (( == ) col) (fun _ -> true) cols |> List.concat in
    Output.set_wm_stack o @@ Ring.rearrange (fun w -> List.memq w order) order o.wm_stack;
    Ok None
;;

let set_width seat (delta : float Delta.t) ~global =
  with_focused_column ~scroll_required:false seat
  @@ fun o _w _cols col ->
  let apply ~f w = Width_fac.of_float f |> Window.set_scroll_width w in
  match List.nth_opt col 0 with
  | None -> Error "not in a column"
  | Some w ->
    let f =
      match delta with
      | Abs a -> a
      | Rel r -> Width_fac.to_float w.scrolling.width +. r
    in
    if global then List.iter (apply ~f) o.wm_stack else apply ~f w;
    Ok None
;;

let default_width seat =
  with_focused_column seat
  @@ fun o _w _cols col ->
  match List.nth_opt col 0 with
  | None -> Error "not in a column"
  | Some w ->
    Window.set_scroll_width w (Output.to_tag_data o).scrolling.default_width;
    Ok None
;;

let cycle_width seat =
  with_focused_column seat
  @@ fun _o _w _cols col ->
  match List.nth_opt col 0 with
  | None -> Error "not in a column"
  | Some w ->
    Width_fac.cycle w.scrolling.width |> Window.set_scroll_width w;
    Ok None
;;

let zoom ?warp ctx seat =
  with_focused_column seat
  @@ fun o w cols col ->
  let warp = Seat.Warp_request.of_override warp in
  match col with
  | _ :: _ :: _ ->
    let rec prev_of = function
      | p :: x :: _ when x == w -> Some p
      | _ :: rest -> prev_of rest
      | [] -> None
    in
    let last = List.rev col |> List.hd in
    if last == w
    then (
      match prev_of col with
      | Some x -> Window.set_consumes x false
      | None -> assert false);
    Window.set_consumes w false;
    Stacking.push [ w ] o;
    Focus.focus_window ~force:true ~warp ctx seat w;
    Ok None
  | [ _ ] ->
    (match cols with
     | [ _ ] -> Error "no other column"
     | first :: _ when first != col ->
       Stacking.push [ w ] o;
       Focus.focus_window ~force:true ~warp ctx seat w;
       Ok None
     | _ :: (next_head :: _) :: _ ->
       Window.set_consumes w next_head.scrolling.consumes;
       Window.set_consumes next_head false;
       let order =
         List.concat cols
         |> List.map (fun x ->
           if x == w then next_head else if x == next_head then w else x)
       in
       Output.set_wm_stack o
       @@ Ring.rearrange (fun x -> List.memq x order) order o.wm_stack;
       Focus.focus_window ~force:true ~warp ctx seat next_head;
       Ok None
     | _ -> Error "no other column")
  | [] -> Error "focused window is not in the strip"
;;
