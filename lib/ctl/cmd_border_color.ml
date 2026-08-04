open! Oxbow_core
open! Oxbow_ipc

let command_term which =
  let open Cmdliner.Term.Syntax in
  let+ color = Ctl_cli.color_arg in
  Command.Border (Color { which; color })
;;

let leaves =
  [ "focused", Border_target.Focused
  ; "unfocused", Border_target.Unfocused
  ; "urgent", Border_target.Urgent
  ]
;;

let mk_leaf mk_term (name, which) =
  Ctl_cli.cmd
    ~name
    ~doc:(Printf.sprintf "Set the border color when the window state is %s" name)
  @@ mk_term
  @@ command_term which
;;

let name = "color"
let doc = "Set the window color for a given state"

let cmd, bind_cmd =
  Ctl_cli.group_pair ~name ~doc
  @@ List.map
       (fun leaf -> Ctl_cli.(mk_leaf command_term leaf, mk_leaf bind_term leaf))
       leaves
;;
