module Input_management = Ocdwm_protocol.River_input_management_v1_client
module Layer_shell = Ocdwm_protocol.River_layer_shell_v1_client
module Input_config = Ocdwm_protocol.River_libinput_config_v1_client
module Window_management = Ocdwm_protocol.River_window_management_v1_client
module Xkb_bindings = Ocdwm_protocol.River_xkb_bindings_v1_client
module Xkb_config = Ocdwm_protocol.River_xkb_config_v1_client

module V : sig
  module Input_management : sig
    type t = [ `V1 ]
  end

  module Layer_shell : sig
    type t = [ `V1 ]
  end

  module Input_config : sig
    type t = [ `V1 ]
  end

  module Window_management : sig
    type t = [ `V4 ]
  end

  module Xkb_bindings : sig
    type t = [ `V2 ]
  end

  module Xkb_config : sig
    type t = [ `V1 ]
  end
end
