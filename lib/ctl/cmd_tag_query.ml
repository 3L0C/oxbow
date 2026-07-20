open! Ocdwm_ipc

let term =
  let open Cmdliner.Term.Syntax in
  let+ output = Ctl_cli.output_flag in
  Query.Tags { output }
;;

let name = "query"
let doc = "Query the tag state of output"
let cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.query_term term
