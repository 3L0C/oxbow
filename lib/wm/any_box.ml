type t =
  | Output_box of Types.Output.t Box.t
  | Window_box of Types.Window.t Box.t
  | Wm_box of Types.Window_manager.t Box.t
  | Seat_box of Types.Seat.t Box.t
