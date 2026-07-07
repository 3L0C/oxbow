open! Ocdwm_core

let apply (window : Types.Window.t) ({ pattern; action } : Window_rule.t) =
  let search r_str s_str =
    let r =
      try Str.regexp r_str with
      | Failure _ -> Str.regexp_string_case_fold r_str
    in
    try
      ignore @@ Str.search_forward r s_str 0;
      true
    with
    | Not_found -> false
  in
  let matches_app_id =
    match pattern.app_id, window.app_id with
    | None, _ -> false
    | Some p_str, Some w_str -> search p_str w_str
    | _, _ -> false
  in
  let matches_title =
    match pattern.title, window.title with
    | None, _ -> false
    | Some p_str, Some w_str -> search p_str w_str
    | _, _ -> false
  in
  if matches_app_id || matches_title
  then (
    match action with
    | Set_tags arg -> Window.queue_request window @@ Req_set_tags arg
    | Send_to_output { name; policy } ->
      Window.queue_request window @@ Req_send_to_output_name { name; policy }
    | Float -> Window.queue_request window Req_float
    | Tile -> Window.queue_request window Req_tile
    | Fullscreen ->
      Window.queue_request window @@ Req_fullscreen { output = window.output }
    | Windowed -> () (* FIXME not really sure what request to put here *))
;;

let apply_for ctx window =
  let wm = Ctx.wm ctx in
  List.iter (apply window) wm.config.rules
;;
