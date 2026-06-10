let channels (c : int32) =
  let byte shift =
    let b = Int32.(shift_right_logical c shift |> logand 0xFFl) in
    Int32.mul b 0x01010101l
  in
  byte 24, byte 16, byte 8, byte 0
;;

(* FIXME we need to rethink border coloring/updating since this sticks around
   and is part of the window itself. Also, we need to read the xml more carefully
   when using new calls *)
let paint (ctx : Ctx.render Ctx.t) (output : Types.Output.t) =
  let wm = Ctx.wm ctx in
  let borders = wm.config.borders in
  let focused = Output.focused_window output in
  List.iter
    (fun (w : Types.Window.t) ->
       let color =
         if w.is_urgent
         then borders.urgent_color
         else (
           match focused with
           | Some f when f == w -> borders.focused_color
           | _ -> borders.unfocused_color)
       in
       let edges =
         let open River.Window_management.River_window_v1.Edges in
         Int32.(logor left right |> logor top |> logor bottom)
       in
       let width = borders.width in
       let r, g, b, a = channels color in
       River.Window_management.River_window_v1.set_borders w.obj ~edges ~width ~r ~g ~b ~a)
    wm.windows
;;
