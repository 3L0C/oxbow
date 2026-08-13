open! Oxbow_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ seed =
    Ctl_cli.extent_pos
      0
      ~docv:"SEED"
      ~doc:
        "The size used when a window becomes floating and has no remembered placement. A \
         pixel value (e.g., $(b,800)) or a percentage of the usable area (e.g., \
         $(b,50%)). The value applies to both dimensions. The window is centered. "
  and+ scope = Ctl_cli.setting_scope_term in
  Command.Layout (Floating (Seed { seed; scope }))
;;

let name = "seed"
let doc = "Set the floating seed of the output"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
