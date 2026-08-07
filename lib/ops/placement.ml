open! Oxbow_core
open! Oxbow_state
open! Oxbow_ipc

let zoom ?warp wm seat target =
  Result.bind (Targets.resolve_one_window wm seat target) (fun w ->
    With.output w
    @@ fun o ->
    match Output.current_layout o with
    | _ when o.overview.enabled -> Error "cannot zoom from overview"
    | Floating -> Error "cannot zoom in the floating layout"
    | Scrolling -> Column.zoom ?warp wm seat w
    | Tiling -> Tiling.zoom ?warp wm seat w)
;;

let move_window ?(policy = Tag.Policy.Keep) window (target : Output.t) =
  let take () =
    (match policy with
     | Keep -> ()
     | Take ->
       Tag.Set.first_index target.tags.selected
       |> Option.fold ~none:window.tags ~some:Tag.Set.singleton
       |> Window.set_tags window);
    Window.set_output window @@ Some target;
    Stacking.push [ window ] target
  in
  match window.output with
  | Some o when o == target -> ()
  | None -> take ()
  | Some _ ->
    Option.iter (Stacking.remove_window ~window) window.output;
    take ()
;;

let send_to ~(src : Output.t) ~(dst : Output.t) window policy =
  move_window ~policy window dst;
  (match window.presentation with
   | Tiled -> ()
   | Floating ->
     let dx = Int32.sub dst.geom.x src.geom.x in
     let dy = Int32.sub dst.geom.y src.geom.y in
     Window.set_position
       window
       ~x:(Int32.add window.geom.x dx)
       ~y:(Int32.add window.geom.y dy);
     Window.fit_to_output window;
     Window.remember_float window
   | Maximized { restore } -> Window.maximize ~restore window
   | Fullscreen _ -> Window.fullscreen ~force:true window);
  Schedule.manage ()
;;

let send_result ~src window policy ~err = function
  | Some o when o != src -> Ok (fun () -> send_to ~src ~dst:o window policy)
  | _ -> Error err
;;

let plan_send_window_to_logical (wm : Wm.t) window dir policy =
  With.output window
  @@ fun current ->
  Output.resolve_output_logical ~dir current wm.outputs
  |> send_result ~src:current window policy ~err:Messages.no_other_output
;;

let send_window_to_logical wm window dir policy =
  Result.map (fun commit ->
    commit ();
    None)
  @@ plan_send_window_to_logical wm window dir policy
;;

let plan_send_window_to_spatial (wm : Wm.t) window dir policy =
  With.output window
  @@ fun current ->
  let from = Output.to_vector current in
  Output.resolve_output_spatial ~from ~dir current wm.outputs
  |> send_result
       ~src:current
       window
       policy
       ~err:(Printf.sprintf "no output %s" (Direction.Spatial.to_string dir))
;;

let send_window_to_spatial wm window dir policy =
  Result.map (fun commit ->
    commit ();
    None)
  @@ plan_send_window_to_spatial wm window dir policy
;;

let plan_send_window_to_name (wm : Wm.t) window name policy =
  With.output window
  @@ fun current ->
  if Output.matches_name name current
  then Ok ignore
  else
    Output.resolve_output_name name wm.outputs
    |> send_result
         ~src:current
         window
         policy
         ~err:(Printf.sprintf "no output named %S" name)
;;

let send_window_to_name wm window name policy =
  Result.map (fun commit ->
    commit ();
    None)
  @@ plan_send_window_to_name wm window name policy
;;

let follow_focus wm seat ~follow ~send =
  Result.bind (send ()) (function
    | w :: _ when follow ->
      Focus.focus_window ~force:true ~warp:Seat.Warp_request.Follow_config wm seat w;
      Ok None
    | _ -> Ok None)
;;

let send_to_logical wm seat target dir policy ~follow =
  follow_focus wm seat ~follow ~send:(fun () ->
    Targets.transact_all_windows wm seat target ~plan:(fun w ->
      plan_send_window_to_logical wm w dir policy))
;;

