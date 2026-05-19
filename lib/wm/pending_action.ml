open Ocdwm_core

type t =
  { action : Action.t
  ; reply : (unit, string) result Eio.Promise.u option
  }
