open Ocdwm_core

type t =
  { body : Request_body.t
  ; reply : (unit, string) result Eio.Promise.u option
  }
