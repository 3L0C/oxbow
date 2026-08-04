open! Oxbow_ipc

let query_term = Ctl_cli.output_query (fun output -> Query.Layouts { output })
let name = "query"
let doc = "Query current and available layouts"
let cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.query_term query_term
