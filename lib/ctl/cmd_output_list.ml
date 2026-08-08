open! Oxbow_ipc

let name = "list"
let doc = "List all the active outputs"

let cmd =
  Ctl_cli.cmd ~name ~doc
  @@ Ctl_cli.query_term ~render:Ctl_cli.render_lines
  @@ Cmdliner.Term.const Query.Outputs
;;
