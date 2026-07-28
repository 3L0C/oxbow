type plan = [ `Plan ]
type manage = [ `Manage ]
type render = [ `Render ]
type 'p t

val wm : 'p t -> Ocdwm_state.Wm.t

(** [plan ctx] narrows a manage witness to a plan witness. *)
val plan : manage t -> plan t

val with_manage : Ocdwm_state.Wm.t -> (manage t -> 'a) -> 'a
val with_render : Ocdwm_state.Wm.t -> (render t -> 'a) -> 'a
