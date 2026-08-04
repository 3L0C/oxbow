(** [socket_path] is the IPC socket path that [run] serves. *)
val socket_path : string

(** [wait_for ?tries p] yields until [p] holds. It fails after [tries] yields. *)
val wait_for : ?tries:int -> (unit -> bool) -> unit

(** [section name] prints one section header line. *)
val section : string -> unit

(** [dump_trace fake] prints the recorded requests, oldest first. *)
val dump_trace : Fake_river.t -> unit

(** [settle fake] waits until [fake] stays idle over several yields. *)
val settle : Fake_river.t -> unit

(** [dump_new fake] prints the requests that arrived after the last [dump_new]
    call, oldest first. *)
val dump_new : Fake_river.t -> unit

(** [ipc env body] sends [body] over the IPC socket and returns the reply.

    {b Effects:} I/O *)
val ipc : Eio_unix.Stdenv.base -> Oxbow_ipc.Request.Body.t -> Yojson.Safe.t option

(** [oxctl env args] evaluates the oxctl command line [args] in process, sends the
    request over [socket_path], and prints the reply like oxctl. Cmdliner errors
    print with the "err:" mark.

    {b Effects:} I/O *)
val oxctl : Eio_unix.Stdenv.base -> string list -> unit

(** [run script] starts the runtime loop against a fake river over a socketpair,
    then runs [script]. It returns when [script] returns.

    {b Effects:} I/O *)
val run
  :  (Eio_unix.Stdenv.base
      -> Fake_river.t
      -> section:(string -> (unit -> unit) -> unit)
      -> unit)
  -> unit
