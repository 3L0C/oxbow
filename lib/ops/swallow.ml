open! Oxbow_core
open! Oxbow_state

let read_parent_pid pid =
  let path = Printf.sprintf "/proc/%d/stat" pid in
  match In_channel.with_open_text path In_channel.input_line with
  | exception Sys_error _ -> None
  | None -> None
  | Some line ->
    (match String.rindex_opt line ')' with
     | None -> None
     | Some i ->
       let rest = String.sub line (i + 1) (String.length line - i - 1) in
       let fields = String.split_on_char ' ' rest |> List.filter (fun s -> s <> "") in
       Option.bind (List.nth_opt fields 1) int_of_string_opt)
;;

let parent_pid = ref read_parent_pid

let ancestors pid =
  let rec walk depth pid' =
    if depth = 0
    then []
    else (
      match !parent_pid pid' with
      | None -> []
      | Some p -> p :: walk (depth - 1) p)
  in
  walk 64 pid
;;

let find_host (wm : Wm.t) (child : Window.t) =
  let chain =
    match child.unreliable_pid with
    | Some p -> ancestors (Int32.to_int p)
    | None -> []
  in
  let eligible w =
    Window.can_swallow w
    && Window.is_tiled w
    && Phys.opt_equal w.output child.output
    && Tag.Set.intersects w.tags child.tags
    &&
    match w.unreliable_pid with
    | Some p -> List.mem (Int32.to_int p) chain
    | None -> false
  in
  List.find_opt eligible wm.windows
;;

let swallow ~(host : Window.t) ~child =
  Window.set_tags child host.tags;
  Option.iter (Stacking.replace ~old_w:host ~new_w:child) host.output;
  Window.swallow ~host ~child
;;

let try_swallow (wm : Wm.t) (child : Window.t) =
  let eligible =
    (match child.unreliable_pid with
     | Some pid -> Int32.to_int pid > 0
     | None -> false)
    && child.swallow.role = Auto
    && Option.is_none child.swallow.relation
    && Window.is_tiled child
    && Option.is_none child.parent
    && child.sticky = Off
    && Option.is_some child.output
  in
  if eligible
  then (
    match find_host wm child with
    | None -> ()
    | Some host -> swallow ~host ~child)
;;

let unswallow (child : Window.t) =
  match child.swallow.relation with
  | None | Some (Swallowed_by _) -> ()
  | Some (Swallowing host) ->
    Window.set_tags host child.tags;
    (match child.output with
     | None -> ()
     | Some o ->
       Stacking.replace ~old_w:child ~new_w:host o;
       Stacking.push [ child ] o;
       if Window.floats host o then Window.restore_float host);
    Window.set_swallow_relation host None;
    Window.set_swallow_relation child None
;;

let on_close (w : Window.t) =
  match w.swallow.relation with
  | None -> ()
  | Some (Swallowing _) -> unswallow w
  | Some (Swallowed_by child) ->
    Window.set_swallow_relation child None;
    Window.set_swallow_relation w None
;;

let toggle wm seat target =
  Result.map (fun _ -> None)
  @@ Targets.transact_all_windows wm seat target ~plan:(fun w ->
    match w.swallow.relation, w.swallow.role with
    | Some (Swallowing _), _ -> Ok (fun () -> unswallow w)
    | Some (Swallowed_by _), _ | None, (Terminal | Disabled) -> Ok ignore
    | None, Auto -> Ok (fun () -> try_swallow wm w))
;;
