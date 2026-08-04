type manage = [ `Manage ]
type render = [ `Render ]
type 'p t

val wm : 'p t -> Oxbow_state.Wm.t
val with_manage : Oxbow_state.Wm.t -> (manage t -> 'a) -> 'a
val with_render : Oxbow_state.Wm.t -> (render t -> 'a) -> 'a
