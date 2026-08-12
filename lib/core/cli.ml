open! Cmdliner

let log_level_conv =
  let levels =
    [ "error", Logs.Error
    ; "warning", Logs.Warning
    ; "info", Logs.Info
    ; "debug", Logs.Debug
    ]
  in
  let level_of_string s =
    List.assoc_opt s levels
    |> Option.to_result ~none:(Printf.sprintf "unknown log level: %S" s)
  in
  let parser s =
    let open Result.Syntax in
    match String.index_opt s ':' with
    | None ->
      let+ l = level_of_string s in
      None, l
    | Some i ->
      let src = String.sub s 0 i in
      let lvl = String.sub s (i + 1) (String.length s - i - 1) in
      let+ l = level_of_string lvl in
      Some src, l
  in
  let pp ppf (src, l) =
    match src with
    | None -> Format.fprintf ppf "%s" (Logs.level_to_string (Some l))
    | Some src -> Format.fprintf ppf "%s:%s" src (Logs.level_to_string (Some l))
  in
  Cmdliner.Arg.Conv.make ~docv:"[SRC:]LEVEL" ~parser ~pp ()
;;

let log_level_arg =
  Arg.(
    value
    & opt_all log_level_conv []
    & info
        [ "log-level" ]
        ~docv:"[SRC:]LEVEL"
        ~doc:
          "Set the log level to one of $(b,error), $(b,warning), $(b,info), or \
           $(b,debug), globally or for one source as $(b,SRC:LEVEL) (list sources with \
           $(b,oxbow.runtime), $(b,oxbow.state), $(b,oxbow.ops), $(b,oxbow.wire), \
           $(b,oxbow.core)). Repeatable; the last flag wins.")
;;

let socket_arg =
  Arg.(
    value
    & opt (some string) None
    & info
        [ "socket" ]
        ~docv:"PATH"
        ~docs:Manpage.s_common_options
        ~doc:"Override $(b,XDG_RUNTIME_DIR) socket path.")
;;

let info ?(exits = Exit.exits) ?man ?man_xrefs ?version name ~doc =
  Cmd.info ?man ?man_xrefs ?version name ~doc ~exits
;;

let help_term = Term.(ret (const (`Help (`Auto, None))))

let group ?exits ?man ?man_xrefs ?version ?default ~name ~doc =
  Cmd.group (info ?exits ?man ?man_xrefs ?version name ~doc) ?default
;;

let cmd ?exits ?man ?man_xrefs ?version ~name ~doc =
  Cmd.v (info ?exits ?man ?man_xrefs ?version name ~doc)
;;
