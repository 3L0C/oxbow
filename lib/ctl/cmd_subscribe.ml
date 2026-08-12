open! Oxbow_ipc

let kind_conv = Cmdliner.Arg.enum @@ Ctl_cli.enum_of Record.to_string Record.all

let term =
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  let+ kind =
    Arg.(
      value
      & pos_all kind_conv []
      & info
          []
          ~docv:"KIND"
          ~doc:
            "Event kinds to stream (default: all). Available: tags, window, layout, \
             mode, focus, and output")
  and+ output =
    Arg.(
      value
      & opt (some string) None
      & info
          [ "output" ]
          ~docv:"NAME"
          ~doc:
            "Only stream output-keyed events for output $(docv); mode events pass through")
  in
  kind, output
;;

let name = "subscribe"
let doc = "Stream state-change events as JSON lines"
let cmd = Ctl_cli.stream_cmd ~name ~doc term
