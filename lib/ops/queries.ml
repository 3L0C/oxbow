open! Ppx_yojson_conv_lib.Yojson_conv
open! Oxbow_core
open! Oxbow_state
open! Oxbow_ipc
open! Result.Syntax

let indexed_rules conv rules =
  `List
    (List.mapi
       (fun i rule ->
          match conv rule with
          | `Assoc fields -> `Assoc (("index", `Int i) :: fields)
          | r -> r)
       rules)
;;

let handle_window_rules (wm : Wm.t) =
  let rules = indexed_rules Window_rule.yojson_of_t wm.config.rules.window in
  Ok (Some rules)
;;

let handle_keymaps wm seat all = Ok (Some (Bind.list wm seat ~all))

let handle_outputs (wm : Wm.t) (seat : Seat.t) =
  Ok
    (Some
       ([%yojson_of: Record.Output.t list] (List.map (Records.to_output seat) wm.outputs)))
;;

let handle_focused seat =
  match Records.to_focus seat with
  | None -> Ok None
  | Some record -> Ok (Some ([%yojson_of: Record.Focus.t] record))
;;

let handle_windows wm seat m =
  let+ _, matching = Window_scope.matching wm seat m in
  Some ([%yojson_of: Record.Window.t list] (List.map (Records.to_window wm) matching))
;;

let handle_tags (wm : Wm.t) output =
  let outs =
    match output with
    | None -> wm.outputs
    | Some o -> List.filter (Output.matches_name o) wm.outputs
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
                { name
                ; mode = Mode.to_string s.mode
                ; output = Option.bind s.output (fun o -> o.name)
                })
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
  let rules = indexed_rules Input_rule.yojson_of_t wm.config.rules.input in
  Ok (Some rules)
;;

let handle wm seat (query : Query.t) =
  match query with
  | Focused -> handle_focused seat
  | Input_devices { pattern; case; role } -> handle_devices wm ~pattern ~case ~role
  | Input_rules -> handle_input_rules wm
  | Keymaps { all } -> handle_keymaps wm seat all
  | Layouts _ -> handle_layouts
  | Outputs -> handle_outputs wm seat
  | Schemes _ -> handle_schemes
  | Seats -> handle_seats wm
  | Tags { output } -> handle_tags wm output
  | Window_rules -> handle_window_rules wm
  | Windows { filter } -> handle_windows wm seat filter
;;
