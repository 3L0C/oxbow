open! Oxbow_ipc

let name = "list"
let doc = "List the input rules"

let cmd =
  Ctl_cli.cmd ~name ~doc
  @@ Ctl_cli.query_term ~render:Ctl_cli.render_lines
  @@ Cmdliner.Term.const Query.Input_rules
;;
