open! Ocdwm_ipc

let docv_term = "COMMAND"
let doc_term = "The $(i,COMMAND) to execute."

let command_term =
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  let+ argv =
    Arg.(non_empty & pos_all string [] & info [] ~docv:docv_term ~doc:doc_term)
  in
  Command.Exec (Array.of_list argv)
;;

let bind_term =
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  let+ argv =
    Arg.(
      non_empty & pos_left ~rev:true 1 string [] & info [] ~docv:docv_term ~doc:doc_term)
  in
  Command.Exec (Array.of_list argv)
;;

let name = "exec"

let doc =
  "Execute $(i,COMMAND) as a shell command, e.g., $(i,/bin/emacs --eval \
   \"(scratch-buffer)\" )"
;;

let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc ~bind:bind_term command_term
