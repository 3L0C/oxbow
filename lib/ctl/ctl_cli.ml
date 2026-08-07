open! Cmdliner
open! Oxbow_core
open! Oxbow_ipc

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

let socket = Cli.socket_arg
let enum_of to_string l = List.map (fun x -> to_string x, x) l
let spatial_targets = enum_of Direction.Spatial.to_string [ Up; Down; Left; Right ]
let logical_targets = enum_of Direction.Logical.to_string [ Next; Prev ]

let logical_leaves ~next ~prev =
  List.map
    (fun (name, (d : Oxbow_core.Direction.Logical.t)) ->
       ( name
       , (match d with
          | Next -> next
          | Prev -> prev)
       , d ))
    logical_targets
;;

let direction_targets =
  let open Direction in
  List.map (fun (s, d) -> s, Logical d) logical_targets
  @ List.map (fun (s, d) -> s, Spatial d) spatial_targets
;;

let delta_conv of_string pp =
  let parser = function
    | "" -> Error "empty delta"
    | s when s.[0] = '+' || s.[0] = '-' ->
      (match of_string s with
       | Some n -> Ok (Delta.Rel n)
       | None -> Error (Printf.sprintf "bad delta: %s" s))
    | s ->
      (match of_string s with
       | Some n -> Ok (Delta.Abs n)
       | None -> Error (Printf.sprintf "bad value: %s" s))
  in
  Arg.Conv.make ~docv:"DELTA" ~parser ~pp ()
;;

let int_delta_conv =
  let pp ppf = function
    | Delta.Abs n -> Format.fprintf ppf "%d" n
    | Rel n -> Format.fprintf ppf "%+d" n
  in
  delta_conv int_of_string_opt pp
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
  let pp ppf = function
    | Delta.Abs n -> Format.fprintf ppf "%f" n
    | Rel n -> Format.fprintf ppf "%+f" n
  in
  delta_conv float_of_string_opt pp
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

let tag_arg =
  let doc =
    tag_shared_doc
    ^ " The string literal $(i,occupied) is allowed and represents all currently \
       occupied tags."
  in
  Arg.(required & pos 0 (some tag_arg_conv) None & info [] ~docv:"TAGS" ~doc)
;;

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

let swap_terms mk =
  let term target_t =
    let open Cmdliner.Term.Syntax in
    let+ target = target_t
    and+ policy = policy_flag
    and+ follow = follow_flag in
    mk ~target ~policy ~follow
  in
  term swap_target, term bind_swap_target
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

let label_flag =
  Arg.(
    value
    & opt (some string) None
    & info
        [ "label" ]
        ~docv:"REGEX"
        ~doc:"Match REGEX against each of the window's labels.")
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

let device_pattern_arg =
  Arg.(
    value
    & opt (some string) None
    & info
        [ "name" ]
        ~docv:"REGEX"
        ~doc:"Match $(docv), a PCRE regex, against the device name.")
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

let output_query mk =
  let open Cmdliner.Term.Syntax in
  let+ output = output_flag in
  mk output
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

let mode_name_arg =
  Arg.(required & pos 0 (some string) None & info [] ~docv:"MODE" ~doc:"The mode name")
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

let index_arg =
  Arg.(
    required
    & pos 0 (some int) None
    & info [] ~docv:"INDEX" ~doc:"The rule index from the $(b,list) output.")
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

let pattern_flags =
  let open Oxbow_core in
  let open Cmdliner.Term.Syntax in
  let+ title = title_flag
  and+ app_id = app_id_flag
  and+ identifier = identifier_flag
  and+ label = label_flag
  and+ case = case_flag in
  ({ title; app_id; identifier; label; case } : Pattern.t)
;;

let pattern_term =
  let open Oxbow_core in
  let open Cmdliner.Term.Syntax in
  Cmdliner.Term.term_result' ~usage:true
  @@ let+ p = pattern_flags in
     if Pattern.is_empty p
     then Error "give at least one of --title, --app-id, --identifier, or --label"
     else Ok p
