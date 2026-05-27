open Ocdwm_core

type make_target =
  { name : string
  ; ppf : (string -> string, unit, string) format
  ; dir : Direction.t
  }

let make_cmds { name; ppf; dir } =
  let window =
    Ctl_cli.cmd ~name:"window" ~doc:(Printf.sprintf ppf "window")
    @@ Ctl_cli.trigger_term (Cmdliner.Term.const (Action.Focus_window_direction dir))
  and output =
    Ctl_cli.cmd ~name:"output" ~doc:(Printf.sprintf ppf "output")
    @@ Ctl_cli.trigger_term (Cmdliner.Term.const (Action.Focus_output_direction dir))
  in
  Ctl_cli.group ~name ~doc:(Printf.sprintf ppf "window or output") [ window; output ]
;;

let make_binds { name; ppf; dir } =
  let window =
    Ctl_cli.cmd ~name:"window" ~doc:(Printf.sprintf ppf "window")
    @@ Ctl_cli.bind_term (Cmdliner.Term.const (Action.Focus_window_direction dir))
  and output =
    Ctl_cli.cmd ~name:"output" ~doc:(Printf.sprintf ppf "output")
    @@ Ctl_cli.bind_term (Cmdliner.Term.const (Action.Focus_output_direction dir))
  in
  Ctl_cli.group ~name ~doc:(Printf.sprintf ppf "window or output") [ window; output ]
;;

let targets =
  [ { name = "next"; ppf = "Focus the next %s"; dir = Next }
  ; { name = "prev"; ppf = "Focus the previous %s"; dir = Prev }
  ]
;;

let cmds = List.map make_cmds targets
let binds = List.map make_binds targets
