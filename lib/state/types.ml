module Key = struct
  type t =
    | Keysym of Xkbcommon.Keysym.t
    | Pointer of Ocdwm_core.Pointer_button.t
end

module Config = struct
  module Border = struct
    type t =
      { mutable width : int32
      ; mutable focused_color : int32
      ; mutable unfocused_color : int32
      ; mutable urgent_color : int32
      }
  end

  module Data = struct
    type t =
      { params : Ocdwm_layout.Params.t
      ; mutable entry : Ocdwm_layout.Entry.t
      }
  end

  type t =
    { default_tag_config : Data.t
    ; borders : Border.t
    ; mutable cursor_theme : (string * int32) option
    ; mutable modkey : River.Window_management.River_seat_v1.Modifiers.t
    ; mutable rules : Ocdwm_core.Rule.t list
    ; mutable focus_follows_pointer : bool
    ; mutable warp_on_focus : bool
    ; mutable repeat_rate : int
    ; mutable repeat_delay : int
    }
end

module rec Input_device : sig
  module Lifecycle : sig
    type t =
      | Active
      | Removed
  end

  module Device : sig
    type t = River.V.Input_management.t River.Input_management.River_input_device_v1.t
  end

  module Kind : sig
    type t = River.Input_management.River_input_device_v1.Type.t
  end

  module Xkb : sig
    type t = River.V.Xkb_config.t River.Xkb_config.River_xkb_keyboard_v1.t
  end

  module Role : sig
    type t =
      | Keyboard of { mutable xkb : Xkb.t option }
      | Pointer
      | Touch
      | Tablet
  end

  type t =
    { device : Device.t
    ; name : string
    ; role : Role.t
    ; mutable lifecycle : Lifecycle.t
    }
end =
  Input_device

and Output : sig
  module Lifecycle : sig
    type t =
      | Active
      | Dirty of { prev : t }
      | Removed
  end

  type t =
    { (* Wayland objects *)
      obj : River.V.Window_management.t River.Window_management.River_output_v1.t
    ; layer_shell : River.V.Layer_shell.t River.Layer_shell.River_layer_shell_output_v1.t
    ; (* Lifecycle *)
      mutable lifecycle : Lifecycle.t
    ; (* Identity *)
      mutable name : string option
    ; (* Geometry *)
      mutable geom : int32 Ocdwm_core.Rect.t
    ; (* Usable area *)
      mutable usable : int Ocdwm_core.Rect.t
    ; (* Tag state *)
      mutable selected_tags : Ocdwm_core.Tag.Set.t
    ; mutable previous_tags : Ocdwm_core.Tag.Set.t
    ; (* Per-tag layout configuration *)
      tag_data : Config.Data.t array
    ; (* Focus stack - most recently focused first *)
      mutable focus_stack : Window.t list
    ; (* All windows on this output. Ordered in tiling order when filtered by
         selected_tags *)
      mutable wm_stack : Window.t list
    }
end =
  Output

