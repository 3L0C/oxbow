(** [start ?socket_path ~sw ~net ~wm ()] listens on the resolved [socket_path] and
    forks a handler fiber per connection until [wm] shuts down.

    {b Effects:} mutates WM state; I/O *)
val start
  :  ?socket_path:string
  -> sw:Eio.Switch.t
  -> net:_ Eio.Net.t
  -> wm:Ocdwm_state.Wm.t
  -> unit
  -> unit
