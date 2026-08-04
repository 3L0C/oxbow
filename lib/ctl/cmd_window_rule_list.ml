open! Oxbow_ipc

let name = "list"
let doc = "List the window rules"

let cmd =
  Ctl_cli.cmd ~name ~doc
  @@ Ctl_cli.query_term ~render:Ctl_cli.render_lines
  @@ Cmdliner.Term.const Query.Window_rules
;;
