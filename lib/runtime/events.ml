open! Oxbow_state
open! Oxbow_ipc
open! Oxbow_ops

let snapshot_tags (output : Output.t) =
  match output.name, Records.to_tags output with
  | None, _ | _, None -> None
  | Some name, Some record -> Some ((Record.Tags, name), Event.Tags record)
;;

let snapshot_windows (wm : Wm.t) output =
  let focused_window = Output.focused_window output in
  match
    output.name, Option.bind focused_window (fun w -> Some (Records.to_window wm w))
  with
  | None, _ | _, None -> None
  | Some name, Some record -> Some ((Record.Window, name), Event.Window record)
;;

let snapshot_layout (output : Output.t) =
  match output.name, Records.to_layout output with
  | None, _ | _, None -> None
  | Some name, Some record -> Some ((Record.Layout, name), Event.Layout record)
;;

let snapshot_mode (seat : Seat.t) =
  match seat.name, Records.to_mode seat with
  | None, _ | _, None -> None
  | Some name, Some record -> Some ((Record.Mode, name), Event.Mode record)
;;

let snapshot_focus (seat : Seat.t) =
  match seat.name, Records.to_focus seat with
  | None, _ | _, None -> None
  | Some name, Some record -> Some ((Record.Focus, name), Event.Focus record)
;;

let snapshots (wm : Wm.t) =
  let seat_snaps =
    List.map
      (fun (s : Seat.t) ->
         let snaps = [ snapshot_mode s; snapshot_focus s ] in
         List.filter_map Fun.id snaps)
      wm.seats
    |> List.flatten
  in
  let out_snaps =
    List.map
      (fun (o : Output.t) ->
         let snaps = [ snapshot_tags o; snapshot_windows wm o; snapshot_layout o ] in
         List.filter_map Fun.id snaps)
      wm.outputs
    |> List.flatten
  in
  out_snaps @ seat_snaps
;;

let matches (sub : Wm.Ipc.Subscriber.t) (k, source) =
  List.exists (Record.equal k) sub.kinds
  &&
  match sub.output with
  | None -> true
  | Some o ->
    (match k with
     | Mode | Focus -> true
     | Tags | Window | Layout -> String.equal o source)
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
