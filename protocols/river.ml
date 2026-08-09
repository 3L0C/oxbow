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
    type v = [ `V5 ]

    let version = 5l

    module C = River_window_management_v1_client

    module Server = struct
      module S = River_window_management_v1_server

      class virtual ['v] decoration = ['v] S.River_decoration_v1.v5
      class virtual ['v] node = ['v] S.River_node_v1.v5
      class virtual ['v] output = ['v] S.River_output_v1.v5
      class virtual ['v] pointer_binding = ['v] S.River_pointer_binding_v1.v5
      class virtual ['v] seat = ['v] S.River_seat_v1.v5
      class virtual ['v] shell_surface = ['v] S.River_shell_surface_v1.v5
      class virtual ['v] window = ['v] S.River_window_v1.v5
      class virtual ['v] t = ['v] S.River_window_manager_v1.v5
    end

    module Client = struct
      class virtual ['v] node = ['v] C.River_node_v1.v5
      class virtual ['v] output = ['v] C.River_output_v1.v5
      class virtual ['v] pointer_binding = ['v] C.River_pointer_binding_v1.v5
      class virtual ['v] seat = ['v] C.River_seat_v1.v5
      class virtual ['v] window = ['v] C.River_window_v1.v5
      class virtual ['v] t = ['v] C.River_window_manager_v1.v5
    end

    module Pointer_binding = struct
      type t = v C.River_pointer_binding_v1.t
    end

    module Seat = struct
      type t = v C.River_seat_v1.t
    end

    module Output = struct
      type t = v C.River_output_v1.t
    end

    module Window = struct
      type t = v C.River_window_v1.t
    end

    module Node = struct
      type t = v C.River_node_v1.t
    end

    type t = v C.River_window_manager_v1.t
  end

  module Layer_shell = struct
    type v = [ `V1 ]

    let version = 1l

    module C = River_layer_shell_v1_client

    module Server = struct
      module S = River_layer_shell_v1_server

      class virtual ['v] output = ['v] S.River_layer_shell_output_v1.v1
      class virtual ['v] seat = ['v] S.River_layer_shell_seat_v1.v1
      class virtual ['v] t = ['v] S.River_layer_shell_v1.v1
    end

    module Client = struct
      class virtual ['v] output = ['v] C.River_layer_shell_output_v1.v1
      class virtual ['v] seat = ['v] C.River_layer_shell_seat_v1.v1
      class virtual ['v] t = ['v] C.River_layer_shell_v1.v1
    end

    module Output = struct
      type t = v C.River_layer_shell_output_v1.t
    end

    module Seat = struct
      type t = v C.River_layer_shell_seat_v1.t
    end

    type t = v C.River_layer_shell_v1.t
  end

  module Xkb = struct
    module Bindings = struct
      type v = [ `V3 ]

      let version = 3l

      module C = River_xkb_bindings_v1_client

      module Server = struct
        module S = River_xkb_bindings_v1_server

        class virtual ['v] binding = ['v] S.River_xkb_binding_v1.v3
        class virtual ['v] seat = ['v] S.River_xkb_bindings_seat_v1.v3
        class virtual ['v] t = ['v] S.River_xkb_bindings_v1.v3
      end

      module Client = struct
        class virtual ['v] binding = ['v] C.River_xkb_binding_v1.v3
        class virtual ['v] seat = ['v] C.River_xkb_bindings_seat_v1.v3
        class virtual ['v] t = ['v] C.River_xkb_bindings_v1.v3
      end

      module Binding = struct
        type t = v C.River_xkb_binding_v1.t
      end

      module Seat = struct
        type t = v C.River_xkb_bindings_seat_v1.t
      end

      type t = v C.River_xkb_bindings_v1.t
    end

    module Config = struct
      type v = [ `V2 ]

      let version = 2l

      module C = River_xkb_config_v1_client

      module Server = struct
        module S = River_xkb_config_v1_server

        class virtual ['v] keyboard = ['v] S.River_xkb_keyboard_v1.v2
        class virtual ['v] keymap = ['v] S.River_xkb_keymap_v1.v2
        class virtual ['v] t = ['v] S.River_xkb_config_v1.v2
      end

      module Client = struct
        class virtual ['v] keyboard = ['v] C.River_xkb_keyboard_v1.v2
        class virtual ['v] keymap = ['v] C.River_xkb_keymap_v1.v2
        class virtual ['v] t = ['v] C.River_xkb_config_v1.v2
      end

      module Keyboard = struct
        type t = v C.River_xkb_keyboard_v1.t
      end

      module Keymap = struct
        type t = v C.River_xkb_keymap_v1.t
      end

      type t = v C.River_xkb_config_v1.t
    end
  end

  module Input = struct
    module Config = struct
      type v = [ `V2 ]

      let version = 2l

      module C = River_libinput_config_v1_client

      module Server = struct
        module S = River_libinput_config_v1_server

        class virtual ['v] accel_config = ['v] S.River_libinput_accel_config_v1.v1
        class virtual ['v] device = ['v] S.River_libinput_device_v1.v2
        class virtual ['v] result = ['v] S.River_libinput_result_v1.v1
        class virtual ['v] t = ['v] S.River_libinput_config_v1.v2
      end

      module Client = struct
        class virtual ['v] accel_config = ['v] C.River_libinput_accel_config_v1.v1
        class virtual ['v] device = ['v] C.River_libinput_device_v1.v2
        class virtual ['v] result = ['v] C.River_libinput_result_v1.v1
        class virtual ['v] t = ['v] C.River_libinput_config_v1.v2
      end

      module Device = struct
        type t = v C.River_libinput_device_v1.t
      end

      module Result = struct
        type t = v C.River_libinput_result_v1.t
      end

      type t = v C.River_libinput_config_v1.t
    end

    module Management = struct
      type v = [ `V2 ]

      let version = 2l

      module C = River_input_management_v1_client

      module Server = struct
        module S = River_input_management_v1_server

        class virtual ['v] device = ['v] S.River_input_device_v1.v2
        class virtual ['v] t = ['v] S.River_input_manager_v1.v2
      end

      module Client = struct
        class virtual ['v] device = ['v] C.River_input_device_v1.v2
        class virtual ['v] t = ['v] C.River_input_manager_v1.v2
      end

      module Device = struct
        type t = v C.River_input_device_v1.t
      end

      type t = v C.River_input_manager_v1.t
    end
  end
end
