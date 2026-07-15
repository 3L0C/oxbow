open! Ocdwm_core
open! Ocdwm_state

let channels c =
  let byte shift =
    let b = Int32.(shift_right_logical c shift |> logand 0xFFl) in
    Int32.mul b 0x01010101l
  in
  byte 24, byte 16, byte 8, byte 0
;;

let paint ctx =
  let wm = Ctx.wm ctx in
  let borders = wm.config.borders in
  let color (w : Window.t) o =
    if w.is_urgent
    then borders.urgent_color
    else if Phys.opt_holds (Output.focused_window o) w
    then borders.focused_color
    else borders.unfocused_color
  in
  let edges =
    let open River.Window_management.River_window_v1.Edges in
    Int32.(logor left right |> logor top |> logor bottom)
  in
  let width = borders.width in
  List.iter
    (fun (w : Window.t) ->
       match w.output with
       | None -> ()
       | Some o ->
         let r, g, b, a = color w o |> channels in
         River.Window_management.River_window_v1.set_borders
           w.obj
           ~edges
           ~width
           ~r
           ~g
           ~b
           ~a)
    wm.windows
;;
