open! Ocdwm_core

let log_of_out = function
  | Some `Debug -> Logs.debug
  | Some `Error -> Logs.err
  | Some `Warn -> Logs.warn
  | Some `Info -> Logs.info
  | None -> Logs.debug
;;

let focused_output (seat : Types.Seat.t) f =
  match seat.output with
  | None -> Error Messages.seat_missing_output
  | Some o -> f o
;;

let named_output ~name (wm : Types.Wm.t) f =
  match Output.resolve_output_name name wm.outputs with
  | Some o -> f o
  | None -> Error (Printf.sprintf "no output named %s" name)
;;

let named_output_log ?out ~name (wm : Types.Wm.t) f =
  named_output ~name wm (fun o ->
    f o;
    Ok None)
  |> Result.iter_error @@ fun e -> log_of_out out @@ fun m -> m "%s" e
;;

let focused_output_log ?out seat f =
  focused_output seat (fun o ->
    f o;
    Ok None)
  |> Result.iter_error @@ fun e -> log_of_out out @@ fun m -> m "%s" e
;;

let focused_window seat f =
  focused_output seat
  @@ fun o ->
  match Output.focused_window o with
  | None -> Error Messages.no_focused_window
  | Some w -> f o w
;;

let focused_window_log ?out seat f =
  focused_window seat (fun o w ->
    f o w;
    Ok None)
  |> Result.iter_error @@ fun e -> log_of_out out @@ fun m -> m "%s" e
;;

let output (window : Types.Window.t) f =
  match window.output with
  | None -> Error Messages.window_missing_output
  | Some o -> f o
;;

let output_log ?out window f =
  output window (fun o ->
    f o;
    Ok None)
  |> Result.iter_error @@ fun e -> log_of_out out @@ fun m -> m "%s" e
;;
