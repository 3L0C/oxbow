(* ocdwm output - output handlers *)
[@@@landmark "auto"]

module Rwm =
  Ocdwm_protocol.River_window_management_v1_client

module Layout = Ocdwm_layout.Layout
module Rlsh = Ocdwm_protocol.River_layer_shell_v1_client
module Utils = Ocdwm_core.Utils
open Ocdwm_core.Types
open Ocdwm_config.Types
open Ocdwm_layout.Types
open Types

let destroy (o : output) =
  Rlsh.River_layer_shell_output_v1.destroy o.layer_shell;
  Wayland.Proxy.delete o.layer_shell;
  Rwm.River_output_v1.destroy o.obj;
  Wayland.Proxy.delete o.obj

let focus_window (target : window) =
  match target.output with
  | Some o ->
      o.focus_stack <-
        target
        :: List.filter (fun w -> w != target) o.focus_stack
  | None -> ()

let focused_window o =
  List.find_opt Window.tag_visible o.focus_stack

let next_tiled : window list -> window option =
  Utils.wrapped_search Window.tag_visible (fun w ->
    (Option.get w.output).windows)

let prev_tiled : window list -> window option =
  Utils.wrapped_search Window.tag_visible (fun w ->
    (Option.get w.output).windows |> List.rev)

let next_window (o : output) =
  match focused_window o with
  | None -> None
  | Some f -> begin
      let rec after = function
        | [ w ] when w == f -> next_tiled o.windows
        | w :: xs when w == f -> next_tiled xs
        | _ :: xs -> after xs
        | [] ->
            failwith
              "Focused window isn't in output window list"
      in
      after o.windows
    end

let prev_window (o : output) =
  match focused_window o with
  | None -> None
  | Some f -> begin
      let rec after = function
        | [ w ] when w == f ->
            List.rev o.windows |> prev_tiled
        | w :: xs when w == f -> prev_tiled xs
        | _ :: xs -> after xs
        | [] ->
            failwith
              "Focused window isn't in output window list"
      in
      List.rev o.windows |> after
    end

let remove_window (target : window) =
  match target.output with
  | None -> ()
  | Some o -> begin
      o.windows <-
        List.filter (fun w -> w != target) o.windows;
      o.focus_stack <-
        List.filter (fun w -> w != target) o.focus_stack
    end

let tag_data (o : output) =
  match Tag_set.first o.selected_tags with
  | Some i -> o.tag_state.(i - 1)
  | None -> assert false

let visible_window_count (o : output) =
  List.fold_left
    (fun a w -> if Window.tag_visible w then a + 1 else a)
    0 o.windows

let visible_windows (o : output) =
  List.filter Window.tag_visible o.windows

let tiled_windows (o : output) =
  List.filter
    (fun w -> Window.tag_visible w && Window.is_tiled w)
    o.windows

let mark_dirty (o : output) = o.state <- O_dirty

let mark_dirty_opt = function
  | None -> ()
  | Some (o : output) -> mark_dirty o

let fullscreen_is_visible (o : output) =
  List.exists
    (fun w ->
       Window.is_fullscreen w && Window.tag_visible w)
    o.focus_stack

let move_window (w : window) (target : output) =
  let take () =
    target.windows <-
      w :: List.filter (fun x -> x != w) target.windows;
    target.focus_stack <-
      w :: List.filter (fun x -> x != w) target.focus_stack;
    w.output <- Some target
  in
  match w.output with
  | Some o when o == target -> ()
  | None -> take ()
  | Some o -> begin
      remove_window w;
      take ()
    end

let add_window (w : window) =
  match w.output with
  | None -> ()
  | Some o -> begin
      o.windows <- w :: o.windows;
      o.focus_stack <-
        begin match o.focus_stack with
        | x :: xs when Window.is_fullscreen x ->
            x :: w :: List.filter (Stdlib.( != ) w) xs
        | _ ->
            w :: List.filter (Stdlib.( != ) w) o.focus_stack
        end
    end

let set_layout_entry (o : output) ~(entry : layout_entry) =
  let td = tag_data o in
  td.layout_entry <- entry

let current_layout_entry (o : output) =
  let td = tag_data o in
  td.layout_entry

let current_layout_params (o : output) =
  let td = tag_data o in
  td.layout_params

let retile (wm : window_manager) = function
  | None -> ()
  | Some (o : output) ->
      if not @@ fullscreen_is_visible o then begin
        let windows = tiled_windows o in
        let count = List.length windows in
        let tag_data = tag_data o in
        let compute =
          Layout.compute ~entry:tag_data.layout_entry
        in
        let dimensions =
          compute ~data:tag_data.layout_params
            ~area:o.usable ~count
        in
        match (windows, dimensions) with
        | _, [] when count <> 0 ->
            List.iter
              (fun w -> Window.restore_or_seed_float w)
              windows
        | _, d_xs when List.length d_xs <> count ->
            let layout_name =
              Layout.entry_name tag_data.layout_entry
            in
            Logs.warn (fun m ->
              m
                "Layout %S returned unexpected geometry \
                 count"
                 layout_name)
        | w_xs, d_xs ->
            List.iter2
              (fun w g ->
                 Window.clamp w g |> Window.set_geom w)
              w_xs d_xs
      end

let switch_tags (o : output) = function
  | tags when Tag_set.is_empty tags -> ()
  | tags when Tag_set.equal tags o.selected_tags -> ()
  | tags -> begin
      o.previous_tags <- o.selected_tags;
      o.selected_tags <- tags
    end

let occupied_tags (o : output) =
  List.fold_left
    (fun s w -> Tag_set.union s w.tags)
    Tag_set.empty o.windows

let at_point ~(x : int32) ~(y : int32) =
  List.find_opt (fun (o : output) ->
    Utils.in_rect ~x ~y ~g:o.geom)