let send_to_spatial wm seat target dir policy ~follow =
  follow_focus wm seat ~follow ~send:(fun () ->
    Targets.transact_all_windows wm seat target ~plan:(fun w ->
      plan_send_window_to_spatial wm w dir policy))
;;

let send_to_name wm seat target name policy ~follow =
  follow_focus wm seat ~follow ~send:(fun () ->
    Targets.transact_all_windows wm seat target ~plan:(fun w ->
      plan_send_window_to_name wm w name policy))
;;

let toggle_floating wm seat target =
  Result.map (fun _ -> None)
  @@ Targets.transact_all_windows wm seat target ~plan:(fun w ->
    match w.output with
    | None -> Error Messages.window_missing_output
    | Some o ->
      if Output.current_layout o = Floating
      then Error "cannot toggle floating from the floating layout"
      else if o.overview.enabled
      then Error "cannot toggle floating from overview"
      else (
        match w.presentation with
        | Fullscreen _ -> Error "cannot toggle float while window is fullscreen"
        | Maximized _ -> Error "cannot toggle float while window is maximized"
        | Floating when w.is_fixed -> Error "cannot tile a fixed window"
        | Tiled ->
          Ok
            (fun () ->
              Window.float w;
              Schedule.manage ())
        | Floating ->
          Ok
            (fun () ->
              Window.tile w;
              Schedule.manage ())))
;;

let maximize (wm : Wm.t) window =
  List.iter Seat.clear_op wm.seats;
  Window.maximize window;
  Schedule.manage ()
;;

let unmaximize window =
  Window.unmaximize window;
  Schedule.manage ()
;;

let fullscreen (wm : Wm.t) output (window : Window.t) cb =
  let enter () =
    match output, window.output with
    | None, None -> ()
    | Some o, _ | None, Some o ->
      List.iter
        (fun w ->
           if Window.tag_visible w && Window.is_fullscreen w
           then cb wm w Window.Request.Exit_fullscreen)
        o.focus_stack;
      List.iter Seat.clear_op wm.seats;
      move_window window o;
      Window.fullscreen window;
      Schedule.manage ()
  in
  match window.presentation with
  | Tiled | Floating | Maximized _ -> enter ()
  | Fullscreen _ ->
    (match output, window.output with
     | Some o1, Some o2 when o1 != o2 ->
       move_window window o1;
       Window.fullscreen ~force:true window;
       Schedule.manage ()
     | _, _ -> ())
;;

let exit_fullscreen (window : Window.t) =
  match window.presentation with
  | Tiled | Floating | Maximized _ -> ()
  | Fullscreen _ ->
    Window.exit_fullscreen window;
    Schedule.manage ()
;;

let close wm seat target =
  Result.map (fun _ -> None)
  @@ Targets.transact_all_windows wm seat target ~plan:(fun w ->
    Ok (fun () -> Window.set_close_pending w true))
;;

let unless_fullscreen ~verb w f =
  if Window.is_fullscreen w
  then Error (Printf.sprintf "cannot %s a fullscreen window" verb)
  else
    Ok
      (fun () ->
        f ();
        Schedule.manage ())
;;

let plan_move_window_to ~x ~y w =
  unless_fullscreen ~verb:"move" w @@ fun () -> Window.move_to w ~x ~y
;;

let move_window_to ~x ~y w =
  Result.map (fun commit ->
    commit ();
    None)
  @@ plan_move_window_to ~x ~y w
;;

let move_to ~x ~y wm seat target =
  Result.map (fun _ -> None)
  @@ Targets.transact_all_windows wm seat target ~plan:(fun w ->
    plan_move_window_to ~x ~y w)
;;

let move_spatial wm seat target dir by =
  Result.map (fun _ -> None)
  @@ Targets.transact_all_windows wm seat target ~plan:(fun w ->
    unless_fullscreen ~verb:"move" w @@ fun () -> Window.move_spatial w dir by)
;;

let plan_resize_window_to ~width ~height window =
  unless_fullscreen ~verb:"resize" window
  @@ fun () -> Window.resize_to window ~width ~height
