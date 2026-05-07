[@@@landmark "auto-off"]

let run ~wm:_ flow =
  let buf = Eio.Buf_read.of_flow flow ~max_size:65536 in
  let _line = Eio.Buf_read.line buf in
  let resp = `Assoc [ "ok", `Bool true ] in
  let s = Yojson.Safe.to_string resp ^ "\n" in
  Eio.Flow.copy_string s flow
;;
