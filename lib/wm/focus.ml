open! Ocdwm_core

let focused_of (seat : Types.Seat.t) : Types.Window.t option =
  match seat.output with
  | Some o -> Output.focused_window o
  | None -> None
;;

let focus_window
      ?(force : bool = false)
      (ctx : Ctx.manage Ctx.t)
      (seat : Types.Seat.t)
      (target : Types.Window.t)
  =
  let force = force || seat.layer_focus <> Lf_none in
  match focused_of seat with
  | Some w when w == target && not force -> ()
  | _ ->
    Window_manager.focus_output ctx seat target.output;
    Output.focus_window ctx seat target
;;

let clear (_ : Ctx.manage Ctx.t) (seat : Types.Seat.t) =
  River.Window_management.River_seat_v1.clear_focus seat.obj
;;

let refresh_focus (ctx : Ctx.manage Ctx.t) (output : Types.Output.t) =
  let wm = Ctx.wm ctx in
  let target = Output.focused_window output in
  List.iter
    (fun (s : Types.Seat.t) ->
       match s.output with
       | Some o when o == output ->
         (match target with
          | Some w -> focus_window ~force:true ctx s w
          | None -> clear ctx s)
       | _ -> ())
    wm.seats
;;

let focus_window_logical
      (ctx : Ctx.manage Ctx.t)
      (seat : Types.Seat.t)
      (dir : Logical_direction.t)
  =
  match focused_of seat, seat.output with
  | Some w, _ when Window.is_fullscreen w -> ()
  | _, None -> ()
  | _, Some o ->
    (match dir with
     | Next -> Output.next_window o |> Option.iter (focus_window ctx seat)
     | Prev -> Output.prev_window o |> Option.iter (focus_window ctx seat))
;;

let focus_window_spatial
      (ctx : Ctx.manage Ctx.t)
      (seat : Types.Seat.t)
      (dir : Spatial_direction.t)
  =
  match focused_of seat, seat.output with
  | Some w, _ when Window.is_fullscreen w -> ()
  | _, None -> ()
  | None, Some _ -> ()
  | Some current, Some o ->
    let from = Vector.position_of_box (Rect.to_int current.geom) in
    Vector.nearest_in_direction
      ~from
      ~dir
      (fun (w : Types.Window.t) ->
         if w == current || (not @@ Window.is_tiled w) || (not @@ Window.tag_visible w)
         then None
         else Some (Rect.to_int w.geom |> Vector.position_of_box))
      o.windows
    |> Option.iter (focus_window ctx seat)
;;

let focus_window_query (ctx : Ctx.manage Ctx.t) (seat : Types.Seat.t) (q : Window_query.t)
  =
  let wm = Ctx.wm ctx in
  match Window_query.get_regex q with
  | Error e -> Logs.err @@ fun m -> m "%s" e
  | Ok r ->
    let matches_opt = function
      | Some s ->
        (try
           ignore @@ Str.search_forward r s 0;
           true
         with
         | Not_found -> false)
      | None -> false
    in
    let matches_fields =
      match q.field with
      | Any -> fun title app_id -> matches_opt title || matches_opt app_id
      | Title -> fun title _ -> matches_opt title
      | App_id -> fun _ app_id -> matches_opt app_id
    in
    let windows =
      List.find_all
        (fun (w : Types.Window.t) -> matches_fields w.title w.app_id)
        wm.windows
    in
    let target =
      match focused_of seat with
      | Some w when q.cycle && matches_fields w.title w.app_id ->
        Utils.next_or_first w windows
      | _ -> List.nth_opt windows 0
    in
    Option.iter (focus_window ctx seat) target
;;

let focus_output (ctx : Ctx.manage Ctx.t) (seat : Types.Seat.t) (output : Types.Output.t) =
  Window_manager.focus_output ctx seat @@ Some output;
  match Output.focused_window output with
  | Some w -> focus_window ctx seat w
  | None -> clear ctx seat
;;

let focus_output_logical
      (ctx : Ctx.manage Ctx.t)
      (seat : Types.Seat.t)
      (dir : Logical_direction.t)
  =
  let wm = Ctx.wm ctx in
  match seat.output with
  | None -> ()
  | Some o ->
    let target =
      match dir with
      | Next -> Utils.next_or_first o wm.outputs
      | Prev -> Utils.prev_or_last o wm.outputs
    in
    (match target with
     | Some t when t != o -> focus_output ctx seat t
     | _ -> ())
;;

let focus_output_spatial
      (ctx : Ctx.manage Ctx.t)
      (seat : Types.Seat.t)
      (dir : Spatial_direction.t)
  =
  let wm = Ctx.wm ctx in
  match seat.output with
  | None -> ()
  | Some current ->
    let from = Vector.position_of_box (Rect.to_int current.geom) in
    Vector.nearest_in_direction
      ~from
      ~dir
      (fun (o : Types.Output.t) ->
         if o == current then None else Some (Rect.to_int o.geom |> Vector.position_of_box))
      wm.outputs
    |> Option.iter (focus_output ctx seat)
;;

let focus_output_name (ctx : Ctx.manage Ctx.t) (seat : Types.Seat.t) (name : string) =
  let wm = Ctx.wm ctx in
  match
    List.find_opt
      (fun (o : Types.Output.t) ->
         Option.fold ~none:false ~some:(fun n -> n = name) o.name)
      wm.outputs
  with
  | None -> ()
  | Some o ->
    (match seat.output with
     | None -> focus_output ctx seat o
     | Some o' when o != o' -> focus_output ctx seat o
     | _ -> ())
;;

let remove_window (ctx : Ctx.manage Ctx.t) (window : Types.Window.t) =
  Option.iter (Output.remove_window ~window) window.output;
  Option.iter (refresh_focus ctx) window.output
;;

let sync (ctx : Ctx.manage Ctx.t) =
  let wm = Ctx.wm ctx in
  let default = Window_manager.default_output wm in
  List.iter
    (fun (s : Types.Seat.t) ->
       match s.output with
       | Some o when not @@ List.memq o wm.outputs ->
         Window_manager.focus_output ctx s default
       | None when not @@ List.is_empty wm.outputs ->
         Window_manager.focus_output ctx s default
       | _ -> ())
    wm.seats;
  List.iter
    (fun (w : Types.Window.t) ->
       match w.output with
       | None when not @@ List.is_empty wm.outputs ->
         w.output <- default;
         Option.iter
           (fun o ->
              Output.push [ w ] o;
              Output.mark_dirty wm o)
           default
       | _ -> ())
    wm.windows
;;

let zoom ctx (seat : Types.Seat.t) =
  let wm = Ctx.wm ctx in
  match seat.output, focused_of seat with
  | Some o, Some w when w.presentation = P_tiled ->
    (match Output.tiled_windows o with
     | w' :: x :: _ when w' == w ->
       Output.push [ x; w ] o;
       focus_window ~force:true ctx seat x;
       Output.mark_dirty wm o
     | w' :: _ when w' != w ->
       Output.push [ w; w' ] o;
       focus_window ~force:true ctx seat w;
       Output.mark_dirty wm o
     | [] when Output.current_layout_entry o |> Layout.entry_name <> Floating.name ->
       Logs.err
       @@ fun m -> m "zoom: focused window is tiled but tiled window list is empty"
     | _ -> ())
  | _ -> ()
;;
