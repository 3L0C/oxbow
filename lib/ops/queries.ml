open! Ppx_yojson_conv_lib.Yojson_conv
open! Oxbow_core
open! Oxbow_state
open! Oxbow_ipc

let handle_window_rules (wm : Wm.t) =
  Ok (Some ([%yojson_of: Window_rule.t list] wm.config.rules.window))
;;

let handle_keymaps wm seat all = Ok (Some (Bind.list wm seat ~all))

let handle_outputs (wm : Wm.t) =
  Ok
    (Some
       ([%yojson_of: string list]
          (List.filter_map (fun (o : Output.t) -> o.name) wm.outputs)))
;;

let handle_focused seat =
  match Records.to_focus seat with
  | None -> Ok None
  | Some record -> Ok (Some ([%yojson_of: Record.Focus.t] record))
;;

let handle_windows wm seat m =
  match Window_scope.matching wm seat m with
  | Error _ as e -> e
  | Ok (_, matching) ->
    Ok
      (Some
         ([%yojson_of: Record.Window.t list] (List.map (Records.to_window wm) matching)))
;;

let handle_tags (wm : Wm.t) output =
  let outs =
    match output with
    | None -> wm.outputs
    | Some o ->
      List.filter
        (fun (o' : Output.t) ->
           Option.fold ~none:false ~some:(fun name -> name = o) o'.name)
        wm.outputs
  in
  let records = List.filter_map Records.to_tags outs in
  Ok (Some ([%yojson_of: Record.Tags.t list] records))
;;

let handle_layouts =
  let available = List.map Layout.to_string Layout.all in
  Ok (Some (Query.Reply.Available.yojson_of_t { available }))
;;

let handle_schemes =
  let available = List.map Scheme.to_string Scheme.all in
  Ok (Some (Query.Reply.Available.yojson_of_t { available }))
;;

let handle_seats (wm : Wm.t) =
  let records =
    List.filter_map
      (fun (s : Seat.t) ->
         Option.map
           (fun name ->
              Query.Reply.Seats.
                { name; mode = s.mode; output = Option.bind s.output (fun o -> o.name) })
           s.name)
      wm.seats
  in
  Ok (Some ([%yojson_of: Query.Reply.Seats.t list] records))
;;

let handle_devices (wm : Wm.t) ~pattern ~case ~role =
  let records =
    List.filter_map
      (fun (device : Input_device.t) ->
         if Input_device.matches device ~pattern ~case ~role
         then
           Some
             Query.Reply.Input_device.
               { name = device.name; role = Input_device.role_to_string device.role }
         else None)
      wm.input_devices
  in
  Ok (Some ([%yojson_of: Query.Reply.Input_device.t list] records))
;;

let handle_input_rules (wm : Wm.t) =
  Ok (Some ([%yojson_of: Input_rule.t list] wm.config.rules.input))
;;

let handle wm seat (query : Query.t) =
  match query with
  | Focused -> handle_focused seat
  | Input_devices { pattern; case; role } -> handle_devices wm ~pattern ~case ~role
  | Input_rules -> handle_input_rules wm
  | Keymaps { all } -> handle_keymaps wm seat all
  | Layouts _ -> handle_layouts
  | Outputs -> handle_outputs wm
  | Schemes _ -> handle_schemes
  | Seats -> handle_seats wm
  | Tags { output } -> handle_tags wm output
  | Window_rules -> handle_window_rules wm
  | Windows { filter } -> handle_windows wm seat filter
;;
