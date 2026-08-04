open! Oxbow_state
open! Oxbow_ipc

let apply (seat : Seat.t) ~name ~size = Emit.set_xcursor_theme seat.obj ~name ~size

let set_theme wm seat name size =
  Config.set_cursor_theme wm @@ Some (name, size);
  apply seat ~name ~size
;;

let handle wm seat (cmd : Command.Input.Cursor.t) =
  let () =
    match cmd with
    | Theme { name; size } -> set_theme wm seat name size
  in
  Ok None
;;
