open! Oxbow_core
open! Oxbow_state
open! Oxbow_layout

let with_column_of ?(scroll_required = true) w f =
  With.output w
  @@ fun o ->
  if scroll_required && Output.current_layout o <> Scrolling
  then Error Messages.not_scrolling
  else (
    let cols =
      Strip.columns
        ~consumes:(fun (w : Window.t) -> w.scrolling.consumes)
        (Output.tiled_windows o)
    in
    match List.find_opt (List.memq w) cols with
    | None -> Error "target window is not in the strip"
    | Some col -> f o cols col)
;;

let consume wm seat target =
  Result.map (fun _ -> None)
  @@ Targets.transact_one_window wm seat target ~plan:(fun w ->
    with_column_of w
    @@ fun _o cols col ->
    let last = List.rev cols |> List.hd in
    if last == col
    then Error "no next column to consume"
    else (
      let last = List.rev col |> List.hd in
      Ok (fun () -> Window.set_consumes last true)))
;;

let expel w (o : Output.t) col =
  match col with
  | [ _ ] -> ()
  | _ ->
    let head = List.hd col in
    let remaining = List.filter (( != ) w) col in
    Ring.hop_left (( == ) w) (( == ) head) o.wm_stack |> Output.set_wm_stack o;
    Window.set_consumes w false;
    List.rev remaining |> List.hd |> fun w -> Window.set_consumes w false
;;

let release wm seat target =
  Result.map (fun _ -> None)
  @@ Targets.transact_one_window wm seat target ~plan:(fun w ->
    with_column_of w
    @@ fun o _cols col ->
    match col with
    | [ _ ] -> Error "target window is alone in its column"
    | _ -> Ok (fun () -> expel w o col))
;;

let detach (w : Window.t) =
  with_column_of w (fun o _cols col -> Ok (expel w o col)) |> ignore
;;

let move wm seat target (dir : Direction.Logical.t) =
  Result.map (fun _ -> None)
  @@ Targets.transact_one_window wm seat target ~plan:(fun w ->
    with_column_of w
    @@ fun o cols col ->
    match cols with
    | [ _ ] -> Error "no other column"
    | _ ->
      let hop =
        match dir with
        | Next -> Ring.hop_right
        | Prev -> Ring.hop_left
      in
      let order = hop (( == ) col) (fun _ -> true) cols |> List.concat in
      Ok
        (fun () ->
          Output.set_wm_stack o
          @@ Ring.rearrange (fun w -> List.memq w order) order o.wm_stack))
;;

let set_width wm seat target (delta : float Delta.t) ~global =
  Result.map (fun _ -> None)
  @@ Targets.transact_one_window wm seat target ~plan:(fun w ->
    with_column_of ~scroll_required:false w
    @@ fun o _cols col ->
    let apply ~f w = Width_fac.of_float f |> Window.set_scroll_width w in
    match List.nth_opt col 0 with
    | None -> Error "not in a column"
    | Some w ->
      let f =
        match delta with
        | Abs a -> a
        | Rel r -> Width_fac.to_float w.scrolling.width +. r
      in
      Ok (fun () -> if global then List.iter (apply ~f) o.wm_stack else apply ~f w))
;;

let default_width wm seat target =
  Result.map (fun _ -> None)
  @@ Targets.transact_one_window wm seat target ~plan:(fun w ->
    with_column_of w
    @@ fun o _cols col ->
    match List.nth_opt col 0 with
    | None -> Error "not in a column"
    | Some w ->
      Ok
        (fun () ->
          Window.set_scroll_width w (Output.to_tag_data o).scrolling.default_width))
;;

let cycle_width wm seat target =
  Result.map (fun _ -> None)
  @@ Targets.transact_one_window wm seat target ~plan:(fun w ->
    with_column_of w
    @@ fun _o _cols col ->
    match List.nth_opt col 0 with
    | None -> Error "not in a column"
    | Some w ->
      Ok (fun () -> Width_fac.cycle w.scrolling.width |> Window.set_scroll_width w))
;;

let zoom ?warp wm seat w =
  with_column_of w
  @@ fun o cols col ->
  let warp = Seat.Warp_request.of_override warp in
  match col with
  | _ :: _ :: _ ->
    let last = List.rev col |> List.hd in
    if last == w
    then Ring.prev_or_last w col |> Option.iter (fun x -> Window.set_consumes x false);
    Window.set_consumes w false;
    Stacking.push [ w ] o;
    Focus.focus_window ~force:true ~warp wm seat w;
    Ok None
  | [ _ ] ->
    (match cols with
     | [ _ ] -> Error "no other column"
     | first :: _ when first != col ->
       Stacking.push [ w ] o;
       Focus.focus_window ~force:true ~warp wm seat w;
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
       Focus.focus_window ~force:true ~warp wm seat next_head;
       Ok None
     | _ -> Error "no other column")
  | [] -> Error "window is not in the strip"
;;
