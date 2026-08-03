module Key = struct
  type t =
    | Keysym of Xkbcommon.Keysym.t
    | Pointer of Ocdwm_core.Pointer_button.t
end

module Config = struct
  module Border = struct
    type t =
      { mutable width : int32
      ; mutable focused_color : Ocdwm_core.Color.t
      ; mutable unfocused_color : Ocdwm_core.Color.t
      ; mutable urgent_color : Ocdwm_core.Color.t
      }
  end

  module Data = struct
    type t =
      { mutable layout : Ocdwm_core.Layout.t
      ; tiling : Ocdwm_layout.Params.Tiling.t
      ; scrolling : Ocdwm_layout.Params.Scrolling.t
      ; gaps : Ocdwm_layout.Params.Gaps.t
      }
  end

  module Rules = struct
    type t =
      { mutable window : Ocdwm_core.Window_rule.t list
      ; mutable input : Ocdwm_core.Input_rule.t list
      }
  end

  type t =
    { default_tag_config : Data.t
    ; borders : Border.t
    ; mutable cursor_theme : (string * int32) option
    ; mutable modes : string list
    ; mutable modkey : Wire.Modifiers.t
    ; rules : Rules.t
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

  module Role : sig
    type t =
      | Keyboard of { mutable keyboard : Wire.Obj.Xkb.Config.Keyboard.t option }
      | Pointer of { mutable class_ : Ocdwm_core.Input.Class.t }
      | Touch
      | Tablet
  end

  type t =
    { obj : Wire.Obj.Input.Management.Device.t
    ; name : string
    ; role : Role.t
    ; mutable lifecycle : Lifecycle.t
    ; mutable libinput : Wire.Obj.Input.Config.Device.t option
    }
end =
  Input_device

and Output : sig
  module Lifecycle : sig
    type t =
      | Active
      | Removed
  end

  module Tags : sig
    type t =
      { mutable selected : Ocdwm_core.Tag.Set.t
      ; mutable previous : Ocdwm_core.Tag.Set.t
      }
  end

  module Overview : sig
    type t =
      { mutable offset : int
      ; mutable enabled : bool
      ; mutable gaps : int
      ; mutable head : Window.t option
      }
  end

  module Scroll : sig
    type t = { mutable offset : int }
  end

  type t =
    { obj : Wire.Obj.Window_management.Output.t
    ; layer_shell : Wire.Obj.Layer_shell.Output.t
    ; mutable lifecycle : Lifecycle.t
    ; mutable name : string option
    ; mutable geom : int32 Ocdwm_core.Rect.t
    ; mutable usable : int Ocdwm_core.Rect.t
    ; tags : Tags.t
    ; overview : Overview.t
    ; scroll : Scroll.t
    ; tag_data : Config.Data.t array
    ; (* Focus stack; most recently focused first *)
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
      | Move_to of
          { x : Ocdwm_core.Extent.t
          ; y : Ocdwm_core.Extent.t
          }
      | Resize of
          { seat : Seat.t
          ; edges : int32
          }
      | Resize_to of
          { w : Ocdwm_core.Extent.t
          ; h : Ocdwm_core.Extent.t
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

  module Scrolling_props : sig
    type t =
      { mutable consumes : bool
      ; mutable width : Ocdwm_core.Width_fac.t
      }
  end

  module Defense : sig
    type t =
      | Idle
      | Bounce of int32 * int32
      | Hold of int32 * int32
  end

  module Committed : sig
    type t =
      { mutable proposed : (int32 * int32) option
      ; mutable fullscreen_on : int32 option
      }
  end

  type t =
    { obj : Wire.Obj.Window_management.Window.t
    ; node : Wire.Obj.Window_management.Node.t
    ; mutable lifecycle : Lifecycle.t
    ; id : int
    ; mutable app_id : string option
    ; mutable title : string option
    ; mutable identifier : string option
    ; mutable unreliable_pid : int32 option
    ; mutable parent : t option
    ; mutable float_seed_pending : bool
    ; mutable close_pending : bool
    ; mutable decoration_hint : Decoration_hint.t option
    ; mutable presentation_hint : Wire.Presentation_mode.t option
    ; mutable defense : Defense.t
    ; mutable geom : int32 Ocdwm_core.Rect.t
    ; mutable float_geom : int32 Ocdwm_core.Rect.t option
    ; mutable clip : ([ `Scrolling | `Overview ] * int Ocdwm_core.Rect.t) option
    ; mutable offscreen : bool
    ; mutable size_hints : int32 Size_hints.t
    ; mutable tags : Ocdwm_core.Tag.Set.t
    ; mutable output : Output.t option
    ; mutable output_before_evac : string option
    ; mutable is_fixed : bool
    ; mutable is_urgent : bool
    ; mutable is_fake_fullscreen : bool
    ; mutable scrolling : Scrolling_props.t
    ; committed : Committed.t
    ; mutable presentation : Presentation.t
    ; mutable requests : Request.t list
    }
end =
  Window

and Seat : sig
  module Lifecycle : sig
    type t =
      | New
      | Active
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
      { obj : Wire.Obj.Xkb.Bindings.Binding.t
      ; seat : Seat.t
      ; mode : string
      ; mutable enabled : bool
      ; command : Ocdwm_ipc.Command.t
      ; mods : int32
      ; keysym : Xkbcommon.Keysym.t
      }
  end

  module Pointer_binding : sig
    type t =
      { obj : Wire.Obj.Window_management.Pointer_binding.t
      ; seat : Seat.t
      ; mode : string
      ; mutable enabled : bool
      ; command : Ocdwm_ipc.Command.t
      ; mods : int32
      ; button : Ocdwm_core.Pointer_button.t
      }
  end

  module Warp_request : sig
    type t =
      | No_request
      | Follow_config
      | Forced of bool
      | Point of (int32 * int32)

    val of_override : bool option -> t
  end

  type t =
    { obj : Wire.Obj.Window_management.Seat.t
    ; layer_shell : Wire.Obj.Layer_shell.Seat.t
    ; xkb_seat : Wire.Obj.Xkb.Bindings.Seat.t
    ; mutable overview_watch : int32
    ; mutable watch_sent : int32
    ; mutable lifecycle : Lifecycle.t
    ; mutable name : string option
    ; mutable output : Output.t option
    ; mutable focus_cleared : bool
    ; mutable position : Position.t
    ; mutable layer_focus : Layer_focus.t option
    ; mutable mode : string
    ; mutable xkb_bindings : Xkb_binding.t list
    ; mutable pointer_bindings : Pointer_binding.t list
    ; mutable pending_requests : Pending_request.t Queue.t
    ; mutable hovered : Window.t option
    ; mutable interacted : Window.t option
    ; mutable warp_request : Warp_request.t
    ; mutable focus_state : Focus_state.t
    ; mutable cursor_target : Window.t option
    ; mutable op : Op.t option
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
        { kinds : Ocdwm_ipc.Record.t list
        ; output : string option
        ; mutable pending : ((Ocdwm_ipc.Record.t * string) * string) list
        ; wake : Eio.Condition.t
        }
    end

    type t =
      { mutable subscribers : Subscriber.t list
      ; mutable last : ((Ocdwm_ipc.Record.t * string) * Ocdwm_ipc.Event.t) list
      }
  end

  type t =
    { river_wm_v1 : Wire.Obj.Window_management.Wm.t
    ; river_xkb_v1 : Wire.Obj.Xkb.Bindings.t
    ; river_lsh_v1 : Wire.Obj.Layer_shell.t
    ; river_input_v1 : Wire.Obj.Input.Management.t
    ; river_libinput_v1 : Wire.Obj.Input.Config.t
    ; river_xkb_config_v1 : Wire.Obj.Xkb.Config.t
    ; shutdown : Eio.Condition.t
    ; mutable lifecycle : Lifecycle.t
    ; mutable session_locked : bool
    ; mutable primary_seat : Seat.t option
    ; mutable outputs : Output.t list
    ; mutable windows : Window.t list
    ; mutable seats : Seat.t list
    ; mutable input_devices : Input_device.t list
    ; mutable xkb_stash : (int32 * Wire.Obj.Xkb.Config.Keyboard.t) list
    ; mutable keymap : Wire.Obj.Xkb.Config.Keymap.t option
    ; mutable desired_keymap_path : string option
    ; config : Config.t
    ; init_command : string option
    ; mutable init_handle : Init_script.t option
    ; ipc : Ipc.t
    }
end =
  Wm
