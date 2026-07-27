open! Ocdwm_state
open! Ocdwm_ipc

let apply = Emit.set_xcursor_theme

let set_theme wm seat name size =
  Config.set_cursor_theme wm @@ Some (name, size);
  apply seat ~name ~size
;;

let handle (ctx : Ctx.manage Ctx.t) seat (cmd : Command.Input.Cursor.t) =
  let () =
    match cmd with
    | Theme { name; size } -> set_theme (Ctx.wm ctx) seat name size
  in
  Ok None
;;
