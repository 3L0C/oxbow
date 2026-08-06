open! Oxbow_state

let window_add seat label =
  With.focused_window seat
  @@ fun _o w ->
  Window.add_label w label;
  Ok None
;;

let window_remove seat label =
  With.focused_window seat
  @@ fun _o w ->
  Window.remove_label w label;
  Ok None
;;

let output_add seat label =
  With.focused_output seat
  @@ fun o ->
  Output.add_label o label;
  Ok None
;;

let output_remove seat label =
  With.focused_output seat
  @@ fun o ->
  Output.remove_label o label;
  Ok None
;;
