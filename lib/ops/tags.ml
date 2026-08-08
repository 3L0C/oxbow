open! Oxbow_core
open! Oxbow_state

let view (seat : Seat.t) arg =
  match seat.output with
  | None -> Error Messages.seat_missing_output
  | Some o ->
    let s = Output.resolve_tag_arg ~arg o in
    if Tag.Set.is_empty s
    then Error Messages.tag_set_is_empty
    else (
      Output.switch_tags ~tags:s o;
      Ok None)
;;

let toggle_view (seat : Seat.t) s =
  if Tag.Set.is_empty s
  then Error Messages.tag_set_is_empty
  else (
    match seat.output with
    | None -> Error Messages.seat_missing_output
    | Some o ->
      let new_tags = Tag.Set.symmetric_diff o.tags.selected s in
      if Tag.Set.is_empty new_tags
      then Error "toggle would leave no tags visible"
      else (
        Output.switch_tags ~tags:new_tags o;
        Ok None))
;;

let view_previous (seat : Seat.t) =
  match seat.output with
  | None -> Error Messages.seat_missing_output
  | Some o when Tag.Set.is_empty o.tags.previous -> Error "no previous tags defined"
  | Some o ->
    Output.switch_tags ~tags:o.tags.previous o;
    Ok None
;;

let view_cycle (seat : Seat.t) (dir : Direction.Logical.t) =
  match seat.output with
  | None -> Error Messages.seat_missing_output
  | Some o ->
    let target =
      match dir with
      | Next -> Tag.Set.next o.tags.selected
      | Prev -> Tag.Set.prev o.tags.selected
    in
    Output.switch_tags ~tags:target o;
    Ok None
;;

let view_cycle_occupied (seat : Seat.t) (dir : Direction.Logical.t) =
  match seat.output with
  | None -> Error Messages.seat_missing_output
  | Some o ->
    let occupied = Output.occupied_tags o in
    if Tag.Set.is_empty occupied
    then Error "no occupied tags"
    else (
      let tags =
        match dir with
        | Next -> Tag.Set.next_occupied ~selected:o.tags.selected ~occupied
        | Prev -> Tag.Set.prev_occupied ~selected:o.tags.selected ~occupied
      in
      Output.switch_tags ~tags o;
      Ok None)
;;

let tag_window wm seat target ~(tags : Tag.Arg.t) ~follow =
  Result.bind
    (Targets.transact_all_windows wm seat target ~plan:(fun w ->
       let resolve s =
         if Tag.Set.is_empty s
         then Error Messages.tag_set_is_empty
         else Ok (fun () -> Window.set_tags w s)
       in
       match w.output, tags with
       | Some o, _ -> Output.resolve_tag_arg ~arg:tags o |> resolve
       | None, Concrete s -> resolve s
       | None, Occupied -> Error "cannot use 'occupied' for window with no output"))
  @@ fun windows ->
  if follow
  then List.nth_opt windows 0 |> Option.iter (Focus.focus_window ~force:true wm seat);
  Ok None
;;

let toggle_window_tags wm seat target tags =
  if Tag.Set.is_empty tags
  then Error Messages.tag_set_is_empty
  else
    Result.map (fun _ -> None)
    @@ Targets.transact_all_windows wm seat target ~plan:(fun w ->
      let new_tags = Tag.Set.symmetric_diff w.tags tags in
      if Tag.Set.is_empty new_tags
      then Error "toggle would leave window invisible"
      else Ok (fun () -> Window.set_tags w new_tags))
;;

let tag_shift_window wm seat target (dir : Direction.Logical.t) ~follow =
  Result.map (fun _ -> None)
  @@ Targets.transact_all_windows wm seat target ~plan:(fun w ->
    let tags =
      match dir with
      | Next -> Tag.Set.next w.tags
      | Prev -> Tag.Set.prev w.tags
    in
    if Tag.Set.is_empty tags
    then Error Messages.tag_set_is_empty
    else
      Ok
        (fun () ->
          Window.set_tags w tags;
          if follow then Focus.focus_window ~force:true wm seat w))
;;

let tag_shift_window_occupied wm seat target (dir : Direction.Logical.t) ~follow =
  Result.map (fun _ -> None)
  @@ Targets.transact_all_windows wm seat target ~plan:(fun w ->
    match w.output with
    | None -> Error Messages.window_missing_output
    | Some o ->
      let occupied = Output.occupied_tags o in
      if Tag.Set.is_empty occupied
      then Error "no occupied tags"
      else (
        let tags =
          match dir with
          | Next -> Tag.Set.next_occupied ~selected:w.tags ~occupied
          | Prev -> Tag.Set.prev_occupied ~selected:w.tags ~occupied
        in
        Ok
          (fun () ->
            Window.set_tags w tags;
            if follow then Focus.focus_window ~force:true wm seat w)))
;;
