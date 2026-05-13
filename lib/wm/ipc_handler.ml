[@@@landmark "auto-off"]

module Core = Ocdwm_core
module Rwm = Ocdwm_protocol.River_window_management_v1_client

let respond_err flow msg =
  let r = Core.Response.{ ok = false; err = Some msg } in
  let s = Yojson.Safe.to_string (Core.Response.yojson_of_t r) ^ "\n" in
  Eio.Flow.copy_string s flow
;;

let respond_ok flow =
  let r = Core.Response.{ ok = true; err = None } in
  let s = Yojson.Safe.to_string (Core.Response.yojson_of_t r) ^ "\n" in
  Eio.Flow.copy_string s flow
;;

let validate ~wm (a : Core.Action.t) : (unit, string) result =
  match a with
  | Layout_set name ->
    (match Layout.find ~registry:wm.Types.Window_manager.layout_registry ~name with
     | Some _ -> Ok ()
     | None -> Error (Printf.sprintf "unknown layout: %s" name))
  | Spawn "" -> Error "spawn: empty command"
  | _ -> Ok ()
;;

let resolve_seat (wm : Types.Window_manager.t) (req : Core.Request.t) =
  match req.seat with
  | Some name ->
    (match
       List.find_opt
         (fun (s : Types.Seat.t) ->
            Option.fold ~none:false ~some:(fun n -> n = name) s.name)
         wm.seats
     with
     | Some s -> Ok s
     | None -> Error (Printf.sprintf "no seat named %S" name))
  | None ->
    Option.fold
      ~none:(Error "no primary seat available")
      ~some:(fun s -> Ok s)
      wm.primary_seat
;;

let parse_json line =
  try Ok (Yojson.Safe.from_string line) with
  | Yojson.Json_error msg -> Error (Printf.sprintf "json parse: %s" msg)
;;

let parse_request json =
  try Ok (Core.Request.t_of_yojson json) with
  | Ppx_yojson_conv_lib.Yojson_conv.Of_yojson_error _ -> Error "invalid request shape: %S"
;;

let dispatch ~(wm : Types.Window_manager.t) line =
  let open Result.Syntax in
  let* json = parse_json line in
  let* req = parse_request json in
  let* () = validate ~wm req.cmd in
  let* seat = resolve_seat wm req in
  Ok (req, seat)
;;

let handle_line ~(wm : Types.Window_manager.t) ~flow line =
  match dispatch ~wm line with
  | Error e -> respond_err flow e
  | Ok (req, seat) ->
    Queue.push req.cmd seat.pending_actions;
    Rwm.River_window_manager_v1.manage_dirty wm.river_wm_v1;
    respond_ok flow
;;

let run ~(wm : Types.Window_manager.t) flow =
  let buf = Eio.Buf_read.of_flow flow ~max_size:65536 in
  match Eio.Buf_read.line buf with
  | exception _ -> respond_err flow "read failed"
  | line -> handle_line ~wm ~flow line
;;
