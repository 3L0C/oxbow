open! Oxbow_core
open! Oxbow_state

let ( |>? ) o f = Option.iter f o

(* Effect order: output, tags, presentation, resize, move, sticky, swallow, label.
   Roughly, placement targets -> mode -> geometry -> etc. *)
let apply_effects
      (queue : Window.Request.t -> unit)
      (e : Window_rule.Effects.t)
      (window : Window.t)
  =
  (e.output |>? fun { name; policy } -> queue (Send_to_output_name { name; policy }));
  (e.tags |>? fun arg -> queue (Set_tags arg));
  (e.presentation
   |>? function
   | Float -> queue Float
   | Tile -> queue Tile
   | Fullscreen -> queue (Fullscreen { output = None })
   | Windowed -> queue Exit_fullscreen
   | Maximize -> queue Maximize
   | Fake_fullscreen -> queue Fake_fullscreen);
  (e.resize_to |>? fun { w; h } -> queue (Resize_to { w; h }));
  (e.move_to |>? fun { x; y } -> queue (Move_to { x; y }));
  (e.sticky |>? fun s -> queue (Set_sticky s));
  (e.scratchpad |>? fun name -> Window.set_scratchpad window (Some name));
  (e.swallow
   |>? fun r ->
   Window.set_swallow_role
     window
     (match r with
      | Auto -> Auto
      | Terminal -> Terminal
      | Disabled -> Disabled));
  e.label_as |>? fun l -> Window.add_label window l
;;

let apply (window : Window.t) ({ pattern; effects } : Window_rule.t) =
  match Window_pattern.compile pattern with
  | Error e -> Logs.debug @@ fun m -> m "%s" e
  | Ok matches ->
    if
      matches
        ~title:window.title
        ~app_id:window.app_id
        ~identifier:window.identifier
        ~labels:window.labels
    then (
      let queue r = Window.queue_request window r in
      apply_effects queue effects window)
;;

let apply_for (wm : Wm.t) window = List.iter (apply window) wm.config.rules.window
let same (p : Window_pattern.t) (r : Window_rule.t) = Window_pattern.equal p r.pattern

let add (wm : Wm.t) (rule : Window_rule.t) =
  Result.bind (Window_pattern.compile rule.pattern)
  @@ fun _ ->
  match List.find_opt (same rule.pattern) wm.config.rules.window with
  | Some old ->
    let merged =
      { rule with
        effects = Window_rule.Effects.merge ~old:old.effects ~new_:rule.effects
      }
    in
    Config.replace_window_rule wm merged;
    List.iter (fun w -> apply w merged) wm.windows;
    Ok None
  | None ->
    Config.add_window_rule wm rule;
    List.iter (fun w -> apply w rule) wm.windows;
    Ok None
;;

let remove (wm : Wm.t) index =
  match List.nth_opt wm.config.rules.window index with
  | None -> Error (Printf.sprintf "no window rule at index %d" index)
  | Some _ ->
    Config.remove_window_rule wm index;
    Ok None
;;

let spawn_for (wm : Wm.t) (window : Window.t) =
  List.fold_left
    (fun (position, focus) ({ pattern; effects } : Window_rule.t) ->
       match Window_pattern.compile pattern with
       | Error _ -> position, focus
       | Ok matches ->
         if
           matches
             ~title:window.title
             ~app_id:window.app_id
             ~identifier:window.identifier
             ~labels:window.labels
         then
           ( Option.value effects.spawn_position ~default:position
           , Option.value effects.spawn_focus ~default:focus )
         else position, focus)
    (wm.config.spawn.position, wm.config.spawn.focus)
    wm.config.rules.window
;;
