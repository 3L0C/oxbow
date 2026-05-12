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
  | Tag_view n | Tag_toggle_view n | Window_tag n | Window_toggle_tag n ->
    if Core.Tag_set.in_range n
    then Ok ()
    else
      Error
        (Printf.sprintf
           "tag %d outside [%d..%d]"
           n
           Core.Tag_set.min_tag
           Core.Tag_set.max_tag)
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

let handle_line ~(wm : Types.Window_manager.t) ~flow line =
  match Yojson.Safe.from_string line with
  | exception Yojson.Json_error msg ->
    respond_err flow (Printf.sprintf "json parse: %s" msg)
  | json ->
    (match Core.Request.t_of_yojson json with
     | exception _ -> respond_err flow "invalid request shape"
     | req ->
       (match validate ~wm req.cmd with
        | Error e -> respond_err flow e
        | Ok () ->
          (match resolve_seat wm req with
           | Error e -> respond_err flow e
           | Ok seat ->
             Queue.push req.cmd seat.pending_actions;
             Rwm.River_window_manager_v1.manage_dirty wm.river_wm_v1;
             respond_ok flow)))
;;

let run ~(wm : Types.Window_manager.t) flow =
  let buf = Eio.Buf_read.of_flow flow ~max_size:65536 in
  match Eio.Buf_read.line buf with
  | exception _ -> respond_err flow "read failed"
  | line -> handle_line ~wm ~flow line
;;
