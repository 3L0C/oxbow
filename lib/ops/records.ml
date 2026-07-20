open! Ocdwm_core
open! Ocdwm_ipc
open! Ocdwm_state
open! Ocdwm_layout

let to_tags (output : Output.t) =
  match output.name with
  | None -> None
  | Some name ->
    Some
      Record.Tags.
        { output = name
        ; viewed = Tag.Set.to_list output.selected_tags
        ; occupied = Output.occupied_tags output |> Tag.Set.to_list
        ; urgent = Output.urgent_tags output |> Tag.Set.to_list
        ; focused =
            Output.focused_window output
            |> Option.fold ~none:[] ~some:(fun (w : Window.t) -> Tag.Set.to_list w.tags)
        }
;;

let to_window (wm : Wm.t) (window : Window.t) =
  Record.Window.
    { id = 1
    ; identifier = window.identifier
    ; title = window.title
    ; app_id = window.app_id
    ; output = Option.bind window.output (fun o -> o.name)
    ; tags = Tag.Set.to_list window.tags
    ; focused =
        (match window.output with
         | None -> false
         | Some o -> List.exists (fun (s : Seat.t) -> Phys.opt_holds o s.output) wm.seats)
    ; urgent = window.is_urgent
    ; hidden = window.is_hidden
    ; presentation = Window.presentation_string window
    }
;;

let to_layout (output : Output.t) =
  match output.name with
  | None -> None
  | Some name ->
    let entry = Output.current_layout_entry output in
    Some
      Record.Layout.
        { output = name
        ; layout = Entry.name entry
        ; symbol = Entry.symbol (Output.current_layout_ctx output) entry
        ; arrangement = Arrangement.to_string output.arrangement
        }
;;

let to_mode (seat : Seat.t) =
  match seat.name with
  | None -> None
  | Some name -> Some Record.Mode.{ seat = name; mode = seat.mode }
;;

let to_focus (seat : Seat.t) =
  match seat.name with
  | None -> None
  | Some name ->
    let focused_window = Option.bind seat.output Output.focused_window in
    Some
      Record.Focus.
        { seat = name
        ; output = Option.bind seat.output (fun o -> o.name)
        ; title = Option.bind focused_window (fun w -> w.title)
        ; app_id = Option.bind focused_window (fun w -> w.app_id)
        ; tags = Option.bind focused_window (fun w -> Some (Tag.Set.to_list w.tags))
        }
;;
