open! Ocdwm_core
open! Ocdwm_state
open! Ocdwm_ipc
open! Ocdwm_layout

let snapshot_tags (output : Output.t) =
  let f name =
    ( (Event.Kind.Tags, name)
    , Event.Tags
        { output = name
        ; viewed = Tag.Set.to_list output.selected_tags
        ; occupied = Output.occupied_tags output |> Tag.Set.to_list
        ; urgent = Output.urgent_tags output |> Tag.Set.to_list
        ; focused =
            Output.focused_window output
            |> Option.fold ~none:[] ~some:(fun (w : Window.t) -> Tag.Set.to_list w.tags)
        } )
  in
  Option.map f output.name
;;

let snapshot_windows (output : Output.t) =
  let f name =
    let focused = Output.focused_window output in
    ( (Event.Kind.Window, name)
    , Event.Window
        { output = name
        ; title = Option.bind focused (fun w -> w.title)
        ; app_id = Option.bind focused (fun w -> w.app_id)
        } )
  in
  Option.map f output.name
;;

let snapshot_layout (output : Output.t) =
  let f name =
    let entry = Output.current_layout_entry output in
    ( (Event.Kind.Layout, name)
    , Event.Layout
        { output = name
        ; layout = Entry.name entry
        ; symbol = Entry.symbol (Output.current_layout_ctx output) entry
        } )
  in
  Option.map f output.name
;;

let snapshot_mode (seat : Seat.t) =
  let f name = (Event.Kind.Mode, name), Event.Mode { seat = name; mode = seat.mode } in
  Option.map f seat.name
;;

let snapshots (wm : Wm.t) =
  let seat_snaps = List.filter_map snapshot_mode wm.seats in
  let out_snaps =
    List.map
      (fun (o : Output.t) ->
         let snaps = [ snapshot_tags o; snapshot_windows o; snapshot_layout o ] in
         List.filter_map Fun.id snaps)
      wm.outputs
    |> List.flatten
  in
  out_snaps @ seat_snaps
;;

let matches (sub : Wm.Ipc.Subscriber.t) (k, source) =
  List.exists (Event.Kind.equal k) sub.kinds
  &&
  match sub.output with
  | None -> true
  | Some o ->
    (match k with
     | Mode -> true
     | _ -> String.equal o source)
;;

let offer (sub : Wm.Ipc.Subscriber.t) key line =
  if List.mem_assoc key sub.pending
  then
    sub.pending
    <- List.map (fun (k, old) -> if k = key then k, line else k, old) sub.pending
  else sub.pending <- sub.pending @ [ key, line ];
  Eio.Condition.broadcast sub.wake
;;

let seed (wm : Wm.t) (sub : Wm.Ipc.Subscriber.t) =
  List.iter
    (fun (key, ev) -> if matches sub key then offer sub key (Event.to_line ev))
    wm.ipc.last
;;

let publish (wm : Wm.t) =
  let snaps = snapshots wm in
  let changed =
    List.filter_map
      (fun (key, ev) ->
         match List.assoc_opt key wm.ipc.last with
         | None -> Some (key, ev)
         | Some ev' when ev <> ev' -> Some (key, ev)
         | _ -> None)
      snaps
  in
  List.iter
    (fun (key, ev) ->
       let line = Event.to_line ev in
       List.iter
         (fun sub -> if matches sub key then offer sub key line)
         wm.ipc.subscribers)
    changed;
  wm.ipc.last <- snaps
;;
