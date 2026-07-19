open! Cmdliner
open! Ocdwm_core
open! Ocdwm_ipc

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

let spatial_targets =
  let open Direction.Spatial in
  List.map (fun d -> to_string d, d) [ Up; Down; Left; Right ]
;;

let logical_targets =
  let open Direction.Logical in
  List.map (fun d -> to_string d, d) [ Next; Prev ]
;;

let direction_targets =
  let open Direction in
  List.map (fun (s, d) -> s, Logical d) logical_targets
  @ List.map (fun (s, d) -> s, Spatial d) spatial_targets
;;

let int_delta_conv =
  let parser = function
    | "" -> Error "empty delta"
    | s when s.[0] = '+' || s.[0] = '-' ->
      (match int_of_string_opt s with
       | Some n -> Ok (Delta.Rel n)
       | None -> Error (Printf.sprintf "bad int delta: %s" s))
    | s ->
      (match int_of_string_opt s with
       | Some n -> Ok (Delta.Abs n)
       | None -> Error (Printf.sprintf "bad int: %s" s))
  in
  let pp ppf = function
    | Delta.Abs n -> Format.fprintf ppf "%d" n
    | Rel n -> Format.fprintf ppf "%+d" n
  in
  Arg.Conv.make ~docv:"DELTA" ~parser ~pp ()
;;

let int_delta =
  Arg.(
    required
    & pos 0 (some int_delta_conv) None
    & info
        []
        ~docv:"INT_DELTA"
        ~doc:"May be either an absolute value ($(b,6)), or an offset ($(b,-2))")
;;

let float_delta_conv =
  let parser = function
    | "" -> Error "empty delta"
    | s when s.[0] = '+' || s.[0] = '-' ->
      (match float_of_string_opt s with
       | Some n -> Ok (Delta.Rel n)
       | None -> Error (Printf.sprintf "bad float delta: %s" s))
    | s ->
      (match float_of_string_opt s with
       | Some n -> Ok (Delta.Abs n)
       | None -> Error (Printf.sprintf "bad float: %s" s))
  in
  let pp ppf = function
    | Delta.Abs n -> Format.fprintf ppf "%f" n
    | Rel n -> Format.fprintf ppf "%+f" n
  in
  Arg.Conv.make ~docv:"DELTA" ~parser ~pp ()
;;

let float_delta =
  Arg.(
    required
    & pos 0 (some float_delta_conv) None
    & info
        []
        ~docv:"FLOAT_DELTA"
        ~doc:"May be either an absolute value ($(b,0.55)), or an offset ($(b,-0.05))")
;;

let tag_arg_conv =
  let parser s =
    let s = String.trim s in
    match s with
    | "occupied" -> Ok Tag.Arg.Occupied
    | s -> Result.map (fun t -> Tag.Arg.Concrete t) (Tag.Set.of_string s)
  in
  let pp ppf = function
    | Tag.Arg.Occupied -> Format.fprintf ppf "occupied"
    | Tag.Arg.Concrete t -> Format.fprintf ppf "%s" (Tag.Set.to_string t)
  in
  Arg.Conv.make ~docv:"TAGS" ~parser ~pp ()
;;

let tag_shared_doc =
  "Tags are numbered 1 to 32. They may be named directly as indices: a single tag \
   ($(b,7)), a comma-separated list ($(b,1,3,8)), or a range ($(b,1-3,5)). They may also \
   be given as a bitmask in hexadecimal ($(b,0xff)), binary ($(b,0b101)), or octal \
   ($(b,0o17)), where each set bit selects one tag. Note that $(b,7) means tag 7, while \
   $(b,0b111) means tags 1, 2, and 3."
;;

let tag_arg_at i =
  let doc =
    tag_shared_doc
    ^ " The string literal $(i,occupied) is allowed and represents all currently \
       occupied tags."
  in
  Arg.(required & pos i (some tag_arg_conv) None & info [] ~docv:"TAGS" ~doc)
;;

let tag_arg = tag_arg_at 0

let tag_set_conv =
  let parser = Tag.Set.of_string in
  let pp ppf t = Format.fprintf ppf "%s" @@ Tag.Set.to_string t in
  Arg.Conv.make ~docv:"TAGS" ~parser ~pp ()
;;

let tag_set =
  let doc = tag_shared_doc in
  Arg.(required & pos 0 (some tag_set_conv) None & info [] ~docv:"TAGS" ~doc)
;;

let occupied_flag =
  Arg.(value & flag & info [ "occupied" ] ~doc:"Restrict operation to occupied tags")
;;

let policy_flag =
  Arg.(
    value
    & vflag
        Tag.Policy.Keep
        [ ( Tag.Policy.Take
          , info [ "take" ] ~doc:"Window takes the active tags on the destination output"
          )
        ])
;;

let app_id_flag =
  Arg.(
    value
    & opt (some string) None
    & info [ "app-id" ] ~docv:"REGEX" ~doc:"Match REGEX against the window's app-id")
;;

let title_flag =
  Arg.(
    value
    & opt (some string) None
    & info [ "title" ] ~docv:"REGEX" ~doc:"Match REGEX against the window's title")
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

let extent_conv =
  let parser = Extent.of_string in
  let pp ppf e = Format.fprintf ppf "%s" @@ Extent.to_string e in
  Arg.Conv.make ~docv:"EXTENT" ~parser ~pp ()
