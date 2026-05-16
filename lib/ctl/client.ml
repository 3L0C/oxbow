module Core = Ocdwm_core

type send_error =
  | E_conn_failed of string
  | E_protocol of string

let send ~env ?seat ?socket (action : Core.Action.t) : (unit, send_error) result =
  let path = Core.Socket_path.resolve ?override:socket () in
  let net = Eio.Stdenv.net env in
  let addr = `Unix path in
  let req = Core.Request.{ cmd = action; seat } in
  let req_str = Yojson.Safe.to_string (Core.Request.yojson_of_t req) ^ "\n" in
  try
    Eio.Switch.run
    @@ fun sw ->
    let flow = Eio.Net.connect ~sw net addr in
    Eio.Flow.copy_string req_str flow;
    Eio.Flow.shutdown flow `Send;
    let buf = Eio.Buf_read.of_flow flow ~max_size:65536 in
    let line = Eio.Buf_read.line buf in
    let resp = Core.Response.t_of_yojson @@ Yojson.Safe.from_string line in
    if resp.ok
    then Ok ()
    else Error (E_protocol (Option.value ~default:"unspecified" resp.err))
  with
  | Eio.Io _ as ex -> Error (E_conn_failed (Format.asprintf "%a" Eio.Exn.pp ex))
;;
