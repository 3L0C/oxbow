module Error : sig
  type t =
    | Connection_failed of string
    | Protocol of string
end

(** [send ~env ?seat ?socket body] sends [body] as a one-line JSON request over
    the ocdwm socket and awaits the reply; [socket] overrides the resolved
    socket path; [seat] overrides the primary-seat target.

    {b Effects:} I/O *)
val send
  :  env:Eio_unix.Stdenv.base
  -> ?seat:string
  -> ?socket:string
  -> Request.Body.t
  -> (Yojson.Safe.t option, Error.t) result

(** [subscribe ~env ?socket ?output ~kinds f] opens a subscribe stream over the
    ocdwm socket and calls [f] with each event line until either side closes;
    [kinds] empty for all kinds, [output] restricts output-keyed kinds.

    {b Effects:} I/O; blocks until the stream ends *)
val subscribe
  :  env:Eio_unix.Stdenv.base
  -> ?socket:string
  -> ?output:string
  -> kinds:Record.t list
  -> (string -> unit)
  -> (unit, Error.t) result
