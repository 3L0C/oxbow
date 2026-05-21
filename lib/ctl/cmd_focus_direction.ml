open Ocdwm_core

let make ~name ~ppf ~dir =
  let window =
    Ctl_cli.cmd
      ~name:"window"
      ~doc:(Printf.sprintf ppf "window")
      (Action.Focus_window_direction dir)
  and output =
    Ctl_cli.cmd
      ~name:"output"
      ~doc:(Printf.sprintf ppf "output")
      (Action.Focus_output_direction dir)
  in
  Ctl_cli.group ~name ~doc:(Printf.sprintf ppf "window or output") [ window; output ]
;;

let next = make ~name:"next" ~ppf:"Focus the next %s" ~dir:Dir_next
let prev = make ~name:"prev" ~ppf:"Focus the previous %s" ~dir:Dir_prev
let left = make ~name:"left" ~ppf:"Focus the %s to the left" ~dir:Dir_left
let right = make ~name:"right" ~ppf:"Focus the %s to the right" ~dir:Dir_right
let up = make ~name:"up" ~ppf:"Focus the %s above" ~dir:Dir_up
let down = make ~name:"down" ~ppf:"Focus the %s below" ~dir:Dir_down
let cmds = [ next; prev; left; right; up; down ]
