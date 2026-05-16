module Core = Ocdwm_core
open Cmdliner

let seat =
  Arg.(
    value
    & opt (some string) None
    & info [ "seat" ] ~docv:"NAME" ~doc:"Override primary-seat target")
;;

let socket =
  Arg.(
    value
    & opt (some string) None
    & info [ "socket" ] ~docv:"PATH" ~doc:"Override $(b,XDG_RUNTIME_DIR) socket path")
;;

let direction =
  let open Core.Direction in
  Arg.enum
    [ "next", Dir_next
    ; "prev", Dir_prev
    ; "left", Dir_left
    ; "right", Dir_right
    ; "up", Dir_up
    ; "down", Dir_down
    ]
;;

let stack_kind =
  let open Core.Stack_kind in
  Arg.enum [ "even", Stack_even; "diminish", Stack_diminish; "dwindle", Stack_dwindle ]
;;

let int_delta =
  let parser = function
    | "" -> Error "empty delta"
    | s when s.[0] = '+' || s.[0] = '-' ->
      (match int_of_string_opt s with
       | Some n -> Ok (Core.Delta.Rel n)
       | None -> Error (Printf.sprintf "bad int delta: %s" s))
    | s ->
      (match int_of_string_opt s with
       | Some n -> Ok (Core.Delta.Abs n)
       | None -> Error (Printf.sprintf "bad int: %s" s))
  in
  let pp ppf = function
    | Core.Delta.Abs n -> Format.fprintf ppf "%d" n
    | Rel n -> Format.fprintf ppf "%+d" n
  in
  Arg.Conv.make ~docv:"DELTA" ~parser ~pp ()
;;

let float_delta =
  let parser = function
    | "" -> Error "empty delta"
    | s when s.[0] = '+' || s.[0] = '-' ->
      (match float_of_string_opt s with
       | Some n -> Ok (Core.Delta.Rel n)
       | None -> Error (Printf.sprintf "bad float delta: %s" s))
    | s ->
      (match float_of_string_opt s with
       | Some n -> Ok (Core.Delta.Abs n)
       | None -> Error (Printf.sprintf "bad float: %s" s))
  in
  let pp ppf = function
    | Core.Delta.Abs n -> Format.fprintf ppf "%f" n
    | Rel n -> Format.fprintf ppf "%+f" n
  in
  Arg.Conv.make ~docv:"DELTA" ~parser ~pp ()
;;

let tag_set : Core.Tag_set.t Arg.Conv.t =
  let open Core in
  let parser = Tag_set.of_string in
  let pp ppf t = Format.fprintf ppf "%s" (Tag_set.to_string t) in
  Arg.Conv.make ~docv:"TAGS" ~parser ~pp ()
;;

let tag_arg : Core.Tag_arg.t Arg.Conv.t =
  let open Core in
  let parser s =
    let s = String.trim s in
    match s with
    | "occupied" -> Ok Tag_arg.Tags_occupied
    | s -> Result.map (fun t -> Tag_arg.Tags_concrete t) (Tag_set.of_string s)
  in
  let pp ppf = function
    | Tag_arg.Tags_occupied -> Format.fprintf ppf "occupied"
    | Tag_arg.Tags_concrete t -> Format.fprintf ppf "%s" (Tag_set.to_string t)
  in
  Arg.Conv.make ~docv:"TAGS" ~parser ~pp ()
;;

let exit_ok = Cmd.Exit.ok
let exit_protocol_err = 1
let exit_conn_failed = 2

let dispatch ?seat ?socket action =
  Eio_main.run
  @@ fun env ->
  match Client.send ~env ?seat ?socket action with
  | Ok () -> exit_ok
  | Error (E_conn_failed msg) ->
    Logs.err (fun m -> m "connection failed: %s" msg);
    exit_conn_failed
  | Error (E_protocol msg) ->
    Logs.err (fun m -> m "%s" msg);
    exit_protocol_err
;;

let simple_cmd ~name ~doc action =
  let open Cmdliner.Term.Syntax in
  Cmd.v (Cmd.info name ~doc)
  @@
  let+ seat = seat
  and+ socket = socket in
  dispatch ?seat ?socket action
;;