;;

let scope_term =
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

let setting_scope_term =
  let open Cmdliner.Term.Syntax in
  Cmdliner.Term.term_result' ~usage:true
  @@ let+ all =
       Arg.(
         value
         & flag
         & info
             [ "all" ]
             ~doc:
               "Apply the change to every tag on every output. The value becomes the \
                default for new outputs and tags.")
     and+ output = output_flag in
     match all, output with
     | true, Some _ -> Error "--all takes no --output"
     | true, None -> Ok Scope.All
     | false, Some name -> Ok (Scope.Output name)
     | false, None -> Ok Scope.Focused
;;

let window_match_of source =
  let open Oxbow_core in
  let open Cmdliner.Term.Syntax in
  let+ pattern = source
  and+ invert = invert_flag
  and+ scope = scope_term in
  ({ pattern; invert; scope } : Window_match.t)
;;

let window_match_term = window_match_of pattern_term
let window_match_any_term = window_match_of pattern_flags

let all_flag =
  Arg.(value & flag & info [ "all" ] ~doc:"Act on every match, not only the best match.")
;;

let target_window_term =
  let open Oxbow_core in
  let open Cmdliner.Term.Syntax in
  Cmdliner.Term.term_result' ~usage:true
  @@ let+ wmatch = window_match_any_term
     and+ all = all_flag in
     if Pattern.is_empty wmatch.pattern
     then if all then Error "--all needs a pattern" else Ok (Focused : Target.Window.t)
     else Ok (Matching { wmatch; all })
;;

let tags_flag =
  Arg.(
    value
    & opt (some tag_arg_conv) None
    & info [ "tags" ] ~docv:"TAGS" ~doc:"Set TAGS on the matching windows.")
;;

let presentation_flag =
  let open Oxbow_core.Window_rule.Effects.Presentation in
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

let extent_pos i ~docv ~doc =
  Arg.(required & pos i (some extent_conv) None & info [] ~docv ~doc)
;;

let resize_to_flag =
  let open Oxbow_core.Window_rule.Effects in
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
  let open Oxbow_core.Window_rule.Effects in
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

let mk_enum name ~doc ~docv l =
  let open Cmdliner in
  let doc = Printf.sprintf "%s The value is %s" doc (Arg.doc_alts_enum l) in
  Arg.(value & opt (some (enum l)) None & info [ name ] ~docv ~doc)
;;

let bool_state = Cmdliner.Arg.enum [ "enabled", true; "disabled", false ]

let bool_state_arg name ~doc ~docv =
  Arg.(value & opt (some bool_state) None & info [ name ] ~docv ~doc)
;;

let accel_profile_arg =
  mk_enum "accel-profile" ~doc:"Set the pointer acceleration profile." ~docv:"PROFILE"
  @@ enum_of Input_rule.Accel_profile.to_string [ None; Flat; Adaptive; Custom ]
;;

let accel_speed_arg =
  Arg.(
    value
    & opt (some float) None
    & info
        [ "accel-speed" ]
        ~docv:"SPEED"
        ~doc:"Set the pointer acceleration speed. The range is -1.0 to 1.0.")
;;

let button_map_arg name ~doc =
  mk_enum name ~doc ~docv:"BUTTON" @@ enum_of Input_rule.Button_map.to_string [ Lrm; Lmr ]
;;

let drag_lock_arg =
  mk_enum "drag-lock" ~doc:"Set the drag lock mode for tap-and-drag." ~docv:"OPTION"
  @@ enum_of Input_rule.Drag_lock.to_string [ Disabled; Enabled_timeout; Enabled_sticky ]
;;

let three_finger_drag_arg =
  mk_enum
    "three-finger-drag"
    ~doc:"Set the drag gesture with three or four fingers."
    ~docv:"OPTION"
  @@ enum_of Input_rule.Three_finger_drag.to_string [ Disabled; Enabled_3fg; Enabled_4fg ]
