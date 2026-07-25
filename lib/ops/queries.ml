open! Ppx_yojson_conv_lib.Yojson_conv
open! Ocdwm_core
open! Ocdwm_state
open! Ocdwm_ipc

let handle_rules (wm : Wm.t) = Ok (Some ([%yojson_of: Rule.t list] wm.config.rules))
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

let handle_windows (wm : Wm.t) seat m =
  match Window_match.compile m with
  | Error e -> Error e
  | Ok matches ->
    (match Window_scope.filter wm seat m.scope with
     | Error e -> Error e
     | Ok windows ->
       Ok
         (Some
            ([%yojson_of: Record.Window.t list]
               (List.filter
                  (fun (w : Window.t) ->
                     matches ~title:w.title ~app_id:w.app_id ~identifier:w.identifier)
                  windows
                |> List.map (Records.to_window wm)))))
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
  Ok (Some (Query.Reply.Layouts.yojson_of_t { available }))
;;

let handle_schemes =
  let available = List.map Scheme.to_string Scheme.all in
  Ok (Some (Query.Reply.Schemes.yojson_of_t { available }))
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

let handle wm seat (query : Query.t) =
  match query with
  | Rules -> handle_rules wm
  | Keymaps { all } -> handle_keymaps wm seat all
  | Outputs -> handle_outputs wm
  | Focused -> handle_focused seat
  | Windows { filter } -> handle_windows wm seat filter
  | Tags { output } -> handle_tags wm output
  | Layouts _ -> handle_layouts
  | Schemes _ -> handle_schemes
  | Seats -> handle_seats wm
;;
