type manage
type render
type 'p t

val wm : 'p t -> Types.Wm.t
val with_manage : Types.Wm.t -> (manage t -> 'a) -> 'a
val with_render : Types.Wm.t -> (render t -> 'a) -> 'a
