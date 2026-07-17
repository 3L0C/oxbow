open! Ocdwm_core
open! Ocdwm_state

let view (seat : Seat.t) arg =
  match seat.output with
  | None -> Error Messages.seat_missing_output
  | Some o ->
    let s = Output.resolve_tag_arg arg o in
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
      let new_tags = Tag.Set.symmetric_diff o.selected_tags s in
      if Tag.Set.is_empty new_tags
      then Error "toggle would leave no tags visible"
      else (
        Output.switch_tags ~tags:new_tags o;
        Ok None))
;;

let view_previous (seat : Seat.t) =
  match seat.output with
  | None -> Error Messages.seat_missing_output
  | Some o when Tag.Set.is_empty o.previous_tags -> Error "no previous tags defined"
  | Some o ->
    Output.switch_tags ~tags:o.previous_tags o;
    Ok None
;;

let view_cycle (seat : Seat.t) (dir : Direction.Logical.t) =
  match seat.output with
  | None -> Error Messages.seat_missing_output
  | Some o ->
    let target =
      match dir with
      | Next -> Tag.Set.next o.selected_tags
      | Prev -> Tag.Set.prev o.selected_tags
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
        | Next -> Tag.Set.next_occupied ~selected:o.selected_tags ~occupied
        | Prev -> Tag.Set.prev_occupied ~selected:o.selected_tags ~occupied
      in
      Output.switch_tags ~tags o;
      Ok None)
;;

let tag_window seat (arg : Tag.Arg.t) =
  match Seat.focused_window seat with
  | None -> Error Messages.no_focused_window
  | Some w ->
    let resolve s =
      if Tag.Set.is_empty s
      then Error Messages.tag_set_is_empty
      else (
        Window.set_tags w s;
        Ok None)
    in
    (match w.output, arg with
     | Some o, _ -> Output.resolve_tag_arg arg o |> resolve
     | None, Concrete s -> resolve s
     | None, Occupied -> Error "cannot use 'occupied' for window with no output")
;;

let toggle_window_tags seat tags =
  if Tag.Set.is_empty tags
  then Error Messages.tag_set_is_empty
  else (
    match Seat.focused_window seat with
    | None -> Error Messages.no_focused_window
    | Some w ->
      let new_tags = Tag.Set.symmetric_diff w.tags tags in
      if Tag.Set.is_empty new_tags
      then Error "toggle would leave window invisible"
      else (
        Window.set_tags w new_tags;
        Ok None))
;;

let tag_window_query ctx q (arg : Tag.Arg.t) =
  match arg with
  | Concrete s when Tag.Set.is_empty s -> Error Messages.tag_set_is_empty
  | _ ->
    (match Window_query.compile q with
     | Error e -> Error e
     | Ok matches ->
       let wm = Ctx.wm ctx in
       let targets =
         List.find_all
           (fun (w : Window.t) -> matches ~title:w.title ~app_id:w.app_id)
           wm.windows
       in
       (match targets with
        | [] ->
          Error (Printf.sprintf "no window matches query: %S" (Window_query.to_string q))
        | ws ->
          List.iter
            (fun (w : Window.t) ->
               match w.output, arg with
               | Some o, _ -> Window.set_tags w (Output.resolve_tag_arg arg o)
               | None, Concrete s -> Window.set_tags w s
               | None, Occupied -> ())
            ws;
          Ok None))
;;

let tag_shift_window seat (dir : Direction.Logical.t) =
  match Seat.focused_window seat with
  | None -> Error Messages.no_focused_window
  | Some w ->
    let tags =
      match dir with
      | Next -> Tag.Set.next w.tags
      | Prev -> Tag.Set.prev w.tags
    in
    if Tag.Set.is_empty tags
    then Error Messages.tag_set_is_empty
    else (
      Window.set_tags w tags;
      Ok None)
;;

let tag_shift_window_occupied seat (dir : Direction.Logical.t) =
  match Seat.focused_window seat with
  | None -> Error Messages.no_focused_window
  | Some w ->
    (match w.output with
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
         Window.set_tags w tags;
         Ok None))
;;
