let ok = 0
let unavailable = 69
let software = 70

let exits =
  let open Cmdliner in
  List.fold_left
    (fun acc (code, doc) -> Cmd.Exit.info code ~doc :: acc)
    []
    [ ok, "on success"
    ; unavailable, "on unavailable service"
    ; software, "on internal software error"
    ]
;;
