open Ocdwm_core
open Cmdliner
open Cmdliner.Term.Syntax

let output_target : Output_target.t Arg.Conv.t =
  let open Direction in
  let open Output_target in
  let dirs =
    [ "next", Dir_next
    ; "prev", Dir_prev
    ; "left", Dir_left
    ; "right", Dir_right
    ; "up", Dir_up
    ; "down", Dir_down
    ]
  in
  let parser s =
    match List.assoc_opt s dirs with
    | Some d -> Ok (Out_direction d)
    | None -> Ok (Out_name s)
  in
  let pp ppf = function
    | Out_direction d -> Format.fprintf ppf "%s" (Direction.to_string d)
    | Out_name n -> Format.fprintf ppf "%s" n
  in
  Arg.Conv.make ~docv:"OUTPUT" ~parser ~pp ()
;;

let cmd =
  let term =
    let+ target =
      Arg.(
        required
        & pos 0 (some output_target) None
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
