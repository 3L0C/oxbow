open Ocdwm_core

type make_target =
  { name : string
  ; dir : Direction.t
  }

let action_term dir =
  let open Cmdliner.Term.Syntax in
  let+ policy = Ctl_cli.policy_flag in
  Action.Send_to_output_direction { dir; policy }
;;

let make_cmd { name; dir } =
  let output =
    Ctl_cli.cmd ~name:"output" ~doc:(Printf.sprintf "Send in the %s direction" name)
    @@ Ctl_cli.trigger_term
    @@ action_term dir
  in
  Ctl_cli.group ~name ~doc:(Printf.sprintf "Send in the %s direction" name) [ output ]
;;

let make_bind { name; dir } =
  let output =
    Ctl_cli.cmd ~name:"output" ~doc:(Printf.sprintf "Send in the %s direction" name)
    @@ Ctl_cli.bind_term
    @@ action_term dir
  in
  Ctl_cli.group ~name ~doc:(Printf.sprintf "Send in the %s direction" name) [ output ]
;;

let targets = [ { name = "next"; dir = Next }; { name = "prev"; dir = Prev } ]
let cmds = List.map make_cmd targets
let binds = List.map make_bind targets
