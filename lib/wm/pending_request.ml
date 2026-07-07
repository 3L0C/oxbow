open Ocdwm_core

type t =
  { body : Request_body.t
  ; reply : (Yojson.Safe.t option, string) result Eio.Promise.u option
  }
