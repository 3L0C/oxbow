module Obj = River.Obj
module Edges = River.Window_management.River_window_v1.Edges
module Capabilities = River.Window_management.River_window_v1.Capabilities
module Modifiers = River.Window_management.River_seat_v1.Modifiers
module Presentation_mode = River.Window_management.River_output_v1.Presentation_mode
module Libinput = River.Proto.Input.Config.River_libinput_device_v1
module S = Wayland.S

val id : ('a, 'b, 'c) Wayland.Proxy.t -> int32
