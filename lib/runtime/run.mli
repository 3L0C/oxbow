(** [loop ?socket_path ?transport ?on_display ~init_command ~net ~clock ()]
    connects to River, manages until shutdown, and returns the process exit
    code. [on_display] receives the connected client; the test harness uses it
    as a sync barrier.

    {b Effects:} mutates WM state; I/O *)
val loop
  :  ?socket_path:string
  -> ?transport:Wayland.Unix_transport.t
  -> ?on_display:(Wayland.Client.t -> unit)
  -> init_command:string option
  -> net:Eio_unix.Net.t
  -> clock:[> float Eio.Time.clock_ty ] Eio.Resource.t
  -> unit
  -> int
