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
  Arg.(value & flag & info [ "occupied" ] ~doc:"Restrict operation to occupied tags.")
;;

let policy_flag =
  Arg.(
    value
    & vflag
        Tag.Policy.Keep
        [ ( Tag.Policy.Take
          , info [ "take" ] ~doc:"Window takes the active tags on the destination output."
          )
        ])
;;

let follow_flag =
  Arg.(value & flag & info [ "follow" ] ~doc:"Move focus with the manipulated object")
;;

let ring_flag =
  Arg.(
    value
    & opt (some (list string)) None
    & info
        [ "ring" ]
        ~docv:"OUTPUTS"
        ~doc:"Swap around the ring of comma-separated $(docv).")
;;

let rev_flag =
  Arg.(value & flag & info [ "rev" ] ~doc:"Go around the ring in the reverse direction.")
;;

let swap_target =
  let open Cmdliner.Term.Syntax in
  Cmdliner.Term.term_result' ~usage:true
  @@ let+ first = Arg.(value & pos 0 (some string) None & info [] ~docv:"OUTPUT")
     and+ second = Arg.(value & pos 1 (some string) None & info [] ~docv:"OUTPUT")
     and+ ring = ring_flag
     and+ rev = rev_flag in
     match ring, first, rev with
     | Some members, None, _ -> Ok (Command.Output.Swap.Target.Ring { members; rev })
     | Some _, Some _, _ -> Error "--ring takes no OUTPUT positional"
     | None, _, true -> Error "--rev needs --ring"
     | None, _, false -> Ok (Command.Output.Swap.Target.Pair { first; second })
;;

let bind_swap_target =
  let open Cmdliner.Term.Syntax in
  Cmdliner.Term.term_result' ~usage:true
  @@ let+ outputs = Arg.(value & pos_left ~rev:true 1 string [] & info [] ~docv:"OUTPUT")
     and+ ring = ring_flag
     and+ rev = rev_flag in
     let pair first second = Command.Output.Swap.Target.Pair { first; second } in
     match ring, outputs, rev with
     | Some members, [], rev -> Ok (Command.Output.Swap.Target.Ring { members; rev })
     | Some _, _ :: _, _ -> Error "--ring takes no OUTPUT positional"
     | None, _, true -> Error "--rev needs --ring"
     | None, [], false -> Ok (pair None None)
     | None, [ a ], false -> Ok (pair (Some a) None)
     | None, a :: b :: _, false -> Ok (pair (Some a) (Some b))
;;

let app_id_flag =
  Arg.(
    value
    & opt (some string) None
    & info [ "app-id" ] ~docv:"REGEX" ~doc:"Match REGEX against the window's app-id.")
;;

let title_flag =
  Arg.(
    value
    & opt (some string) None
    & info [ "title" ] ~docv:"REGEX" ~doc:"Match REGEX against the window's title.")
;;

let identifier_flag =
  Arg.(
    value
    & opt (some string) None
    & info
        [ "identifier" ]
        ~docv:"REGEX"
        ~doc:"Match REGEX against the window's identifier.")
;;

let case_flag =
  Arg.(
    value
    & vflag
        Pattern.Case.Sensitive
        [ ( Pattern.Case.Insensitive
          , info [ "i"; "ignore-case" ] ~doc:"Match $(i,PATTERN) case-insensitively." )
        ])
;;

let invert_flag =
  Arg.(value & flag & info [ "invert" ] ~doc:"Select the windows that do not match.")
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

let output_flag =
  Arg.(
    value
    & opt (some string) None
    & info [ "output" ] ~docv:"NAME" ~doc:"Filter to outputs matching $(i,NAME).")
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

let warp_flag =
  Arg.(
    value
    & vflag
        None
        [ ( Some true
          , info
              [ "warp" ]
              ~doc:
                "Warp the pointer after the focus change. This overrides the warp on \
                 focus configuration." )
        ; ( Some false
          , info
              [ "no-warp" ]
              ~doc:
                "Do not warp the pointer after the focus change. This overrides the warp \
                 on focus configuration." )
        ])
;;

let global_flag =
  Arg.(value & flag & info [ "all" ] ~doc:"Applies the change to all tags")
;;

let pattern_flags =
  let open Ocdwm_core in
  let open Cmdliner.Term.Syntax in
  let+ title = title_flag
  and+ app_id = app_id_flag
  and+ identifier = identifier_flag
  and+ case = case_flag in
  ({ title; app_id; identifier; case } : Pattern.t)
;;

let pattern_term =
  let open Ocdwm_core in
  let open Cmdliner.Term.Syntax in
  Cmdliner.Term.term_result' ~usage:true
  @@ let+ p = pattern_flags in
     if Pattern.is_empty p
     then Error "give at least one of --title, --app-id, or --identifier"
     else Ok p
