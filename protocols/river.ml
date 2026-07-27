module Window_management = River_window_management_v1_client
module Layer_shell = River_layer_shell_v1_client

module Input = struct
  module Management = River_input_management_v1_client
  module Config = River_libinput_config_v1_client
end

module Xkb = struct
  module Bindings = River_xkb_bindings_v1_client
  module Config = River_xkb_config_v1_client
end

module Proto = struct
  module Window_management = River_window_management_v1_proto
  module Layer_shell = River_layer_shell_v1_proto

  module Input = struct
    module Management = River_input_management_v1_proto
    module Config = River_libinput_config_v1_proto
  end

  module Xkb = struct
    module Bindings = River_xkb_bindings_v1_proto
    module Config = River_xkb_config_v1_proto
  end
end

module Server = struct
  module Window_management = River_window_management_v1_server
  module Layer_shell = River_layer_shell_v1_server

  module Input = struct
    module Management = River_input_management_v1_server
    module Config = River_libinput_config_v1_server
  end

  module Xkb = struct
    module Bindings = River_xkb_bindings_v1_server
    module Config = River_xkb_config_v1_server
  end
end

module Obj = struct
  module Window_management = struct
    type v = [ `V4 ]

    module Wm = struct
      type t = v River_window_management_v1_client.River_window_manager_v1.t
    end

    module Pointer_binding = struct
      type t = v River_window_management_v1_client.River_pointer_binding_v1.t
    end

    module Seat = struct
      type t = v River_window_management_v1_client.River_seat_v1.t
    end

    module Output = struct
      type t = v River_window_management_v1_client.River_output_v1.t
    end

    module Window = struct
      type t = v River_window_management_v1_client.River_window_v1.t
    end

    module Node = struct
      type t = v River_window_management_v1_client.River_node_v1.t
    end
  end

  module Layer_shell = struct
    type v = [ `V1 ]

    module Output = struct
      type t = v River_layer_shell_v1_client.River_layer_shell_output_v1.t
    end

    module Seat = struct
      type t = v River_layer_shell_v1_client.River_layer_shell_seat_v1.t
    end

    type t = v River_layer_shell_v1_client.River_layer_shell_v1.t
  end

  module Xkb = struct
    module Bindings = struct
      type v = [ `V2 ]

      module Binding = struct
        type t = v River_xkb_bindings_v1_client.River_xkb_binding_v1.t
      end

      module Seat = struct
        type t = v River_xkb_bindings_v1_client.River_xkb_bindings_seat_v1.t
      end

      type t = v River_xkb_bindings_v1_client.River_xkb_bindings_v1.t
    end

    module Config = struct
      type v = [ `V1 ]

      module Keyboard = struct
        type t = v River_xkb_config_v1_client.River_xkb_keyboard_v1.t
      end

      module Keymap = struct
        type t = v River_xkb_config_v1_client.River_xkb_keymap_v1.t
      end

      type t = v River_xkb_config_v1_client.River_xkb_config_v1.t
    end
  end

  module Input = struct
    module Config = struct
      type v = [ `V2 ]
      type t = v River_libinput_config_v1_client.River_libinput_config_v1.t
    end

    module Management = struct
      type v = [ `V1 ]

      module Device = struct
        type t = v River_input_management_v1_client.River_input_device_v1.t
      end

      type t = v River_input_management_v1_client.River_input_manager_v1.t
    end
  end
end