;;

let click_method_arg =
  mk_enum "click-method" ~doc:"Set the click method of the touchpad." ~docv:"METHOD"
  @@ enum_of Input_rule.Click_method.to_string [ None; Button_areas; Clickfinger ]
;;

let natural_scroll_arg =
  bool_state_arg
    "natural-scroll"
    ~doc:"Enable or disable the natural scroll direction."
    ~docv:"OPTION"
;;

let left_handed_arg =
  bool_state_arg
    "left-handed"
    ~doc:"Enable or disable the left-handed button layout."
    ~docv:"OPTION"
;;

let middle_emulation_arg =
  bool_state_arg
    "middle-emulation"
    ~doc:"Enable or disable middle-button emulation."
    ~docv:"OPTION"
;;

let scroll_factor_arg =
  Arg.(
    value
    & opt (some float) None
    & info
        [ "scroll-factor" ]
        ~docv:"FACTOR"
        ~doc:"Multiply the scroll distance by $(docv).")
;;

let scroll_method_arg =
  mk_enum "scroll-method" ~doc:"Set the scroll method of the device." ~docv:"METHOD"
  @@ enum_of
       Input_rule.Scroll_method.to_string
       [ No_scroll; Two_finger; Edge; On_button_down ]
;;

let scroll_button_arg =
  mk_enum
    "scroll-button"
    ~doc:"Set the button that starts on-button-down scroll."
    ~docv:"BUTTON"
  @@ enum_of Pointer_button.to_string Pointer_button.all
;;

let send_events_arg =
  mk_enum "send-events" ~doc:"Set the send-events mode of the device." ~docv:"OPTION"
  @@ enum_of
       Input_rule.Send_events.to_string
       [ Enabled; Disabled; Disabled_on_external_mouse ]
;;

let sticky_arg =
  mk_enum "sticky" ~doc:"Set the sticky state of the window." ~docv:"OPTION"
  @@ enum_of Sticky.to_string Sticky.all
;;

let label_conv =
  let parser = function
    | "" -> Error "label must not be empty"
    | s -> Ok s
  in
  Arg.Conv.make ~docv:"LABEL" ~parser ~pp:Format.pp_print_string ()
;;

let label_arg =
  let open Cmdliner in
  Arg.(required & pos 0 (some label_conv) None & info [] ~doc:"The label")
;;

let swallow_arg =
  mk_enum "swallow" ~doc:"Set the swallow role of the window." ~docv:"ROLE"
  @@ enum_of Swallow_role.to_string Swallow_role.all
;;

let code_protocol_err = 1
let code_conn_failed = 2
let exit_success = Cmd.Exit.info 0 ~doc:"on success"

let exit_protocol_err =
  Cmd.Exit.info code_protocol_err ~doc:"on protocol error from oxbow"
;;

let exit_conn_failed =
  Cmd.Exit.info code_conn_failed ~doc:"on failure to connect to the oxbow socket"
;;

let exits = [ exit_success; exit_protocol_err; exit_conn_failed ]
let json_flag = Arg.(value & flag & info [ "json" ] ~doc:"Print the raw JSON reply.")

