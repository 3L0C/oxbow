type t =
  { body : Ocdwm_core.Request.Body.t
  ; reply : (Yojson.Safe.t option, string) result Eio.Promise.u option
  }
