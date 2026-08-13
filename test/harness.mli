type h_env =
  { env : Eio_unix.Stdenv.base
  ; fake : Fake_river.t
  ; section : 'a. string -> (unit -> 'a) -> 'a
  ; oxctl : string -> unit
  }

type window
type output
type seat

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

(** [with_windows name h spec body] spawns one window per [(app_id, tag)] pair
    in [spec], runs [body], then closes the spawned windows. Setup views each
    target tag before the spawn, then views tag 1. Teardown views tag 1. Setup
    and teardown run silently. The outermost runner prints one "== [name] =="
    header and ends with a quiet [oxctl config reset --all].

    {b Effects:} I/O *)
val with_windows : string -> h_env -> (string * int) list -> (unit -> unit) -> unit

(** [with_outputs name h spec body] adds one output per [(name, x, y)] triple
    in [spec], runs [body], then removes the added outputs. Setup and teardown
    run silently. The outermost runner prints one "== [name] ==" header and ends
    with a quiet [oxctl config reset --all].

    {b Effects:} I/O *)
val with_outputs
  :  string
  -> h_env
  -> (string * int32 * int32) list
  -> (unit -> unit)
  -> unit

(** [with_seats name h spec body] adds one seat per name in [spec], runs [body],
    then removes the added seats. Setup and teardown run silently. The outermost
    runner prints one "== [name] ==" header and ends with a quiet
    [oxctl config reset --all].

    {b Effects:} I/O *)
val with_seats : string -> h_env -> string list -> (unit -> unit) -> unit

(** [spawn ?section ?pid h app_id] spawns one window inside a section and
    returns its handle. The section name defaults to "[app_id] arrives".

    {b Effects:} I/O *)
val spawn : ?section:string -> ?pid:int -> h_env -> string -> window

(** [close ?section h w] closes [w] inside a section. The section name defaults
    to "close [app_id]".

    {b Effects:} I/O *)
val close : ?section:string -> h_env -> window -> unit

(** [spawn_output ?section ?x ?y h name] adds one output inside a section and
    returns its handle. The section name defaults to "[name] arrives".

    {b Effects:} I/O *)
val spawn_output : ?section:string -> ?x:int32 -> ?y:int32 -> h_env -> string -> output

(** [remove_output ?section h o] removes [o] inside a section. The section name
    defaults to "remove [name]".

    {b Effects:} I/O *)
val remove_output : ?section:string -> h_env -> output -> unit

(** [spawn_seat ?section h name] adds one seat inside a section and returns its
    handle. The section name defaults to "[name] arrives".

    {b Effects:} I/O *)
val spawn_seat : ?section:string -> h_env -> string -> seat

(** [remove_seat ?section h s] removes [s] inside a section. The section name
    defaults to "remove [name]".

    {b Effects:} I/O *)
val remove_seat : ?section:string -> h_env -> seat -> unit

(** [run script] starts the runtime loop against a fake river over a socketpair,
    then runs [script]. It returns when [script] returns.

    {b Effects:} I/O *)
val run : (h_env -> unit) -> unit