;;

let scope_term =
  let open Ocdwm_core.Window_match in
  let open Cmdliner.Term.Syntax in
  Cmdliner.Term.term_result' ~usage:true
  @@ let+ focused =
       Arg.(value & flag & info [ "focused" ] ~doc:"Search the focused output only.")
     and+ output = output_flag in
     match focused, output with
     | true, Some _ -> Error "--focused takes no --output"
     | true, None -> Ok Scope.Focused
     | false, Some name -> Ok (Scope.Output name)
     | false, None -> Ok Scope.All
;;

let window_match_of source =
  let open Ocdwm_core in
  let open Cmdliner.Term.Syntax in
  let+ pattern = source
  and+ invert = invert_flag
  and+ scope = scope_term in
  ({ pattern; invert; scope } : Window_match.t)
;;

let window_match_term = window_match_of pattern_term
let window_match_any_term = window_match_of pattern_flags

let tags_flag =
  Arg.(
    value
    & opt (some tag_arg_conv) None
    & info [ "tags" ] ~docv:"TAGS" ~doc:"Set TAGS on the matching windows.")
;;

let presentation_flag =
  let open Ocdwm_core.Rule.Effects.Presentation in
  Arg.(
    value
    & vflag
        None
        [ Some Float, info [ "float" ] ~doc:"Manage the window floating."
        ; Some Tile, info [ "tile" ] ~doc:"Manage the window tiled."
        ; Some Fullscreen, info [ "fullscreen" ] ~doc:"Manage the window fullscreen."
        ; Some Windowed, info [ "windowed" ] ~doc:"Exit fullscreen."
        ; Some Maximize, info [ "maximize" ] ~doc:"Manage the window maximized."
        ; Some Fake_fullscreen, info [ "fake-fullscreen" ] ~doc:"Fake fullscreen."
        ])
;;

let extent_pair name ~docv ~doc =
  Arg.(value & opt (some (list extent_conv)) None & info [ name ] ~docv ~doc)
;;

let resize_to_flag =
  let open Ocdwm_core.Rule.Effects in
  let open Cmdliner.Term.Syntax in
  Cmdliner.Term.term_result' ~usage:true
  @@ let+ pair =
       extent_pair
         "resize-to"
         ~docv:"W,H"
         ~doc:
           "Resize the matching windows to $(i,W) and $(i,H). Each half is a pixel size \
            (e.g. $(b,800)) or a percentage of the usable area (e.g. $(b,50%))."
     in
     match pair with
     | None -> Ok None
     | Some [ w; h ] -> Ok (Some ({ w; h } : Resize_to.t))
     | Some _ -> Error "--resize-to takes two values: W,H"
;;

let move_to_flag =
  let open Ocdwm_core.Rule.Effects in
  let open Cmdliner.Term.Syntax in
  Cmdliner.Term.term_result' ~usage:true
  @@ let+ pair =
       extent_pair
         "move-to"
         ~docv:"X,Y"
         ~doc:
           "Move the matching windows to $(i,X) and $(i,Y). Each half is a pixel size \
            (e.g. $(b,800)) or a percentage of the usable area (e.g. $(b,50%))."
     in
     match pair with
     | None -> Ok None
     | Some [ x; y ] -> Ok (Some ({ x; y } : Move_to.t))
     | Some _ -> Error "--move-to takes two values: X,Y"
;;

let code_protocol_err = 1
let code_conn_failed = 2
let exit_success = Cmd.Exit.info 0 ~doc:"on success"

let exit_protocol_err =
  Cmd.Exit.info code_protocol_err ~doc:"on protocol error from ocdwm"
;;

let exit_conn_failed =
  Cmd.Exit.info code_conn_failed ~doc:"on failure to connect to the ocdwm socket"
;;

let exits = [ exit_success; exit_protocol_err; exit_conn_failed ]

let dispatch ?seat ?socket body =
  Eio_posix.run
  @@ fun env ->
  match Client.send ~env ?seat ?socket body with
  | Ok (Some (`String s)) ->
    (Logs.app @@ fun m -> m "%s" s);
    Cmd.Exit.ok
  | Ok (Some data) ->
    (Logs.app @@ fun m -> m "%s" (Yojson.Safe.to_string data));
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

let group ?(exits = exits) = Cli.group ~exits

let run_term term =
  let open Cmdliner.Term.Syntax in
  let+ seat = seat
  and+ socket = socket
  and+ body = term in
  dispatch ?seat ?socket body
;;

let cmd ~name ~doc term = Cli.cmd ~exits ~name ~doc (run_term term)

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
