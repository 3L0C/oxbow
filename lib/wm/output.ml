(* ocdwm output - output handlers *)
[@@@landmark "auto"]

include Types.Output_t
module Rwm = Ocdwm_protocol.River_window_management_v1_client
module Rlsh = Ocdwm_protocol.River_layer_shell_v1_client
module Layout = Ocdwm_layout.Layout
module Tag_set = Ocdwm_core.Tag_set
module Utils = Ocdwm_core.Utils
open Ocdwm_config.Types
open Ocdwm_layout.Types

let destroy (o : t) =
  Rlsh.River_layer_shell_output_v1.destroy o.layer_shell;
  Wayland.Proxy.delete o.layer_shell;
  Rwm.River_output_v1.destroy o.obj;
  Wayland.Proxy.delete o.obj
;;

let focus_window (target : Window.t) =
  match target.output with
  | Some o -> o.focus_stack <- target :: List.filter (fun w -> w != target) o.focus_stack
  | None -> ()
;;

let focused_window (o : t) = List.find_opt Window.tag_visible o.focus_stack

let next_tiled : Window.t list -> Window.t option =
  Utils.wrapped_search Window.tag_visible (fun w -> (Option.get w.output).windows)
;;

let prev_tiled : Window.t list -> Window.t option =
  Utils.wrapped_search Window.tag_visible (fun w ->
    (Option.get w.output).windows |> List.rev)
;;

let next_window (o : t) =
  match focused_window o with
  | None -> None
  | Some f ->
    let rec after = function
      | [ w ] when w == f -> next_tiled o.windows
      | w :: xs when w == f -> next_tiled xs
      | _ :: xs -> after xs
      | [] ->
        Logs.err (fun m -> m "Focused window isn't in output window list");
        None
    in
    after o.windows
;;

let prev_window (o : t) =
  match focused_window o with
  | None -> None
  | Some f ->
    let rec after = function
      | [ w ] when w == f -> List.rev o.windows |> prev_tiled
      | w :: xs when w == f -> prev_tiled xs
      | _ :: xs -> after xs
      | [] ->
        Logs.err (fun m -> m "Focused window isn't in output window list");
        None
    in
    List.rev o.windows |> after
;;

let remove_window ~(window : Window.t) (o : t) =
  o.windows <- List.filter (fun w -> w != window) o.windows;
  o.focus_stack <- List.filter (fun w -> w != window) o.focus_stack
;;

let tag_data (o : t) =
  match Tag_set.first o.selected_tags with
  | Some i -> o.tag_state.(i - 1)
  | None -> assert false
;;

let visible_window_count (o : t) =
  List.fold_left (fun a w -> if Window.tag_visible w then a + 1 else a) 0 o.windows
;;

let visible_windows (o : t) = List.filter Window.tag_visible o.windows

let tiled_windows (o : t) =
  List.filter (fun w -> Window.tag_visible w && Window.is_tiled w) o.windows
;;

let mark_dirty (o : t) = o.state <- O_dirty { prev = o.state }

let fullscreen_is_visible (o : t) =
  List.exists (fun w -> Window.is_fullscreen w && Window.tag_visible w) o.focus_stack
;;

let move_window (w : Window.t) (target : t) =
  let take () =
    target.windows <- w :: List.filter (fun x -> x != w) target.windows;
    target.focus_stack <- w :: List.filter (fun x -> x != w) target.focus_stack;
    w.output <- Some target
  in
  match w.output with
  | Some o when o == target -> ()
  | None -> take ()
  | Some o ->
    Option.iter (remove_window ~window:w) w.output;
    take ()
;;

let add_window ~(window : Window.t) (o : t) =
  o.windows <- window :: o.windows;
  o.focus_stack
  <- (match o.focus_stack with
      | x :: xs when Window.is_fullscreen x ->
        x :: window :: List.filter (Stdlib.( != ) window) xs
      | _ -> window :: List.filter (Stdlib.( != ) window) o.focus_stack)
;;

let set_layout_entry (o : t) ~(entry : Layout_entry.t) =
  let td = tag_data o in
  td.layout_entry <- entry
;;

let current_layout_entry (o : t) =
  let td = tag_data o in
  td.layout_entry
;;

let current_layout_params (o : t) =
  let td = tag_data o in
  td.layout_params
;;

let retile (ctx : Ctx.manage Ctx.t) (o : t) =
  if not @@ fullscreen_is_visible o
  then (
    let windows = tiled_windows o in
    let count = List.length windows in
    let tag_data = tag_data o in
    let compute = Layout.compute ~entry:tag_data.layout_entry in
    let dimensions = compute ~data:tag_data.layout_params ~area:o.usable ~count in
    match windows, dimensions with
    | _, [] when count <> 0 ->
      List.iter (fun w -> Window.restore_or_seed_float ctx w) windows
    | _, d_xs when List.length d_xs <> count ->
      let layout_name = Layout.entry_name tag_data.layout_entry in
      Logs.warn (fun m ->
        m
          "retile skipped: layout %S returned unexpected geometry count. Expected %d, \
           got %d"
          layout_name
          count
          (List.length d_xs))
    | w_xs, d_xs ->
      List.iter2 (fun w g -> Window.clamp w g |> Window.set_geom ctx w) w_xs d_xs)
;;

let switch_tags (o : t) = function
  | tags when Tag_set.is_empty tags -> ()
  | tags when Tag_set.equal tags o.selected_tags -> ()
  | tags ->
    o.previous_tags <- o.selected_tags;
    o.selected_tags <- tags
;;

let occupied_tags (o : t) =
  List.fold_left
    (fun (s : Tag_set.t) (w : Window.t) -> Tag_set.union s w.tags)
    Tag_set.empty
    o.windows
;;

let at_point ~(x : int32) ~(y : int32) =
  List.find_opt (fun (o : t) -> Utils.in_rect ~x ~y ~g:o.geom)
;;
