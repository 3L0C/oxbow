open! Ocdwm_core
open! Ocdwm_state

let paint ctx (seat : Seat.t) =
  let wm = Ctx.wm ctx in
  let borders = wm.config.borders in
  let color (w : Window.t) o =
    if w.is_urgent
    then borders.urgent_color
    else if not @@ Phys.opt_holds o seat.output
    then borders.unfocused_color
    else if Phys.opt_holds w (Output.focused_window o)
    then borders.focused_color
    else borders.unfocused_color
  in
  let edges =
    let open Wire in
    Int32.(logor Edges.left Edges.right |> logor Edges.top |> logor Edges.bottom)
  in
  let width = borders.width in
  List.iter
    (fun (w : Window.t) ->
       match w.output with
       | None -> ()
       | Some o ->
         let r, g, b, a = color w o |> Color.channels in
         Send.set_borders ctx w ~edges ~width ~r ~g ~b ~a)
    wm.windows
;;
