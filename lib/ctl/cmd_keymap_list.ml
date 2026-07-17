open! Ocdwm_core
open! Ocdwm_ipc

let name = "list"
let doc = "List active keybindings"

let all_flag =
  Cmdliner.Arg.(value & flag & info [ "all" ] ~doc:"List keybindings for every seat")
;;

let cmd =
  let open Cmdliner.Term.Syntax in
  Ctl_cli.cmd ~name ~doc
  @@ Ctl_cli.query_term
  @@
  let+ all = all_flag in
  Query.Keymaps { all }
;;
