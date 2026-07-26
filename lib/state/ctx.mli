type plan = [ `Plan ]
type manage = [ `Manage ]
type render = [ `Render ]
type 'p t

val wm : 'p t -> Types.Wm.t

(** [plan ctx] narrows a manage witness to a plan witness. *)
val plan : manage t -> plan t

val with_manage : Types.Wm.t -> (manage t -> 'a) -> 'a
val with_render : Types.Wm.t -> (render t -> 'a) -> 'a
