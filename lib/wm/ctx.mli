open Types

type manage
type render
type 'p t

val wm : 'p t -> Window_manager_t.t
val with_manage : Window_manager_t.t -> (manage t -> 'a) -> 'a
val with_render : Window_manager_t.t -> (render t -> 'a) -> 'a
