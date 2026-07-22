open! Ocdwm_ipc

let term =
  let open Cmdliner.Term.Syntax in
  let+ output = Ctl_cli.output_flag in
  Query.Schemes { output }
;;

let name = "scheme"
let doc = "Query current and available tiling schemes"
let cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.query_term term
