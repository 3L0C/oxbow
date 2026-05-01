open Types

let phase_to_string = function
  | P_manage -> "manage"
  | P_render -> "render"
  | P_idle -> "idle"

let during_cycle (wm : window_manager) ~op f =
  match wm.phase with
  | P_manage
  | P_render ->
      f ()
  | P_idle ->
      Logs.warn (fun m -> m "%s refused: phase=idle" op)

let during_manage (wm : window_manager) ~op f =
  match wm.phase with
  | P_manage -> f ()
  | P_render
  | P_idle ->
      Logs.warn (fun m ->
        m "%s refused: phase=%s" op
          (phase_to_string wm.phase))

let outside_cycle (wm : window_manager) ~op f =
  match wm.phase with
  | P_idle -> f ()
  | P_manage
  | P_render ->
      Logs.warn (fun m ->
        m "%s refused: phase=%s" op
          (phase_to_string wm.phase))
