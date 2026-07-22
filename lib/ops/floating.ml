open! Ocdwm_core
open! Ocdwm_state

let arrange ctx (output : Output.t) =
  if not @@ Output.has_visible_fullscreen output
  then (
    let windows = Output.tiled_windows output in
    List.iter (Window.restore_or_seed_float ctx) windows)
;;
