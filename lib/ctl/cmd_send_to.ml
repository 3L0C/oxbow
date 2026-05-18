open Ocdwm_core
open Cmdliner
open Cmdliner.Term.Syntax

let cmd =
  let term =
    let+ target =
      Arg.(
        required
        & pos 0 (some Target_arg.conv) None
        & info
            []
            ~docv:"OUTPUT"
            ~doc:
              "Destination output. Either a direction keyword ($(b,next), $(b,prev), \
               $(b,left), $(b,right), $(b,up), $(b,down)) or an output name (e.g., \
               $(b,eDP-1), $(b,HDMI-A-1), etc.).")
    and+ take_tags =
      Arg.(
        value
        & flag
        & info
            [ "selected-tags" ]
            ~doc:
              "Adopt the destination output's currently selected tags so the moved \
               window becomes visible there.")
    in
    if take_tags then Action.Send_to_output_tags target else Action.Send_to_output target
  in
  Ctl_cli.cmd_of_term
    ~name:"send-to"
    ~doc:"Send the focused window to another output"
    term
;;
