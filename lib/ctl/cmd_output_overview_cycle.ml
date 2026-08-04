open! Oxbow_ipc

let command_term dir =
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  let+ until_release =
    Arg.(
      value
      & opt (some string) None
      & info
          [ "until-release" ]
          ~docv:"MODS"
          ~doc:"Close the overview when $(docv) modifiers are released")
  in
  Command.Output (Cycle_overview { dir; until_release })
;;

let mk_leaf mk_term (name, dir) =
  Ctl_cli.cmd
    ~name
    ~doc:(Printf.sprintf "Move the overview selection to the %s window" name)
  @@ mk_term
  @@ command_term dir
;;

let name = "cycle"
let doc = "Cycle the overview selection through the focus stack"

let cmd, bind_cmd =
  Ctl_cli.group_pair ~name ~doc
  @@ List.map
       (fun leaf -> Ctl_cli.(mk_leaf command_term leaf, mk_leaf bind_term leaf))
       Ctl_cli.logical_targets
;;
