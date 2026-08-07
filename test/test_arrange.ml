open! Oxbow_core
open! Oxbow_state
open! Oxbow_ops
open! Oxbow_runtime

let sent : Cstruct.t list ref = ref []

let recording_transport =
  object (_ : #Wayland.S.transport)
    method send (buf : Cstruct.t) (_ : Eio_unix.Fd.t list) =
      sent := Cstruct.of_string (Cstruct.to_string buf) :: !sent

    method recv ~sw:_ (_ : Cstruct.t) = 0, []
    method shutdown = ()
    method up = true
    method pp fmt = Format.pp_print_string fmt "recording"
  end
;;

let silent (type a) (m : (module Wayland.Metadata.S with type t = a)) =
  object (_ : (a, _, [ `Client ]) #Wayland.Proxy.Handler.t)
    method user_data = Wayland.S.No_data
    method metadata = m
    method dispatch _proxy _msg = ()
  end
;;

let decode (buf : Cstruct.t) : (int32 * int) list =
  let rec go off acc =
    if off >= Cstruct.length buf
    then List.rev acc
    else (
      let id = Cstruct.LE.get_uint32 buf off in
      let word = Cstruct.LE.get_uint32 buf (off + 4) in
      let size = Int32.to_int (Int32.shift_right_logical word 16) in
      let opcode = Int32.to_int (Int32.logand word 0xFFFFl) in
      go (off + size) ((id, opcode) :: acc))
  in
  go 0 []
;;

let spawn root = fun m -> Wayland.Proxy.spawn (Wayland.Proxy.cast_version root) (silent m)

let make_wm root =
  Oxbow_state.Wm.
    { river_wm_v1 =
        spawn root (module River.Proto.Window_management.River_window_manager_v1)
    ; river_xkb_v1 = spawn root (module River.Proto.Xkb.Bindings.River_xkb_bindings_v1)
    ; river_lsh_v1 = spawn root (module River.Proto.Layer_shell.River_layer_shell_v1)
    ; river_input_v1 =
        spawn root (module River.Proto.Input.Management.River_input_manager_v1)
    ; river_libinput_v1 =
        spawn root (module River.Proto.Input.Config.River_libinput_config_v1)
    ; river_xkb_config_v1 = spawn root (module River.Proto.Xkb.Config.River_xkb_config_v1)
    ; shutdown = Eio.Condition.create ()
    ; lifecycle = Running
    ; primary_seat = None
    ; session_locked = false
    ; outputs = []
    ; windows = []
    ; seats = []
    ; input_devices = []
    ; xkb_stash = []
    ; keymap = None
    ; desired_keymap_path = None
    ; config = Config.default ()
    ; init_command = None
    ; init_handle = None
    ; ipc = { subscribers = []; last = [] }
    }
;;

let make_seat root =
  Seat.
    { obj = spawn root (module River.Proto.Window_management.River_seat_v1)
    ; layer_shell = spawn root (module River.Proto.Layer_shell.River_layer_shell_seat_v1)
    ; xkb_seat = spawn root (module River.Proto.Xkb.Bindings.River_xkb_bindings_seat_v1)
    ; overview_watch = 0l
    ; watch_sent = 0l
    ; lifecycle = New
    ; name = None
    ; output = None
    ; focus_cleared = false
    ; position = { x = 0l; y = 0l }
    ; layer_focus = None
    ; mode = Mode.normal
    ; xkb_bindings = []
    ; pointer_bindings = []
    ; pending_requests = Queue.create ()
    ; hovered = None
    ; interacted = None
    ; warp_request = No_request
    ; focus_state = Idle
    ; cursor_target = None
    ; op = None
    }
;;

let make_output root =
  Output.
    { obj = spawn root (module River.Proto.Window_management.River_output_v1)
    ; layer_shell =
        spawn root (module River.Proto.Layer_shell.River_layer_shell_output_v1)
    ; lifecycle = Active
    ; name = None
    ; labels = []
    ; geom = { x = 0l; y = 0l; w = 0l; h = 0l }
    ; usable = { x = 0; y = 0; w = 1920; h = 1080 }
    ; tags = { selected = Tag.Set.singleton 1; previous = Tag.Set.singleton 1 }
    ; overview = { offset = 0; enabled = false; gaps = 10; head = None }
    ; tag_data = Array.init 32 (fun _ -> Config.create_tag_data ())
    ; focus_stack = []
    ; wm_stack = []
    }
;;

let make_window output root =
  Window.create
    (Some output)
    (Output.to_tag_data output).scrolling.default_width
    (spawn root (module River.Proto.Window_management.River_window_v1))
;;

let pp_rect (r : int32 Rect.t) = Printf.sprintf "(%ld, %ld) %ldx%ld" r.x r.y r.w r.h

let () =
  Eio_main.run
  @@ fun _env ->
  Eio.Switch.run
  @@ fun sw ->
  let conn = Wayland.Client.connect ~sw recording_transport in
  let root = Wayland.Client.wl_display conn in
  let wm = make_wm root in
  let seat = make_seat root in
  let output = make_output root in
  let windows = List.init 3 (fun _ -> make_window output root) in
  Wm.set_windows wm windows;
  Output.set_wm_stack output windows;
  Output.set_focus_stack output windows;
  Arrange.retile wm output;
  List.iteri
    (fun i (w : Window.t) ->
       Printf.printf "window(index=%d, id=%lu): %s\n" i (Wire.id w.obj) (pp_rect w.geom))
    output.wm_stack;
  let windows = windows @ List.init 4 (fun _ -> make_window output root) in
  Wm.set_windows wm windows;
  Output.set_wm_stack output windows;
  List.rev windows |> Output.set_focus_stack output;
  Output.enter_overview output;
  Arrange.retile wm output;
  List.iteri
    (fun i (w : Window.t) ->
       Printf.printf "window(index=%d, id=%lu): %s\n" i (Wire.id w.obj) (pp_rect w.geom))
    output.wm_stack;
  Focus.focus_output wm seat output;
  Focus.window_logical wm seat Focused Prev
  |> Result.iter_error (fun e -> Printf.printf "focus prev request failed: %s" e);
  Arrange.retile wm output;
  List.iteri
    (fun i (w : Window.t) ->
       Printf.printf "window(index=%d, id=%lu): %s\n" i (Wire.id w.obj) (pp_rect w.geom))
    output.wm_stack;
  sent := [];
  Ctx.with_manage wm Commit.manage;
  let messages = List.rev !sent |> List.concat_map decode in
  List.iteri
    (fun i (w : Window.t) ->
       let mine =
         List.filter (fun (id, _opcode) -> Int32.equal id (Wire.id w.obj)) messages
       in
       List.iter
         (fun (_id, opcode) ->
            let name, _args =
              River.Proto.Window_management.River_window_v1.requests opcode
            in
            Printf.printf "%d: %s\n" i name)
         mine)
    output.wm_stack
;;
