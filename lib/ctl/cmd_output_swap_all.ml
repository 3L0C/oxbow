open! Ocdwm_core
open! Ocdwm_ipc

let command_term =
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  let+ first = Arg.(value & pos 0 (some string) None & info [] ~docv:"OUTPUT")
  and+ second = Arg.(value & pos 1 (some string) None & info [] ~docv:"OUTPUT")
  and+ policy = Ctl_cli.policy_flag in
  Command.Output (Swap_all { first; second; policy })
;;

let bind_command_term =
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  let+ outputs = Arg.(value & pos_left ~rev:true 1 string [] & info [] ~docv:"OUTPUT")
  and+ policy = Ctl_cli.policy_flag in
  let payload first second = Command.Output (Swap_all { first; second; policy }) in
  match outputs with
  | [] -> payload None None
  | [ a ] -> payload (Some a) None
  | a :: b :: _ -> payload (Some a) (Some b)
;;

let name = "all"
let doc = "Swap all windows between two outputs"
let cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.command_term command_term
let bind_cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.bind_term bind_command_term