and Window : sig
  module Lifecycle : sig
    type t =
      | New
      | Active
      | Closing

    val to_string : t -> string
  end

  module Request : sig
    type t =
      | Move of { seat : Seat.t }
      | Resize of
          { seat : Seat.t
          ; edges : int32
          }
      | Maximize
      | Unmaximize
      | Fake_fullscreen
      | Exit_fake_fullscreen
      | Fullscreen of { output : Output.t option }
      | Exit_fullscreen
      | Dimensions of
          { width : int32
          ; height : int32
          }
      | Set_tags of Ocdwm_core.Tag.Arg.t
      | Send_to_output_name of
          { name : string
          ; policy : Ocdwm_core.Tag.Policy.t
          }
      | Float
      | Tile
  end

  module Presentation : sig
    module Tile_or_float : sig
      type t =
        [ `Tiled
        | `Floating
        ]
    end

    module Fullscreen_prior : sig
      type t =
        [ Tile_or_float.t
        | `Maximized of Tile_or_float.t
        ]
    end

    type t =
      | Tiled
      | Floating
      | Maximized of { restore : Tile_or_float.t }
      | Fullscreen of { restore : Fullscreen_prior.t }
  end

  module Size_hints : sig
    type 'a t =
      { min_w : 'a
      ; max_w : 'a
      ; min_h : 'a
      ; max_h : 'a
      }
  end

  module Decoration_hint : sig
    type t =
      | Only_csd
      | Prefer_csd
      | Prefer_ssd
      | No_preference
  end

  type t =
    { (* Wayland objects *)
      obj : River.V.Window_management.t River.Window_management.River_window_v1.t
    ; node : River.V.Window_management.t River.Window_management.River_node_v1.t
    ; (* Lifecycle *)
      mutable lifecycle : Lifecycle.t
    ; (* State *)
      id : int
    ; mutable app_id : string option
    ; mutable title : string option
    ; mutable identifier : string option
    ; mutable unreliable_pid : int32 option
    ; mutable parent : Window.t Box.t
    ; mutable decoration_hint : Decoration_hint.t option
    ; mutable presentation_hint :
        River.Window_management.River_output_v1.Presentation_mode.t option
    ; (* Geometry *)
      mutable geom : int32 Ocdwm_core.Rect.t
    ; mutable float_geom : int32 Ocdwm_core.Rect.t option
    ; (* Size hints from dimensions_hint *)
      mutable size_hints : int32 Size_hints.t
    ; (* Tag and output assignment *)
      mutable tags : Ocdwm_core.Tag.Set.t
    ; mutable output : Output.t option
    ; (* State flags *)
      mutable is_fixed : bool
    ; mutable is_urgent : bool
    ; mutable is_fake_fullscreen : bool
    ; mutable is_hidden : bool
    ; mutable presentation : Presentation.t
    ; (* Pointer op state *)
      mutable requests : Request.t list
    }
end =
  Window

and Seat : sig
  module Lifecycle : sig
    type t =
      | New
      | Active
      | Dirty of { prev : t }
      | Closing
  end

  module Layer_focus : sig
    type t =
      | Non_exclusive
      | Exclusive
  end

  module Position : sig
    type t =
      { x : int32
      ; y : int32
      }
  end

  module Focus_state : sig
    type t =
      | Idle
      | Refresh of Window.t
      | Clear
  end

  module Op : sig
    type t =
      | Move of
          { window : Window.t
          ; start_x : int32
          ; start_y : int32
          ; mutable dx : int32
          ; mutable dy : int32
          ; mutable release : bool
          }
      | Resize of
          { window : Window.t
          ; start_x : int32
          ; start_y : int32
          ; start_w : int32
          ; start_h : int32
          ; edges : int32
          ; mutable dx : int32
          ; mutable dy : int32
          ; mutable release : bool
          }
  end

  module Xkb_binding : sig
    type t =
      { obj : River.V.Xkb_bindings.t River.Xkb_bindings.River_xkb_binding_v1.t
      ; seat : Seat.t
      ; command : Ocdwm_ipc.Command.t
      ; mods : int32
      ; keysym : Xkbcommon.Keysym.t
      }
  end

  module Pointer_binding : sig
    type t =
      { obj :
          River.V.Window_management.t River.Window_management.River_pointer_binding_v1.t
      ; seat : Seat.t
      ; command : Ocdwm_ipc.Command.t
      ; mods : int32
      ; button : Ocdwm_core.Pointer_button.t
      }
  end

  type t =
    { (* Wayland objects *)
      obj : River.V.Window_management.t River.Window_management.River_seat_v1.t
    ; layer_shell : River.V.Layer_shell.t River.Layer_shell.River_layer_shell_seat_v1.t
    ; (* Lifecycle *)
      mutable lifecycle : Lifecycle.t
    ; (* Identity *)
      mutable name : string option
    ; (* State *)
      mutable output : Output.t option
    ; mutable position : Position.t
    ; mutable layer_focus : Layer_focus.t option
    ; (* Keybindings *)
      mutable xkb_bindings : Xkb_binding.t list
    ; mutable pointer_bindings : Pointer_binding.t list
    ; mutable pending_requests : Pending_request.t Queue.t
    ; (* Pointer state *)
      mutable hovered : Window.t option
    ; mutable interacted : Window.t option
    ; mutable focus_state : Focus_state.t
    ; mutable cursor_target : Window.t option
    ; (* Interactive op state *)
      mutable op : Op.t option
    }
end =
  Seat

and Wm : sig
  module Lifecycle : sig
    type t =
      | Running
      | Pending_exit of [ `Local | `Compositor ]
      | Exited
      | Close_requested

    val to_string : t -> string
  end

  module Ipc : sig
    module Subscriber : sig
      type t =
        { mutable fd : Unix.file_descr
        ; mutable events : string list
        }
    end

    module Connection : sig
      type t =
        { socket_path : string
        ; server_fd : Unix.file_descr
        ; mutable subscribers : Subscriber.t list
        }
    end

    type t =
      | Inactive
      | Active of Connection.t
  end

  type t =
    { (* Wayland objects *)
      river_wm_v1 :
        River.V.Window_management.t River.Window_management.River_window_manager_v1.t
    ; river_xkb_v1 : River.V.Xkb_bindings.t River.Xkb_bindings.River_xkb_bindings_v1.t
    ; river_lsh_v1 : River.V.Layer_shell.t River.Layer_shell.River_layer_shell_v1.t
    ; river_input_v1 :
        River.V.Input_management.t River.Input_management.River_input_manager_v1.t
    ; river_xkb_config_v1 : River.V.Xkb_config.t River.Xkb_config.River_xkb_config_v1.t
    ; registry : Wayland.Registry.t
    ; (* Lifecycle *)
      shutdown : Eio.Condition.t
    ; mutable lifecycle : Lifecycle.t
    ; mutable is_dirty : bool
    ; (* State *)
      mutable primary_seat : Seat.t option
    ; (* Managed items *)
      mutable outputs : Output.t list (* Sorted by focus order *)
    ; mutable windows : Window.t list
    ; mutable seats : Seat.t list
    ; mutable input_devices : Input_device.t list
    ; mutable xkb_stash : (int32 * Input_device.Xkb.t) list
    ; mutable keymap : River.V.Xkb_config.t River.Xkb_config.River_xkb_keymap_v1.t option
    ; mutable desired_keymap_path : string option
    ; (* User configuration *)
      config : Config.t
    ; init_command : string option
    ; mutable init_handle : Init_script.t option
    ; (* Layout registry *)
      layout_registry : Ocdwm_layout.Registry.t
    ; (* IPC state *)
      ipc : Ipc.t
    }
end =
  Wm
