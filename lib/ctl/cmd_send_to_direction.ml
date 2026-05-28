open Ocdwm_core

type make_target =
  { name : string
  ; doc : string
  ; dir : Ctl_cli.Any_direction.t
  }

let action_term dir =
  let open Cmdliner.Term.Syntax in
  let open Ctl_cli.Any_direction in
  let+ policy = Ctl_cli.policy_flag in
  match dir with
  | Logical dir -> Action.Send_to_output_direction { dir; policy }
  | Spatial dir -> Action.Send_to_output_spatial { dir; policy }
;;

let make_cmd { name; doc; dir } =
  let output =
    Ctl_cli.cmd ~name:"output" ~doc @@ Ctl_cli.trigger_term @@ action_term dir
  in
  Ctl_cli.group ~name ~doc [ output ]
;;

let make_bind { name; doc; dir } =
  let output = Ctl_cli.cmd ~name:"output" ~doc @@ Ctl_cli.bind_term @@ action_term dir in
  Ctl_cli.group ~name ~doc [ output ]
;;

let targets =
  [ { name = "next"; doc = "Send to the next output"; dir = Logical Next }
  ; { name = "prev"; doc = "Send to the previous output"; dir = Logical Prev }
  ; { name = "up"; doc = "Send to the output above"; dir = Spatial Up }
  ; { name = "down"; doc = "Send to the output below"; dir = Spatial Down }
  ; { name = "left"; doc = "Send to the output to the left"; dir = Spatial Left }
  ; { name = "right"; doc = "Send to the output to the right"; dir = Spatial Right }
  ]
;;

let cmds = List.map make_cmd targets
let binds = List.map make_bind targets
