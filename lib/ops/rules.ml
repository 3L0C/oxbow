open! Ocdwm_core
open! Ocdwm_state

let apply wm (window : Window.t) ({ pattern; action } : Rule.t) =
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
    | Set_tags arg -> Window.queue_request wm window @@ Set_tags arg
    | Send_to_output { name; policy } ->
      Window.queue_request wm window @@ Send_to_output_name { name; policy }
    | Float -> Window.queue_request wm window Float
    | Tile -> Window.queue_request wm window Tile
    | Fullscreen ->
      Window.queue_request wm window @@ Fullscreen { output = window.output }
    | Windowed -> Window.queue_request wm window Exit_fullscreen)
;;

let apply_for ctx window =
  let wm = Ctx.wm ctx in
  List.iter (apply wm window) wm.config.rules
;;

let add (wm : Wm.t) rule =
  if List.exists (Rule.equal rule) wm.config.rules
  then Error "rule already exists"
  else (
    Config.add_rule wm rule;
    Ok None)
;;

let remove (wm : Wm.t) rule =
  if List.exists (Rule.equal rule) wm.config.rules
  then (
    Config.remove_rule wm rule;
    Ok None)
  else Error "no matching rule"
;;
