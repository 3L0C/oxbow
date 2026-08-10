open! Oxbow_core
open! Oxbow_ipc
open! Oxbow_state
open! Oxbow_layout

let to_tags (output : Output.t) =
  match output.name with
  | None -> None
  | Some name ->
    Some
      Record.Tags.
        { output = name
        ; viewed = Tag.Set.to_index_list output.tags.selected
        ; occupied = Output.occupied_tags output |> Tag.Set.to_index_list
        ; urgent = Output.urgent_tags output |> Tag.Set.to_index_list
        ; focused =
            Output.focused_window output
            |> Option.fold ~none:[] ~some:(fun (w : Window.t) ->
              Tag.Set.to_index_list w.tags)
        }
;;

let to_window (wm : Wm.t) (window : Window.t) =
  Record.Window.
    { id = window.id
    ; identifier = window.identifier
    ; title = window.title
    ; app_id = window.app_id
    ; output = Option.bind window.output (fun o -> o.name)
    ; tags = Tag.Set.to_index_list window.tags
    ; focused =
        List.exists (Fun.compose (Phys.opt_holds window) Seat.focused_window) wm.seats
    ; urgent = window.is_urgent
    ; captured = window.is_captured
    ; hidden = not @@ Window.is_rendered window
    ; presentation = Window.presentation_string window
    ; sticky = Sticky.to_string window.sticky
    ; scratchpad = window.scratchpad.name
    ; stashed = window.scratchpad.stashed
    ; swallowing = Window.swallowing window
    ; labels = window.labels
    }
;;

let to_output (seat : Seat.t) (output : Output.t) =
  Record.Output.
    { name = output.name
    ; labels = output.labels
    ; focused = Phys.opt_holds output seat.output
    ; captured = output.is_captured
    }
;;

let to_layout (output : Output.t) =
  match output.name with
  | None -> None
  | Some name ->
    let td = Output.to_tag_data output in
    let visible = Output.visible_windows output in
    let focused_index =
      match Output.focused_window output with
      | None -> 0
      | Some w -> List.find_index (( == ) w) visible |> Option.value ~default:0
    in
    let ctx = Symbol.Ctx.{ focused_index; count = List.length visible } in
    Some
      Record.Layout.
        { output = name
        ; layout = Layout.to_string td.layout
        ; scheme =
            (match td.layout with
             | Tiling -> Some (Scheme.to_string td.tiling.scheme)
             | Scrolling | Floating -> None)
        ; symbol =
            Symbol.render
              td.layout
              ~scheme:td.tiling.scheme
              ~align:td.scrolling.align
              ~ctx
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
        ; tags = Option.bind focused_window (fun w -> Some (Tag.Set.to_index_list w.tags))
        }
;;