let render_lines (json : Yojson.Safe.t) =
  let rec flat (j : Yojson.Safe.t) =
    match j with
    | `Assoc fields ->
      List.map (fun (key, value) -> Printf.sprintf "%s=%s" key (flat value)) fields
      |> String.concat " "
    | `List [ `String tag; payload ] -> tag ^ " " ^ flat payload
    | `List [ `String tag ] | `String tag -> tag
    | `List items -> List.map flat items |> String.concat ","
    | `Bool _ | `Int _ | `Intlit _ | `Float _ | `Null -> Yojson.Safe.to_string j
  in
  match json with
  | `List items ->
    List.mapi (fun i item -> Printf.sprintf "%d: %s" i (flat item)) items
    |> String.concat "\n"
  | _ -> Yojson.Safe.to_string json
;;

let dispatch_command ?render ?seat ?socket body =
  Eio_posix.run
  @@ fun env ->
  match Client.send ~env ?seat ?socket body with
  | Ok (Some (`String s)) ->
    (Logs.app @@ fun m -> m "%s" s);
    Cmd.Exit.ok
  | Ok (Some data) ->
    let text =
      match render with
      | None -> Yojson.Safe.to_string data
      | Some render -> render data
    in
    (Logs.app @@ fun m -> m "%s" text);
    Cmd.Exit.ok
  | Ok None -> Cmd.Exit.ok
  | Error (Connection_failed msg) ->
    (Logs.err @@ fun m -> m "connection failed: %s" msg);
    code_conn_failed
  | Error (Protocol msg) ->
    (Logs.err @@ fun m -> m "%s" msg);
    code_protocol_err
;;

let dispatch_command_ref = ref dispatch_command

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

let dispatch_stream_ref = ref dispatch_stream
let group ?(exits = exits) = Cli.group ~exits

let run_term term =
  let open Cmdliner.Term.Syntax in
  let+ seat = seat
  and+ socket = socket
  and+ body, render = term in
  !dispatch_command_ref ?render ?seat ?socket body
;;

let cmd ~name ~doc term = Cli.cmd ~exits ~name ~doc (run_term term)

let stream_cmd ~name ~doc term =
  let open Cmdliner.Term.Syntax in
  Cli.cmd ~exits ~name ~doc
  @@
  let+ socket = socket
  and+ kinds, output = term in
  !dispatch_stream_ref ?socket ?output ~kinds ()
;;

let command_term term =
  let open Cmdliner.Term.Syntax in
  let+ command = term in
  Request.Body.Command command, None
;;

let bind_to_kw =
  let to_kw = Arg.enum [ "to", () ] in
  Arg.(
    required
    & pos ~rev:true 1 (some to_kw) None
    & info [] ~docv:"to" ~doc:"Literal $(b,to) separating command from keybind")
;;

let bind_suffix =
  let open Cmdliner.Term.Syntax in
  let+ () = bind_to_kw
  and+ keybind = keybind_arg in
  keybind
;;

let bind_term term =
  let open Cmdliner.Term.Syntax in
  let+ command = term
  and+ mode = mode_flag
  and+ keybind = bind_suffix in
  Request.Body.Keymap (Bind { keybind; command; mode }), None
;;

let bind_to_term term =
  let open Cmdliner.Term.Syntax in
  let t =
    let+ command = term
    and+ mode = mode_flag
    and+ keybind = keybind_arg in
    Request.Body.Keymap (Bind { keybind; command; mode }), None
  in
  cmd ~name:"to" ~doc:"Bind this command to $(i,KEYBIND)" t
;;

let cmd_pair ?bind ~name ~doc term =
  let bind = Option.value bind ~default:term in
  cmd ~name ~doc (command_term term), cmd ~name ~doc (bind_term bind)
;;

let group_pair ?(extra = []) ?default ~name ~doc pairs =
  let cmds, binds = List.split pairs in
  let mk mk_term children =
    group
      ~name
      ~doc
      ?default:(Option.map (fun t -> run_term (mk_term t)) default)
      children
  in
  let to_child =
    match default with
    | None -> []
    | Some t -> [ bind_to_term t ]
  in
  mk command_term (cmds @ extra), mk bind_term (binds @ to_child)
;;

let query_term ?render term =
  let open Cmdliner.Term.Syntax in
  let+ json = json_flag
  and+ query = term in
  Request.Body.Query query, if json then None else render
;;

let const_leaves l =
  List.map (fun (name, doc, c) -> cmd_pair ~name ~doc (Cmdliner.Term.const c)) l
;;
