module Rwm = Ocdwm_protocol.River_window_management_v1_client
module Rlsh = Ocdwm_protocol.River_layer_shell_v1_client
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
    seat.output <- target.output;
    Window_manager.focus_output ctx target.output;
    Output.focus_window ctx seat target
;;

let clear (_ : Ctx.manage Ctx.t) (seat : Types.Seat.t) =
  Rwm.River_seat_v1.clear_focus seat.obj
;;

let refresh_focus (ctx : Ctx.manage Ctx.t) (output : Types.Output.t) =
  let wm = Ctx.wm ctx in
  match Output.focused_window output with
  | None ->
    Window_manager.focus_output ctx @@ Some output;
    List.iter
      (fun (s : Types.Seat.t) ->
         match s.output with
         | Some so when so == output -> clear ctx s
         | _ -> ())
      wm.seats
  | Some w ->
    Window_manager.focus_output ctx @@ Some output;
    List.iter
      (fun (s : Types.Seat.t) ->
         match s.output with
         | Some so when so == output -> focus_window ~force:true ctx s w
         | _ -> ())
      wm.seats
;;

let focus_window_dir (ctx : Ctx.manage Ctx.t) (seat : Types.Seat.t) (dir : Direction.t) =
  match focused_of seat, seat.output with
  | Some w, _ when Window.is_fullscreen w -> ()
  | _, None -> ()
  | _, Some o ->
    (match dir with
     | Dir_next -> Output.next_window o |> Option.iter (focus_window ctx seat)
     | Dir_prev -> Output.prev_window o |> Option.iter (focus_window ctx seat)
     | Dir_left | Dir_right | Dir_up | Dir_down -> ())
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
      match q.fields with
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
        Utils.after_or_first w windows
      | _ -> List.nth_opt windows 0
    in
    Option.iter (focus_window ctx seat) target
;;

let focus_window_target
      (ctx : Ctx.manage Ctx.t)
      (seat : Types.Seat.t)
      (target : Window_target.t)
  =
  match target with
  | By_direction d -> focus_window_dir ctx seat d
  | By_query q -> focus_window_query ctx seat q
;;

let focus_output_dir (ctx : Ctx.manage Ctx.t) (seat : Types.Seat.t) (dir : Direction.t) =
  let wm = Ctx.wm ctx in
  match seat.output with
  | None -> ()
  | Some o ->
    let target =
      match dir with
      | Dir_next | Dir_down | Dir_right -> Utils.after_or_first o wm.outputs
      | Dir_prev | Dir_up | Dir_left -> Utils.prev_or_last o wm.outputs
    in
    (match target with
     | Some t when t != o ->
       Rlsh.River_layer_shell_output_v1.set_default t.layer_shell;
       (match Output.focused_window t with
        | Some w -> focus_window ctx seat w
        | None ->
          seat.output <- target;
          Window_manager.focus_output ctx target;
          clear ctx seat)
     | _ -> ())
;;

let focus_output_target
      (ctx : Ctx.manage Ctx.t)
      (seat : Types.Seat.t)
      (target : Output_target.t)
  =
  match target with
  | By_direction d -> focus_output_dir ctx seat d
  | By_name q -> Logs.err @@ fun m -> m "Focus_output_by_name: not yet implemented"
;;

let get_output (lst : Types.Output.t list) = List.nth_opt lst 0

let focus_other_output (ctx : Ctx.manage Ctx.t) (output : Types.Output.t) =
  let wm = Ctx.wm ctx in
  match wm.focused_output with
  | Some o when o == output ->
    Window_manager.focus_output ctx @@ List.find_opt (fun o -> o != output) wm.outputs
  | _ -> ()
;;

let remove_window (ctx : Ctx.manage Ctx.t) (window : Types.Window.t) =
  Option.iter (Output.remove_window ~window) window.output;
  Option.iter (refresh_focus ctx) window.output
;;

let sync (ctx : Ctx.manage Ctx.t) =
  let wm = Ctx.wm ctx in
  match wm.focused_output with
  | None ->
    (match wm.outputs with
     | o :: _ -> Window_manager.focus_output ctx @@ Some o
     | [] -> ())
  | Some o ->
    if not @@ List.memq o wm.outputs
    then (
      match wm.outputs with
      | o :: _ -> Window_manager.focus_output ctx @@ Some o
      | [] -> Window_manager.focus_output ctx None)
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
