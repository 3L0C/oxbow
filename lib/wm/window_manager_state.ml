type t =
  | Wm_running
  | Wm_pending_exit of [ `Local | `Compositor ]
  | Wm_exited
  | Wm_pending_close
  | Wm_close_sent
  | Wm_closed

let to_string = function
  | Wm_running -> "running"
  | Wm_pending_exit `Local -> "pending_exit(local)"
  | Wm_pending_exit `Compositor -> "pending_exit(compositor)"
  | Wm_exited -> "exited"
  | Wm_pending_close -> "pending_close"
  | Wm_close_sent -> "close_sent"
  | Wm_closed -> "closed"
;;
