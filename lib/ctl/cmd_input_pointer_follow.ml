open! Oxbow_core
open! Oxbow_ipc

let command_term policy = Cmdliner.Term.const @@ Command.Input (Pointer (Follow policy))

let policy_targets =
  Ctl_cli.enum_of Focus_follows_policy.to_string Focus_follows_policy.all
;;

let mk_leaf (name, policy) =
  Ctl_cli.cmd_pair
    ~name
    ~doc:(Printf.sprintf "Set the focus follows pointer policy to %s" name)
  @@ command_term policy
;;

let name = "follow"
let doc = "How pointer motion changes focus"

let cycle_leaf =
  Ctl_cli.cmd_pair ~name:"cycle" ~doc:"Cycle the focus follows pointer policy"
  @@ Cmdliner.Term.const
  @@ Command.Input (Pointer Cycle_follow)
;;

let cmd, bind_cmd =
  Ctl_cli.group_pair ~name ~doc @@ (cycle_leaf :: List.map mk_leaf policy_targets)
;;
