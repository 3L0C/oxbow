type manage
type render
type 'p t

val wm : 'p t -> Types.Window_manager.t
val with_manage : Types.Window_manager.t -> (manage t -> 'a) -> 'a
val with_render : Types.Window_manager.t -> (render t -> 'a) -> 'a
