type manage = [ `Manage ]
type render = [ `Render ]
type 'p t

val wm : 'p t -> Ocdwm_state.Wm.t
val with_manage : Ocdwm_state.Wm.t -> (manage t -> 'a) -> 'a
val with_render : Ocdwm_state.Wm.t -> (render t -> 'a) -> 'a
