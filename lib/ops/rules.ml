open! Ocdwm_core
open! Ocdwm_state
open! Ocdwm_ipc

let ( |>? ) o f = Option.iter f o

let apply_effects
      (queue : Window.Request.t -> unit)
      (e : Rule.Effects.t)
      (window : Window.t)
  =
  (e.output
   |>? fun ({ name; policy } : Rule.Effects.Output.t) ->
   queue (Send_to_output_name { name; policy }));
  (e.tags |>? fun arg -> queue (Set_tags arg));
  (e.presentation
   |>? function
   | Float -> queue Float
   | Tile -> queue Tile
   | Fullscreen -> queue (Fullscreen { output = window.output })
   | Windowed -> queue Exit_fullscreen
   | Maximize -> queue Maximize
   | Fake_fullscreen -> queue Fake_fullscreen);
  (e.resize_to |>? fun { w; h } -> queue (Resize_to { w; h }));
  e.move_to |>? fun { x; y } -> queue (Move_to { x; y })
;;

let apply wm (window : Window.t) ({ pattern; effects } : Rule.t) =
  match Pattern.compile pattern with
  | Error e -> Logs.debug @@ fun m -> m "%s" e
  | Ok matches ->
    if matches ~title:window.title ~app_id:window.app_id ~identifier:window.identifier
    then (
      let queue r = Window.queue_request wm window r in
      apply_effects queue effects window)
;;

let apply_for ctx window =
  let wm = Ctx.wm ctx in
  List.iter (apply wm window) wm.config.rules
;;

let same (p : Pattern.t) (r : Rule.t) = Pattern.equal p r.pattern

let add (wm : Wm.t) (rule : Rule.t) =
  match List.find_opt (same rule.pattern) wm.config.rules with
  | Some old ->
    let merged =
      { rule with effects = Rule.Effects.merge ~old:old.effects ~new_:rule.effects }
    in
    Config.replace_rule wm merged;
    List.iter (fun w -> apply wm w merged) wm.windows;
    Ok None
  | None ->
    Config.add_rule wm rule;
    List.iter (fun w -> apply wm w rule) wm.windows;
    Ok None
;;

let remove (wm : Wm.t) (pattern : Pattern.t) =
  match List.find_opt (same pattern) wm.config.rules with
  | None -> Error "no matching rule"
  | Some _ ->
    Config.remove_rule wm pattern;
    Ok None
;;

let handle ctx _seat (cmd : Command.Rule.t) =
  let wm = Ctx.wm ctx in
  match cmd with
  | Add rule -> add wm rule
  | Remove rule -> remove wm rule
;;
