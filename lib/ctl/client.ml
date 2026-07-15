open! Ocdwm_core

module Error = struct
  type t =
    | Connection_failed of string
    | Protocol of string
end

let send ~env ?seat ?socket (body : Request.Body.t)
  : (Yojson.Safe.t option, Error.t) result
  =
  let path = Socket_path.resolve ?override:socket () in
  let net = Eio.Stdenv.net env in
  let addr = `Unix path in
  let req = Request.{ body; seat } in
  let req_str = Yojson.Safe.to_string (Request.yojson_of_t req) ^ "\n" in
  try
    Eio.Switch.run
    @@ fun sw ->
    let flow = Eio.Net.connect ~sw net addr in
    Eio.Flow.copy_string req_str flow;
    Eio.Flow.shutdown flow `Send;
    let buf = Eio.Buf_read.of_flow flow ~max_size:65536 in
    let line = Eio.Buf_read.line buf in
    let resp = Response.t_of_yojson @@ Yojson.Safe.from_string line in
    if resp.ok
    then Ok resp.data
    else Error (Error.Protocol (Option.value ~default:"unspecified" resp.err))
  with
  | Eio.Io _ as ex -> Error (Connection_failed (Format.asprintf "%a" Eio.Exn.pp ex))
;;
