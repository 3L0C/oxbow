(* ocdwm output - output handlers *)
module Rwm =
  Ocdwm_protocol.River_window_management_v1_client

let destroy = Rwm.River_output_v1.destroy
