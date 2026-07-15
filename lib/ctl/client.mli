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
  -> Ocdwm_core.Request.Body.t
  -> (Yojson.Safe.t option, Error.t) result
