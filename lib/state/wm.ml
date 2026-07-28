include Types.Wm

module Lifecycle = struct
  include Types.Wm.Lifecycle

  let to_string = function
    | Running -> "running"
    | Pending_exit `Local -> "pending_exit(local)"
    | Pending_exit `Compositor -> "pending_exit(compositor)"
    | Exited -> "exited"
    | Close_requested -> "close_requested"
  ;;
end

let focused_output (wm : t) = Option.bind wm.primary_seat @@ fun s -> s.output

let default_output (wm : t) =
  match focused_output wm with
  | Some _ as o -> o
  | None -> List.nth_opt wm.outputs 0
;;

let ensure_seat_output (wm : t) (seat : Types.Seat.t) =
  match seat.output with
  | Some _ -> ()
  | None -> default_output wm |> Seat.focus_output seat
;;

let set_primary_seat (wm : t) seat = wm.primary_seat <- seat
let set_outputs (wm : t) outputs = wm.outputs <- outputs
let set_windows (wm : t) windows = wm.windows <- windows
let set_seats (wm : t) seats = wm.seats <- seats
let set_lifecycle (wm : t) lifecycle = wm.lifecycle <- lifecycle
let set_keymap (wm : t) keymap = wm.keymap <- keymap
let set_desired_keymap_path (wm : t) path = wm.desired_keymap_path <- path
let set_init_handle (wm : t) script = wm.init_handle <- script
let set_input_devices (wm : t) devices = wm.input_devices <- devices

let add_xkb_stash (wm : t) device xkb =
  if not @@ List.mem_assoc device wm.xkb_stash
  then wm.xkb_stash <- (device, xkb) :: wm.xkb_stash
;;

let remove_xkb_stash (wm : t) device =
  let _matches, rest = List.partition (fun (d, _) -> Int32.equal device d) wm.xkb_stash in
  wm.xkb_stash <- rest
;;

let find_xkb_stash_opt (wm : t) device =
  let result = List.find_opt (fun (d, _xkb) -> Int32.equal device d) wm.xkb_stash in
  match result with
  | Some (_, xkb) -> Some xkb
  | None -> None
;;

let add_input_device (wm : t) entry =
  set_input_devices wm @@ (entry :: wm.input_devices);
  remove_xkb_stash wm @@ Input_device.id entry.device
;;

let remove_input_device (wm : t) entry =
  set_input_devices wm @@ List.filter (fun e -> e != entry) wm.input_devices;
  Input_device.remove_entry entry
;;

let find_window_opt (wm : t) id =
  List.find_opt (fun (w : Types.Window.t) -> Wire.id w.obj = id) wm.windows
;;

let find_seat_opt (wm : t) id =
  List.find_opt (fun (s : Types.Seat.t) -> Wire.id s.obj = id) wm.seats
;;

let find_output_opt (wm : t) id =
  List.find_opt (fun (o : Types.Output.t) -> Wire.id o.obj = id) wm.outputs
;;

let find_input_device_opt (wm : t) id =
  List.find_opt
    (fun (e : Types.Input_device.t) -> Input_device.id e.device = id)
    wm.input_devices
;;

let add_subscriber (wm : t) sub = wm.ipc.subscribers <- sub :: wm.ipc.subscribers

let remove_subscriber (wm : t) sub =
  wm.ipc.subscribers <- List.filter (( != ) sub) wm.ipc.subscribers
;;

let set_session_locked (wm : t) b = wm.session_locked <- b