;;

let resize_window_to ~width ~height window =
  Result.map (fun commit ->
    commit ();
    None)
  @@ plan_resize_window_to ~width ~height window
;;

let resize_to ~width ~height wm seat target =
  Result.map (fun _ -> None)
  @@ Targets.transact_all_windows wm seat target ~plan:(fun w ->
    plan_resize_window_to ~width ~height w)
;;

let resize_spatial wm seat target dir by =
  Result.map (fun _ -> None)
  @@ Targets.transact_all_windows wm seat target ~plan:(fun w ->
    unless_fullscreen ~verb:"resize" w @@ fun () -> Window.resize_spatial w dir by)
;;

let swap_outputs
      (wm : Wm.t)
      seat
      ~(target : Command.Output.Swap.Target.t)
      ~policy
      ~follow
      scope
  =
  With.focused_output seat
  @@ fun current ->
  let with_named_output name f =
    match List.find_opt (fun (o : Output.t) -> Output.matches_name name o) wm.outputs with
    | None -> Error (Printf.sprintf "no output name matching %S" name)
    | Some o -> f o
  in
  let pair =
    match target with
    | Pair { first; second } ->
      (match first, second with
       | None, None ->
         (match wm.outputs with
          | [ a; b ] -> if a == current then Ok (a, b) else Ok (b, a)
          | os ->
            Error (Printf.sprintf "needs exactly two outputs, have %d" (List.length os)))
       | Some n, None -> with_named_output n @@ fun a -> Ok (current, a)
       | Some n, Some n' ->
         with_named_output n @@ fun a -> with_named_output n' @@ fun b -> Ok (a, b)
       | None, Some _ -> Error "swap needs a first output name before a second")
    | Ring { members; rev } ->
      let resolve name = List.find_opt (Output.matches_name name) wm.outputs in
      let live = List.filter_map resolve members in
      if List.length live < 2
      then Error "the ring needs two connect outputs"
      else if not @@ List.memq current live
      then Error "the focused output is not in the ring"
      else (
        let dest =
          Option.get
          @@
          if rev then Ring.prev_or_last current live else Ring.next_or_first current live
        in
        Ok (current, dest))
  in
  match pair with
  | Error _ as e -> e
  | Ok (a, b) when a == b -> Error "cannot swap an output with itself"
  | Ok (a, b) ->
    let in_scope =
      match scope with
      | `Tags ->
        fun (o : Output.t) ->
          if o == a
          then Output.visible_windows a
          else Output.windows_on_tags b ~tags:a.tags.selected
      | `All -> fun (o : Output.t) -> o.wm_stack
      | `Visible -> Output.visible_windows
    in
    let a_focus = a.focus_stack
    and b_focus = b.focus_stack
    and a_ws = in_scope a |> List.rev
    and b_ws = in_scope b |> List.rev in
    List.iter (fun w -> send_to ~src:a ~dst:b w policy) a_ws;
    List.iter (fun w -> send_to ~src:b ~dst:a w policy) b_ws;
    Stacking.restore_focus_order ~like:a_focus b;
    Stacking.restore_focus_order ~like:b_focus a;
    if follow
    then (
      let arrived w = List.memq w a_focus in
      match List.find_opt arrived b.focus_stack with
      | Some w ->
        Focus.focus_window ~force:true ~warp:Seat.Warp_request.Follow_config wm seat w
      | None -> Focus.focus_output wm seat b);
    Ok None
;;

let set_sticky wm seat target scope =
  Result.map (fun _ -> None)
  @@ Targets.transact_all_windows wm seat target ~plan:(fun w ->
    Ok (fun () -> Window.set_sticky w scope))
;;

let toggle_sticky wm seat target toggle =
  Result.map (fun _ -> None)
  @@ Targets.transact_all_windows wm seat target ~plan:(fun w ->
    let scope =
      match w.sticky with
      | Off -> Sticky.of_toggle toggle
      | Occupied | All -> Off
    in
    Ok (fun () -> Window.set_sticky w scope))
;;
