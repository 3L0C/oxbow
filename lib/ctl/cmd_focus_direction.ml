open Ocdwm_core

type make_target =
  { name : string
  ; ppf : (string -> string, unit, string) format
  ; dir : Ctl_cli.Any_direction.t
  }

let make_cmds { name; ppf; dir } =
  let open Ctl_cli.Any_direction in
  let win_action =
    match dir with
    | Logical d -> Action.Focus_window_direction d
    | Spatial d -> Action.Focus_window_spatial d
  in
  let out_action =
    match dir with
    | Logical d -> Action.Focus_output_direction d
    | Spatial d -> Action.Focus_output_spatial d
  in
  let window =
    Ctl_cli.cmd ~name:"window" ~doc:(Printf.sprintf ppf "window")
    @@ Ctl_cli.trigger_term (Cmdliner.Term.const win_action)
  and output =
    Ctl_cli.cmd ~name:"output" ~doc:(Printf.sprintf ppf "output")
    @@ Ctl_cli.trigger_term (Cmdliner.Term.const out_action)
  in
  Ctl_cli.group ~name ~doc:(Printf.sprintf ppf "window or output") [ window; output ]
;;

let make_binds { name; ppf; dir } =
  let open Ctl_cli.Any_direction in
  let win_action =
    match dir with
    | Logical d -> Action.Focus_window_direction d
    | Spatial d -> Action.Focus_window_spatial d
  in
  let out_action =
    match dir with
    | Logical d -> Action.Focus_output_direction d
    | Spatial d -> Action.Focus_output_spatial d
  in
  let window =
    Ctl_cli.cmd ~name:"window" ~doc:(Printf.sprintf ppf "window")
    @@ Ctl_cli.bind_term (Cmdliner.Term.const win_action)
  and output =
    Ctl_cli.cmd ~name:"output" ~doc:(Printf.sprintf ppf "output")
    @@ Ctl_cli.bind_term (Cmdliner.Term.const out_action)
  in
  Ctl_cli.group ~name ~doc:(Printf.sprintf ppf "window or output") [ window; output ]
;;

let targets =
  [ { name = "next"; ppf = "Focus the next %s"; dir = Logical Next }
  ; { name = "prev"; ppf = "Focus the previous %s"; dir = Logical Prev }
  ; { name = "up"; ppf = "Focus the %s above"; dir = Spatial Up }
  ; { name = "down"; ppf = "Focus the %s below"; dir = Spatial Down }
  ; { name = "left"; ppf = "Focus the %s to the left"; dir = Spatial Left }
  ; { name = "right"; ppf = "Focus the %s to the right"; dir = Spatial Right }
  ]
;;

let cmds = List.map make_cmds targets
let binds = List.map make_binds targets
