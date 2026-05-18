open Ocdwm_core

let cmd =
  Ctl_cli.cmd
    ~name:"tag-view-previous"
    ~doc:"View the previously selected set of tags"
    Action.Tag_view_previous
;;