;;

let keybind_arg =
  let open Cmdliner in
  Arg.(
    required
    & pos ~rev:true 0 (some string) None
    & info
        []
        ~docv:"KEYBIND"
        ~doc:
          "Modifiers, keysym, and/or button. Modifiers include Shift, Control, Mod1/Alt, \
           Mod3, Mod4/Super/Logo, Mod5, or None. Keysyms mirror xkbcommon-keysym.h \
           without the 'K_' prefix, (e.g. Return instead of K_Return). Buttons are \
           prefixed with 'Btn_' followed by [0-9], left, right, middle, side, extra, \
           forward, back, or task.")
;;

let mode_flag =
  let open Cmdliner in
  Arg.(
    value
    & opt (some string) None
    & info
        [ "mode" ]
        ~docv:"MODE"
        ~doc:"The keymap mode the binding belongs to (default $(b,normal)).")
;;

let color_arg_conv =
  let parser = Color.of_string in
  let pp ppf c = Color.to_string c |> Format.fprintf ppf "%s" in
  Arg.Conv.make ~docv:"COLOR" ~parser ~pp ()
;;

let color_arg =
  Arg.(
    required
    & pos 0 (some color_arg_conv) None
    & info
        []
        ~docv:"COLOR"
        ~doc:
          "An RGBA or RGB color string. The following are equivalent: $(i,7FB4CAFF) \
           $(i,7FB4CA). May be prefixed with $(i,#) or $(i,0x).")
;;

let window_query_pattern_arg =
  Arg.(
    required
    & pos 0 (some string) None
    & info [] ~docv:"STRING" ~doc:"Match windows containing STRING in their title/app-id")
;;

let window_query_field_flag =
  let open Ocdwm_core.Window_query in
  Arg.(
    value
    & vflag
        Field.Any
        [ Field.Title, info [ "title" ] ~doc:"Match against window title only"
        ; Field.App_id, info [ "app-id" ] ~doc:"Match againts app-id only"
        ])
;;

let window_query_regex_flag =
  Arg.(
    value
    & flag
    & info [ "regex" ] ~doc:"Interpret the search string as a regular expression")
;;

let code_protocol_err = 1
let code_conn_failed = 2

let exit_protocol_err =
  Cmd.Exit.info code_protocol_err ~doc:"on protocol error from ocdwm"
;;

let exit_conn_failed =
  Cmd.Exit.info code_conn_failed ~doc:"on failure to connect to the ocdwm socket"
;;

let exits = exit_protocol_err :: exit_conn_failed :: Exit.exits

let dispatch ?seat ?socket body =
  Eio_posix.run
  @@ fun env ->
  match Client.send ~env ?seat ?socket body with
  | Ok (Some (`String s)) ->
    (Logs.app @@ fun m -> m "%s" s);
    Cmd.Exit.ok
  | Ok (Some data) ->
    (Logs.app @@ fun m -> m "%s" (Yojson.Safe.pretty_to_string data));
    Cmd.Exit.ok
  | Ok None -> Cmd.Exit.ok
  | Error (Connection_failed msg) ->
    (Logs.err @@ fun m -> m "connection failed: %s" msg);
    code_conn_failed
  | Error (Protocol msg) ->
    (Logs.err @@ fun m -> m "%s" msg);
    code_protocol_err
;;

let dispatch_stream ?socket ?output ~kinds () =
  Eio_posix.run
  @@ fun env ->
  Sys.set_signal Sys.sigpipe Sys.Signal_default;
  match
    Client.subscribe ~env ?socket ?output ~kinds (fun line ->
      print_endline line;
      flush stdout)
  with
  | Ok () -> Cmd.Exit.ok
  | Error (Connection_failed msg) ->
    (Logs.err @@ fun m -> m "connection failed: %s" msg);
    code_conn_failed
  | Error (Protocol msg) ->
    (Logs.err @@ fun m -> m "%s" msg);
    code_protocol_err
;;

let group = Cli.group

let cmd ~name ~doc term =
  let open Cmdliner.Term.Syntax in
  Cli.cmd ~exits ~name ~doc
  @@
  let+ seat = seat
  and+ socket = socket
  and+ body = term in
  dispatch ?seat ?socket body
;;

let stream_cmd ~name ~doc term =
  let open Cmdliner.Term.Syntax in
  Cli.cmd ~exits ~name ~doc
  @@
  let+ socket = socket
  and+ kinds, output = term in
  dispatch_stream ?socket ?output ~kinds ()
;;

let command_term term =
  let open Cmdliner.Term.Syntax in
  let+ command = term in
  Request.Body.Command command
;;

let bind_suffix =
  let open Cmdliner.Term.Syntax in
  let to_kw = Arg.enum [ "to", () ] in
  let+ () =
    Arg.(
      required
      & pos ~rev:true 1 (some to_kw) None
      & info [] ~docv:"to" ~doc:"Literal $(b,to) separating command from keybind")
  and+ keybind = keybind_arg in
  keybind
;;

let bind_term term =
  let open Cmdliner.Term.Syntax in
  let+ command = term
  and+ mode = mode_flag
  and+ keybind = bind_suffix in
  Request.Body.Keymap (Bind { keybind; command; mode })
;;

let query_term term =
  let open Cmdliner.Term.Syntax in
  let+ query = term in
  Request.Body.Query query
;;
