module Core = Ocdwm_core
open Cmdliner

let seat =
  Arg.(
    value
    & opt (some string) None
    & info
        [ "seat" ]
        ~docv:"NAME"
        ~docs:Manpage.s_common_options
        ~doc:"Override primary-seat target")
;;

let socket =
  Arg.(
    value
    & opt (some string) None
    & info
        [ "socket" ]
        ~docv:"PATH"
        ~docs:Manpage.s_common_options
        ~doc:"Override $(b,XDG_RUNTIME_DIR) socket path")
;;

let direction =
  let open Core.Direction in
  Arg.enum [ "next", Next; "prev", Prev ]
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

let policy_flag =
  Arg.(
    value
    & vflag
        Core.Tag_policy.Tag_keep
        [ ( Core.Tag_policy.Tag_take
          , info
              [ "take" ]
              ~doc:"Window takes the the active tags on the destination output" )
        ])
;;

let output_name_arg =
  Arg.(
    required
    & pos 0 (some string) None
    & info
        []
        ~docv:"OUTPUT_NAME"
        ~doc:"The name of the target output, e.g., HDMI-A-2, eDP-1, etc.")
;;

let code_protocol_err = 1
let code_conn_failed = 2

let exit_protocol_err =
  Cmd.Exit.info code_protocol_err ~doc:"on protocol error from ocdwm"
;;

let exit_conn_failed =
  Cmd.Exit.info code_conn_failed ~doc:"on failure to connect to the ocdwm socket"
;;

let exits = exit_protocol_err :: exit_conn_failed :: Cmd.Exit.defaults
let info ?(exits = exits) ?version name ~doc = Cmd.info name ~doc ~exits ?version

let dispatch ?seat ?socket body =
  Eio_main.run
  @@ fun env ->
  match Client.send ~env ?seat ?socket body with
  | Ok () -> Cmd.Exit.ok
  | Error (E_conn_failed msg) ->
    (Logs.err @@ fun m -> m "connection failed: %s" msg);
    code_conn_failed
  | Error (E_protocol msg) ->
    (Logs.err @@ fun m -> m "%s" msg);
    code_protocol_err
;;

let group ?version ~name ~doc =
  let default = Term.(ret (const (`Help (`Auto, None)))) in
  Cmd.group (info ?version name ~doc) ~default
;;

let cmd ~name ~doc body_term =
  let open Cmdliner.Term.Syntax in
  Cmd.v (info name ~doc)
  @@
  let+ seat = seat
  and+ socket = socket
  and+ body = body_term in
  dispatch ?seat ?socket body
;;

let trigger_term action_term =
  let open Cmdliner.Term.Syntax in
  let+ action = action_term in
  Core.Request_body.Trigger action
;;

let bind_suffix =
  let open Cmdliner.Term.Syntax in
  let to_kw = Arg.enum [ "to", () ] in
  let+ () =
    Arg.(
      required
      & pos ~rev:true 1 (some to_kw) None
      & info [] ~docv:"to" ~doc:"Literal $(b,to) separating action from keybind")
  and+ keybind =
    Arg.(
      required
      & pos ~rev:true 0 (some string) None
      & info
          []
          ~docv:"KEYBIND"
          ~doc:
            "Modifiers, keysym, and/or button to bind to COMMAND. Modifiers include \
             Shift, Control, Mod1/Alt, Mod3, Mod4/Super/Logo, Mod5, or None. Keysyms \
             mirror xkbcommon-keysym.h without the 'K_' prefix, e.g., K_Return > Return. \
             Buttons are prefixed with 'Btn_' followed by [0-9], left, right, middle, \
             side, extra, forward, back, or task.")
  in
  keybind
;;

let bind_term action_term =
  let open Cmdliner.Term.Syntax in
  let+ action = action_term
  and+ keybind = bind_suffix in
  Core.Request_body.Setting (Bind { keybind; action })
;;
