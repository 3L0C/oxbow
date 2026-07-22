open! Ppx_yojson_conv_lib.Yojson_conv
open! Ocdwm_core
open! Ocdwm_state
open! Ocdwm_ipc
open! Ocdwm_layout

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

let handle_windows (wm : Wm.t) query =
  let matcher =
    match query with
    | None -> Ok (fun ~title:_ ~app_id:_ ~identifier:_ -> true)
    | Some q -> Window_query.compile q
  in
  match matcher with
  | Error _ as e -> e
  | Ok m ->
    Ok
      (Some
         ([%yojson_of: Record.Window.t list]
            (List.filter
               (fun (w : Window.t) ->
                  m ~title:w.title ~app_id:w.app_id ~identifier:w.identifier)
               wm.windows
             |> List.map (Records.to_window wm))))
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
  | Windows { query } -> handle_windows wm query
  | Tags { output } -> handle_tags wm output
  | Layouts { output } -> handle_layouts
  | Schemes { output } -> handle_schemes
  | Seats -> handle_seats wm
;;
