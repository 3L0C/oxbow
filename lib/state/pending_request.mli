type t =
  { body : Oxbow_ipc.Request.Body.t
  ; reply : (Yojson.Safe.t option, string) result Eio.Promise.u option
  }
