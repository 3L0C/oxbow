open! Ocdwm_core
open! Ocdwm_state
open! Ocdwm_layout

let with_focused_column (seat : Seat.t) f =
  match seat.output with
  | None -> Error Messages.seat_missing_output
  | Some { arrangement = Tiling | Overview _; _ } -> Error Messages.not_scrolling
  | Some ({ arrangement = Scrolling; _ } as o) ->
    (match Output.focused_window o with
     | None -> Error Messages.no_focused_window
     | Some w ->
       let cols =
         Strip.columns
           ~consumes:(fun (w : Window.t) -> w.consumes)
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

let set_width seat (delta : float Delta.t) =
  with_focused_column seat
  @@ fun o _w _cols col ->
  match List.nth_opt col 0 with
  | None -> Error "not in a column"
  | Some w ->
    let wf =
      let sw =
        match w.scroll_width with
        | None -> (Output.current_layout_params o).mfact
        | Some sw -> Width_fac.to_float sw
      in
      match delta with
      | Abs d -> Width_fac.of_float d
      | Rel d -> Width_fac.of_float (sw +. d)
    in
    Window.set_scroll_width w (Some wf);
    Ok None
;;

let default_width seat =
  with_focused_column seat
  @@ fun _o _w _cols col ->
  match List.nth_opt col 0 with
  | None -> Error "not in a column"
  | Some w ->
    Window.set_scroll_width w None;
    Ok None
;;

let cycle_width seat =
  with_focused_column seat
  @@ fun o _w _cols col ->
  match List.nth_opt col 0 with
  | None -> Error "not in a column"
  | Some w ->
    let wf =
      match w.scroll_width with
      | None -> (Output.current_layout_params o).mfact |> Width_fac.of_float
      | Some sw -> sw
    in
    Width_fac.cycle wf |> Option.some |> Window.set_scroll_width w;
    Ok None
;;
