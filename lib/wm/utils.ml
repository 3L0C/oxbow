open Types

(** [is_visible] is true if [o_tags] and [w_tags] share any active bits in common *)
let is_visible o_tags w_tags =
  Int32.logand o_tags w_tags <> 0l

(** [visible_windows] is a list of all the currently visible windows on [output]. *)
let visible_windows output =
  List.filter
    (fun w -> is_visible output.selected_tags w.tags)
    output.windows

(** [next_window] is the next visible window in the output after [current]. *)
let next_window output current =
  let windows = visible_windows output in
  let rec aux = function
    (* When current is the last element, focus the head. May be the same window as current *)
    | x :: [] when x == current -> List.hd windows
    (* Focus the next window in the stack *)
    | x :: xs when x == current -> List.hd xs
    (* Recurse *)
    | _ :: xs -> aux xs
    (* This would only happen if [window] is on an inactive tag
     * or on a different output and tag to that of [output.selected_tags] *)
    | [] -> failwith "Current window is not on an output"
  in
  aux windows
