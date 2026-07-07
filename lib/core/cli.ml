open Cmdliner

let log_level_arg =
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  let levels =
    [ "error", Logs.Error
    ; "warning", Logs.Warning
    ; "info", Logs.Info
    ; "debug", Logs.Debug
    ]
  in
  Arg.(
    value
    & opt (enum levels) Logs.Debug
    & info
        [ "log-level" ]
        ~docv:"LOG_LEVEL"
        ~doc:
          "Set the log level to one of $(b,error), $(b,warning), $(b,info), or \
           $(b,debug).")
;;

let info ?(exits = Exit.exits) ?man ?man_xrefs ?version name ~doc =
  Cmd.info ?man ?man_xrefs ?version name ~doc ~exits
;;

let group ?man ?man_xrefs ?version ~name ~doc =
  let default = Term.(ret (const (`Help (`Auto, None)))) in
  Cmd.group (info ?man ?man_xrefs ?version name ~doc) ~default
;;

let cmd ?exits ?man ?man_xrefs ?version ~name ~doc =
  Cmd.v (info ?exits ?man ?man_xrefs ?version name ~doc)
;;
