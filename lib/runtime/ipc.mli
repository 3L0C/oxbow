module Handler : sig
  (** [run ~wm flow] reads one request line from [flow], queues it on the resolved
      seat, and writes the JSON reply when the request completes.

      {b Effects:} mutates WM state; I/O *)
  val run : wm:Ocdwm_state.Wm.t -> _ Eio.Flow.two_way -> unit
end

module Server : sig
  (** [start ~sw ~net ~wm] listens on the resolved socket path and forks a handler
      fiber per connection until [wm] shuts down.

      {b Effects:} mutates WM state; I/O *)
  val start
    :  sw:Eio.Switch.t
    -> net:[> 'a Eio.Net.ty ] Eio.Resource.t
    -> wm:Ocdwm_state.Wm.t
    -> unit
end
