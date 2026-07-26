(** [loop ?socket_path ?transport ~init_command ~net ~clock ()] connects to
    River, manages until shutdown, and returns the process exit code.

    {b Effects:} mutates WM state; sends River request; I/O *)
val loop
  :  ?socket_path:string
  -> ?transport:Wayland.Unix_transport.t
  -> init_command:string option
  -> net:Eio_unix.Net.t
  -> clock:[> float Eio.Time.clock_ty ] Eio.Resource.t
  -> unit
  -> int
