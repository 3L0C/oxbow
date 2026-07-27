(* This file was generated automatically by wayland-scanner-ocaml *)

[@@@ocaml.warning "-27-34"]
open struct
  module Imports = struct
    include River_libinput_config_v1_proto
    include River_input_management_v1_proto
  end
  
  module Proxy = Wayland.Proxy
  module Msg = Wayland.Msg
  module Fixed = Wayland.Fixed
  module Iface_reg = Wayland.Iface_reg
  module S = Wayland.S
end


(** Libinput config global interface.
    
    Global interface for configuring libinput devices. This global should
    only be advertised if river_input_manager_v1 is advertised as well. *)
module River_libinput_config_v1 = struct
  type 'v t = ([`River_libinput_config_v1], 'v, [`Client]) Proxy.t
  module Error = River_libinput_config_v1_proto.River_libinput_config_v1.Error
  
  (** {2 Version 1, 2} *)
  
  (** Create a acceleration config.
      
      Create a acceleration config which can be applied
      with river_libinput_device_v1.apply_accel_config. *)
  let create_accel_config (_t:([< `V1 | `V2] as 'v) t) (id:([`River_libinput_accel_config_v1], 'v, [`Client]) #Proxy.Handler.t) ~profile =
    let __id = Proxy.spawn _t id in
    let _msg = Proxy.alloc _t ~op:2 ~ints:2 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id __id);
    Msg.add_int _msg (Imports.River_libinput_device_v1.Accel_profile.to_int32 profile);
    Proxy.send _t _msg;
    __id
  
  (** Destroy the river_libinput_config_v1 object.
      
      This request should be called after the finished event has been received
      to complete destruction of the object.
      
      It is a protocol error to make this request before the finished event
      has been received.
      
      If a client wishes to destroy this object it should send a
      river_libinput_config_v1.stop request and wait for a
      river_libinput_config_v1.finished event. Once the finished event is
      received it is safe to destroy this object and any other objects created
      through this interface. *)
  let destroy (_t:([< `V1 | `V2] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:1 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg;
    Proxy.shutdown_send _t
  
  (** Stop sending events.
      
      This request indicates that the client no longer wishes to receive
      events on this object.
      
      The Wayland protocol is asynchronous, which means the server may send
      further events until the stop request is processed. The client must wait
      for a river_libinput_config_v1.finished event before destroying this
      object. *)
  let stop (_t:([< `V1 | `V2] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:0 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (**/**)
  class virtual ['v] _handlers_unsafe = object (_self : (_, 'v, _) #Proxy.Handler.t)
    method user_data = S.No_data
    method metadata = (module River_libinput_config_v1_proto.River_libinput_config_v1)
    method max_version = 2l
    
    method private virtual on_finished : [> ] t -> unit
    
    method private virtual on_libinput_device : [> ] t -> ([`River_libinput_device_v1], 'v, [`Client]) Proxy.t -> unit
    
    
    method dispatch (_proxy : 'v t) _msg =
      let _proxy = Proxy.cast_version _proxy in
      match Msg.op _msg with
      | 0 ->
        _self#on_finished _proxy 
      | 1 ->
        let id : ([`River_libinput_device_v1], _, _) Proxy.t =
          Msg.get_int _msg |> Proxy.Handler.accept_new _proxy (module Imports.River_libinput_device_v1) in
        _self#on_libinput_device _proxy id
      | _ -> assert false
  end
  (**/**)
  
  (** {2 Handlers}
      Note: Servers will always want to use [v1].
   *)
  
  
  (** Handler for a proxy with version >= 1. *)
  class virtual ['v] v1 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V1 | `V2] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_finished : [> `V1 | `V2] t -> unit
    
    (** The server has finished with the object.
        
        This event indicates that the server will send no further events on this
        object. The client should destroy the object. See
        river_libinput_config_v1.destroy for more information. *)
    
    method private virtual on_libinput_device : [> `V1 | `V2] t -> ([`River_libinput_device_v1], 'v, [`Client]) Proxy.t ->
                                                unit
    
    (** New libinput device.
        
        A new libinput device has been created. Not every river_input_device_v1
        is necessarily a libinput device as well. *)
    
    method min_version = 1l
    method bind_version : [`V1] = `V1
  end
  
  (** Handler for a proxy with version >= 2. *)
  class virtual ['v] v2 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V2] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_finished : [> `V2] t -> unit
    
    (** The server has finished with the object.
        
        This event indicates that the server will send no further events on this
        object. The client should destroy the object. See
        river_libinput_config_v1.destroy for more information. *)
    
    method private virtual on_libinput_device : [> `V2] t -> ([`River_libinput_device_v1], 'v, [`Client]) Proxy.t ->
                                                unit
    
    (** New libinput device.
        
        A new libinput device has been created. Not every river_input_device_v1
        is necessarily a libinput device as well. *)
    
    method min_version = 2l
    method bind_version : [`V2] = `V2
  end
end

(** A libinput device.
    
    In general, *_support events will be sent exactly once directly after the
    river_libinput_device_v1 is created. *_default events will be sent after
    *_support events if the config option is supported, and *_current events
    willl be sent after the *_default events and again whenever the config
    option is changed. *)
module River_libinput_device_v1 = struct
  type 'v t = ([`River_libinput_device_v1], 'v, [`Client]) Proxy.t
  module Error = River_libinput_config_v1_proto.River_libinput_device_v1.Error
  
  module Send_events_modes = River_libinput_config_v1_proto.River_libinput_device_v1.Send_events_modes
  
  module Tap_state = River_libinput_config_v1_proto.River_libinput_device_v1.Tap_state
  
  module Tap_button_map = River_libinput_config_v1_proto.River_libinput_device_v1.Tap_button_map
  
  module Drag_state = River_libinput_config_v1_proto.River_libinput_device_v1.Drag_state
  
  module Drag_lock_state = River_libinput_config_v1_proto.River_libinput_device_v1.Drag_lock_state
  
  module Three_finger_drag_state = River_libinput_config_v1_proto.River_libinput_device_v1.Three_finger_drag_state
  
  module Accel_profile = River_libinput_config_v1_proto.River_libinput_device_v1.Accel_profile
  
  module Accel_profiles = River_libinput_config_v1_proto.River_libinput_device_v1.Accel_profiles
  
  module Natural_scroll_state = River_libinput_config_v1_proto.River_libinput_device_v1.Natural_scroll_state
  
  module Left_handed_state = River_libinput_config_v1_proto.River_libinput_device_v1.Left_handed_state
  
  module Click_method = River_libinput_config_v1_proto.River_libinput_device_v1.Click_method
  
  module Click_methods = River_libinput_config_v1_proto.River_libinput_device_v1.Click_methods
  
  module Clickfinger_button_map = River_libinput_config_v1_proto.River_libinput_device_v1.Clickfinger_button_map
  
  module Middle_emulation_state = River_libinput_config_v1_proto.River_libinput_device_v1.Middle_emulation_state
  
  module Scroll_method = River_libinput_config_v1_proto.River_libinput_device_v1.Scroll_method
  
  module Scroll_methods = River_libinput_config_v1_proto.River_libinput_device_v1.Scroll_methods
  
  module Scroll_button_lock_state = River_libinput_config_v1_proto.River_libinput_device_v1.Scroll_button_lock_state
  
  module Dwt_state = River_libinput_config_v1_proto.River_libinput_device_v1.Dwt_state
  
  module Dwtp_state = River_libinput_config_v1_proto.River_libinput_device_v1.Dwtp_state
  
  (** {2 Version 1} *)
  
  (** Set rotation angle.
      
      Set rotation angle in degrees clockwise off the logical neutral
      position. Angle must be in the range [0-360). *)
  let set_rotation (_t:([< `V1 | `V2] as 'v) t) (result:([`River_libinput_result_v1], 'v, [`Client]) #Proxy.Handler.t) ~angle =
    let __result = Proxy.spawn _t result in
    let _msg = Proxy.alloc _t ~op:21 ~ints:2 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id __result);
    Msg.add_int _msg angle;
    Proxy.send _t _msg;
    __result
  
  (** Set disable-while-trackpointing state.
      
      Set disable-while-trackpointing state. *)
  let set_dwtp (_t:([< `V1 | `V2] as 'v) t) (result:([`River_libinput_result_v1], 'v, [`Client]) #Proxy.Handler.t) ~state =
    let __result = Proxy.spawn _t result in
    let _msg = Proxy.alloc _t ~op:20 ~ints:2 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id __result);
    Msg.add_int _msg (Imports.River_libinput_device_v1.Dwtp_state.to_int32 state);
    Proxy.send _t _msg;
    __result
  
  (** Set disable-while-typing state.
      
      Set disable-while-typing state. *)
  let set_dwt (_t:([< `V1 | `V2] as 'v) t) (result:([`River_libinput_result_v1], 'v, [`Client]) #Proxy.Handler.t) ~state =
    let __result = Proxy.spawn _t result in
    let _msg = Proxy.alloc _t ~op:19 ~ints:2 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id __result);
    Msg.add_int _msg (Imports.River_libinput_device_v1.Dwt_state.to_int32 state);
    Proxy.send _t _msg;
    __result
  
  (** Set scroll button lock state.
      
      Set scroll button lock state.
      Supported if scroll_methods.on_button_down is supported. *)
  let set_scroll_button_lock (_t:([< `V1 | `V2] as 'v) t) (result:([`River_libinput_result_v1], 'v, [`Client]) #Proxy.Handler.t) ~state =
    let __result = Proxy.spawn _t result in
    let _msg = Proxy.alloc _t ~op:18 ~ints:2 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id __result);
    Msg.add_int _msg (Imports.River_libinput_device_v1.Scroll_button_lock_state.to_int32 state);
    Proxy.send _t _msg;
    __result
  
  (** Set scroll button.
      
      Set scroll button.
      Supported if scroll_methods.on_button_down is supported. *)
  let set_scroll_button (_t:([< `V1 | `V2] as 'v) t) (result:([`River_libinput_result_v1], 'v, [`Client]) #Proxy.Handler.t) ~button =
    let __result = Proxy.spawn _t result in
    let _msg = Proxy.alloc _t ~op:17 ~ints:2 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id __result);
    Msg.add_int _msg button;
    Proxy.send _t _msg;
    __result
  
  (** Set scroll method.
      
      Set scroll method. *)
  let set_scroll_method (_t:([< `V1 | `V2] as 'v) t) (result:([`River_libinput_result_v1], 'v, [`Client]) #Proxy.Handler.t) ~method_ =
    let __result = Proxy.spawn _t result in
    let _msg = Proxy.alloc _t ~op:16 ~ints:2 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id __result);
    Msg.add_int _msg (Imports.River_libinput_device_v1.Scroll_method.to_int32 method_);
    Proxy.send _t _msg;
    __result
  
  (** Set middle mouse button emulation state.
      
      Set middle mouse button emulation state. *)
  let set_middle_emulation (_t:([< `V1 | `V2] as 'v) t) (result:([`River_libinput_result_v1], 'v, [`Client]) #Proxy.Handler.t) ~state =
    let __result = Proxy.spawn _t result in
    let _msg = Proxy.alloc _t ~op:15 ~ints:2 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id __result);
    Msg.add_int _msg (Imports.River_libinput_device_v1.Middle_emulation_state.to_int32 state);
    Proxy.send _t _msg;
    __result
  
  (** Set clickfinger button map.
      
      Set clickfinger button map.
      Supported if click_methods.clickfinger is supported. *)
  let set_clickfinger_button_map (_t:([< `V1 | `V2] as 'v) t) (result:([`River_libinput_result_v1], 'v, [`Client]) #Proxy.Handler.t) ~button_map =
    let __result = Proxy.spawn _t result in
    let _msg = Proxy.alloc _t ~op:14 ~ints:2 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id __result);
    Msg.add_int _msg (Imports.River_libinput_device_v1.Clickfinger_button_map.to_int32 button_map);
    Proxy.send _t _msg;
    __result
  
  (** Set click method.
      
      Set click method. *)
  let set_click_method (_t:([< `V1 | `V2] as 'v) t) (result:([`River_libinput_result_v1], 'v, [`Client]) #Proxy.Handler.t) ~method_ =
    let __result = Proxy.spawn _t result in
    let _msg = Proxy.alloc _t ~op:13 ~ints:2 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id __result);
    Msg.add_int _msg (Imports.River_libinput_device_v1.Click_method.to_int32 method_);
    Proxy.send _t _msg;
    __result
  
  (** Set left-handed mode state.
      
      Set left-handed mode state. *)
  let set_left_handed (_t:([< `V1 | `V2] as 'v) t) (result:([`River_libinput_result_v1], 'v, [`Client]) #Proxy.Handler.t) ~state =
    let __result = Proxy.spawn _t result in
    let _msg = Proxy.alloc _t ~op:12 ~ints:2 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id __result);
    Msg.add_int _msg (Imports.River_libinput_device_v1.Left_handed_state.to_int32 state);
    Proxy.send _t _msg;
    __result
  
  (** Set natural scroll state.
      
      Set natural scroll state. *)
  let set_natural_scroll (_t:([< `V1 | `V2] as 'v) t) (result:([`River_libinput_result_v1], 'v, [`Client]) #Proxy.Handler.t) ~state =
    let __result = Proxy.spawn _t result in
    let _msg = Proxy.alloc _t ~op:11 ~ints:2 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id __result);
    Msg.add_int _msg (Imports.River_libinput_device_v1.Natural_scroll_state.to_int32 state);
    Proxy.send _t _msg;
    __result
  
  (** Apply acceleration config.
      
      Apply a pointer accleration config. *)
  let apply_accel_config (_t:([< `V1 | `V2] as 'v) t) (result:([`River_libinput_result_v1], 'v, [`Client]) #Proxy.Handler.t) ~(config:([`River_libinput_accel_config_v1], _, [`Client]) Proxy.t) =
    let __result = Proxy.spawn _t result in
    let _msg = Proxy.alloc _t ~op:10 ~ints:2 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id __result);
    Msg.add_int _msg (Proxy.id config);
    Proxy.send _t _msg;
    __result
  
  (** Set acceleration speed.
      
      Set the acceleration speed within a range of [-1, 1], where 0 is
      the default acceleration for this device, -1 is the slowest acceleration
      and 1 is the maximum acceleration available on this device. *)
  let set_accel_speed (_t:([< `V1 | `V2] as 'v) t) (result:([`River_libinput_result_v1], 'v, [`Client]) #Proxy.Handler.t) ~speed =
    let __result = Proxy.spawn _t result in
    let _msg = Proxy.alloc _t ~op:9 ~ints:2 ~strings:[] ~arrays:[speed] in
    Msg.add_int _msg (Proxy.id __result);
    Msg.add_array _msg speed;
    Proxy.send _t _msg;
    __result
  
  (** Set acceleration profile.
      
      Set the acceleration profile. *)
  let set_accel_profile (_t:([< `V1 | `V2] as 'v) t) (result:([`River_libinput_result_v1], 'v, [`Client]) #Proxy.Handler.t) ~profile =
    let __result = Proxy.spawn _t result in
    let _msg = Proxy.alloc _t ~op:8 ~ints:2 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id __result);
    Msg.add_int _msg (Imports.River_libinput_device_v1.Accel_profile.to_int32 profile);
    Proxy.send _t _msg;
    __result
  
  (** Set calibration matrix.
      
      Set calibration matrix. *)
  let set_calibration_matrix (_t:([< `V1 | `V2] as 'v) t) (result:([`River_libinput_result_v1], 'v, [`Client]) #Proxy.Handler.t) ~matrix =
    let __result = Proxy.spawn _t result in
    let _msg = Proxy.alloc _t ~op:7 ~ints:2 ~strings:[] ~arrays:[matrix] in
    Msg.add_int _msg (Proxy.id __result);
    Msg.add_array _msg matrix;
    Proxy.send _t _msg;
    __result
  
  (** Set three finger drag state.
      
      Configure three finger drag functionality for the device. *)
  let set_three_finger_drag (_t:([< `V1 | `V2] as 'v) t) (result:([`River_libinput_result_v1], 'v, [`Client]) #Proxy.Handler.t) ~state =
    let __result = Proxy.spawn _t result in
    let _msg = Proxy.alloc _t ~op:6 ~ints:2 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id __result);
    Msg.add_int _msg (Imports.River_libinput_device_v1.Three_finger_drag_state.to_int32 state);
    Proxy.send _t _msg;
    __result
  
  (** Set drag lock state.
      
      Configure drag-lock during tapping on this device. When enabled, a
      finger may be lifted and put back on the touchpad and the drag process
      continues. A timeout for lifting the finger is optional. When disabled,
      lifting the finger during a tap-and-drag will immediately stop the drag.
      See the libinput documentation for more details. *)
  let set_drag_lock (_t:([< `V1 | `V2] as 'v) t) (result:([`River_libinput_result_v1], 'v, [`Client]) #Proxy.Handler.t) ~state =
    let __result = Proxy.spawn _t result in
    let _msg = Proxy.alloc _t ~op:5 ~ints:2 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id __result);
    Msg.add_int _msg (Imports.River_libinput_device_v1.Drag_lock_state.to_int32 state);
    Proxy.send _t _msg;
    __result
  
  (** Set tap-and-drag state.
      
      Configure tap-and-drag functionality on the device. *)
  let set_drag (_t:([< `V1 | `V2] as 'v) t) (result:([`River_libinput_result_v1], 'v, [`Client]) #Proxy.Handler.t) ~state =
    let __result = Proxy.spawn _t result in
    let _msg = Proxy.alloc _t ~op:4 ~ints:2 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id __result);
    Msg.add_int _msg (Imports.River_libinput_device_v1.Drag_state.to_int32 state);
    Proxy.send _t _msg;
    __result
  
  (** Set tap-to-click button map.
      
      Set the finger number to button number mapping for tap-to-click. The
      default mapping on most devices is to have a 1, 2 and 3 finger tap to
      map to the left, right and middle button, respectively. *)
  let set_tap_button_map (_t:([< `V1 | `V2] as 'v) t) (result:([`River_libinput_result_v1], 'v, [`Client]) #Proxy.Handler.t) ~button_map =
    let __result = Proxy.spawn _t result in
    let _msg = Proxy.alloc _t ~op:3 ~ints:2 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id __result);
    Msg.add_int _msg (Imports.River_libinput_device_v1.Tap_button_map.to_int32 button_map);
    Proxy.send _t _msg;
    __result
  
  (** Enable/disable tap-to-click.
      
      Configure tap-to-click on this device, with a default mapping of
      1, 2, 3 finger tap mapping to left, right, middle click, respectively. *)
  let set_tap (_t:([< `V1 | `V2] as 'v) t) (result:([`River_libinput_result_v1], 'v, [`Client]) #Proxy.Handler.t) ~state =
    let __result = Proxy.spawn _t result in
    let _msg = Proxy.alloc _t ~op:2 ~ints:2 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id __result);
    Msg.add_int _msg (Imports.River_libinput_device_v1.Tap_state.to_int32 state);
    Proxy.send _t _msg;
    __result
  
  (** Set send events mode.
      
      Set the send events mode for the device. *)
  let set_send_events (_t:([< `V1 | `V2] as 'v) t) (result:([`River_libinput_result_v1], 'v, [`Client]) #Proxy.Handler.t) ~mode =
    let __result = Proxy.spawn _t result in
    let _msg = Proxy.alloc _t ~op:1 ~ints:2 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id __result);
    Msg.add_int _msg (Imports.River_libinput_device_v1.Send_events_modes.to_int32 mode);
    Proxy.send _t _msg;
    __result
  
  (** Destroy the libinput device object.
      
      This request indicates that the client will no longer use the input
      device object and that it may be safely destroyed. *)
  let destroy (_t:([< `V1 | `V2] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:0 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg;
    Proxy.shutdown_send _t
  
  
  (** {2 Version 2} *)
  
  (**/**)
  class virtual ['v] _handlers_unsafe = object (_self : (_, 'v, _) #Proxy.Handler.t)
    method user_data = S.No_data
    method metadata = (module River_libinput_config_v1_proto.River_libinput_device_v1)
    method max_version = 2l
    
    method private virtual on_removed : [> ] t -> unit
    
    method private virtual on_input_device : [> ] t -> device:([`River_input_device_v1], [> Imports.River_input_device_v1.versions], [`Client]) Proxy.t ->
                                             unit
    
    method private virtual on_send_events_support : [> ] t -> modes:Imports.River_libinput_device_v1.Send_events_modes.t ->
                                                    unit
    
    method private virtual on_send_events_default : [> ] t -> mode:Imports.River_libinput_device_v1.Send_events_modes.t ->
                                                    unit
    
    method private virtual on_send_events_current : [> ] t -> mode:Imports.River_libinput_device_v1.Send_events_modes.t ->
                                                    unit
    
    method private virtual on_tap_support : [> ] t -> finger_count:int32 -> unit
    
    method private virtual on_tap_default : [> ] t -> state:Imports.River_libinput_device_v1.Tap_state.t -> unit
    
    method private virtual on_tap_current : [> ] t -> state:Imports.River_libinput_device_v1.Tap_state.t -> unit
    
    method private virtual on_tap_button_map_default : [> ] t -> button_map:Imports.River_libinput_device_v1.Tap_button_map.t ->
                                                       unit
    
    method private virtual on_tap_button_map_current : [> ] t -> button_map:Imports.River_libinput_device_v1.Tap_button_map.t ->
                                                       unit
    
    method private virtual on_drag_default : [> ] t -> state:Imports.River_libinput_device_v1.Drag_state.t -> unit
    
    method private virtual on_drag_current : [> ] t -> state:Imports.River_libinput_device_v1.Drag_state.t -> unit
    
    method private virtual on_drag_lock_default : [> ] t -> state:Imports.River_libinput_device_v1.Drag_lock_state.t ->
                                                  unit
    
    method private virtual on_drag_lock_current : [> ] t -> state:Imports.River_libinput_device_v1.Drag_lock_state.t ->
                                                  unit
    
    method private virtual on_three_finger_drag_support : [> ] t -> finger_count:int32 -> unit
    
    method private virtual on_three_finger_drag_default : [> ] t -> state:Imports.River_libinput_device_v1.Three_finger_drag_state.t ->
                                                          unit
    
    method private virtual on_three_finger_drag_current : [> ] t -> state:Imports.River_libinput_device_v1.Three_finger_drag_state.t ->
                                                          unit
    
    method private virtual on_calibration_matrix_support : [> ] t -> supported:int32 -> unit
    
    method private virtual on_calibration_matrix_default : [> ] t -> matrix:string -> unit
    
    method private virtual on_calibration_matrix_current : [> ] t -> matrix:string -> unit
    
    method private virtual on_accel_profiles_support : [> ] t -> profiles:Imports.River_libinput_device_v1.Accel_profiles.t ->
                                                       unit
    
    method private virtual on_accel_profile_default : [> ] t -> profile:Imports.River_libinput_device_v1.Accel_profile.t ->
                                                      unit
    
    method private virtual on_accel_profile_current : [> ] t -> profile:Imports.River_libinput_device_v1.Accel_profile.t ->
                                                      unit
    
    method private virtual on_accel_speed_default : [> ] t -> speed:string -> unit
    
    method private virtual on_accel_speed_current : [> ] t -> speed:string -> unit
    
    method private virtual on_natural_scroll_support : [> ] t -> supported:int32 -> unit
    
    method private virtual on_natural_scroll_default : [> ] t -> state:Imports.River_libinput_device_v1.Natural_scroll_state.t ->
                                                       unit
    
    method private virtual on_natural_scroll_current : [> ] t -> state:Imports.River_libinput_device_v1.Natural_scroll_state.t ->
                                                       unit
    
    method private virtual on_left_handed_support : [> ] t -> supported:int32 -> unit
    
    method private virtual on_left_handed_default : [> ] t -> state:Imports.River_libinput_device_v1.Left_handed_state.t ->
                                                    unit
    
    method private virtual on_left_handed_current : [> ] t -> state:Imports.River_libinput_device_v1.Left_handed_state.t ->
                                                    unit
    
    method private virtual on_click_method_support : [> ] t -> methods:Imports.River_libinput_device_v1.Click_methods.t ->
                                                     unit
    
    method private virtual on_click_method_default : [> ] t -> method_:Imports.River_libinput_device_v1.Click_method.t ->
                                                     unit
    
    method private virtual on_click_method_current : [> ] t -> method_:Imports.River_libinput_device_v1.Click_method.t ->
                                                     unit
    
    method private virtual on_clickfinger_button_map_default : [> ] t -> button_map:Imports.River_libinput_device_v1.Clickfinger_button_map.t ->
                                                               unit
    
    method private virtual on_clickfinger_button_map_current : [> ] t -> button_map:Imports.River_libinput_device_v1.Clickfinger_button_map.t ->
                                                               unit
    
    method private virtual on_middle_emulation_support : [> ] t -> supported:int32 -> unit
    
    method private virtual on_middle_emulation_default : [> ] t -> state:Imports.River_libinput_device_v1.Middle_emulation_state.t ->
                                                         unit
    
    method private virtual on_middle_emulation_current : [> ] t -> state:Imports.River_libinput_device_v1.Middle_emulation_state.t ->
                                                         unit
    
    method private virtual on_scroll_method_support : [> ] t -> methods:Imports.River_libinput_device_v1.Scroll_methods.t ->
                                                      unit
    
    method private virtual on_scroll_method_default : [> ] t -> method_:Imports.River_libinput_device_v1.Scroll_method.t ->
                                                      unit
    
    method private virtual on_scroll_method_current : [> ] t -> method_:Imports.River_libinput_device_v1.Scroll_method.t ->
                                                      unit
    
    method private virtual on_scroll_button_default : [> ] t -> button:int32 -> unit
    
    method private virtual on_scroll_button_current : [> ] t -> button:int32 -> unit
    
    method private virtual on_scroll_button_lock_default : [> ] t -> state:Imports.River_libinput_device_v1.Scroll_button_lock_state.t ->
                                                           unit
    
    method private virtual on_scroll_button_lock_current : [> ] t -> state:Imports.River_libinput_device_v1.Scroll_button_lock_state.t ->
                                                           unit
    
    method private virtual on_dwt_support : [> ] t -> supported:int32 -> unit
    
    method private virtual on_dwt_default : [> ] t -> state:Imports.River_libinput_device_v1.Dwt_state.t -> unit
    
    method private virtual on_dwt_current : [> ] t -> state:Imports.River_libinput_device_v1.Dwt_state.t -> unit
    
    method private virtual on_dwtp_support : [> ] t -> supported:int32 -> unit
    
    method private virtual on_dwtp_default : [> ] t -> state:Imports.River_libinput_device_v1.Dwtp_state.t -> unit
    
    method private virtual on_dwtp_current : [> ] t -> state:Imports.River_libinput_device_v1.Dwtp_state.t -> unit
    
    method private virtual on_rotation_support : [> ] t -> supported:int32 -> unit
    
    method private virtual on_rotation_default : [> ] t -> angle:int32 -> unit
    
    method private virtual on_rotation_current : [> ] t -> angle:int32 -> unit
    
    method private virtual on_done : [> ] t -> unit
    
    
    method dispatch (_proxy : 'v t) _msg =
      let _proxy = Proxy.cast_version _proxy in
      match Msg.op _msg with
      | 0 ->
        _self#on_removed _proxy 
      | 1 ->
        let device : ([`River_input_device_v1], _, _) Proxy.t =
          let Proxy.Proxy p = Msg.get_int _msg |> Proxy.lookup_other _proxy in
          match Proxy.ty p with
          | Imports.River_input_device_v1.T -> p
          | _ -> Proxy.wrong_type ~parent:_proxy ~expected:"river_input_device_v1" p
          in
        _self#on_input_device _proxy ~device
      | 2 ->
        let modes = Msg.get_int _msg |> Imports.River_libinput_device_v1.Send_events_modes.of_int32 in
        _self#on_send_events_support _proxy ~modes
      | 3 ->
        let mode = Msg.get_int _msg |> Imports.River_libinput_device_v1.Send_events_modes.of_int32 in
        _self#on_send_events_default _proxy ~mode
      | 4 ->
        let mode = Msg.get_int _msg |> Imports.River_libinput_device_v1.Send_events_modes.of_int32 in
        _self#on_send_events_current _proxy ~mode
      | 5 ->
        let finger_count = Msg.get_int _msg in
        _self#on_tap_support _proxy ~finger_count
      | 6 ->
        let state = Msg.get_int _msg |> Imports.River_libinput_device_v1.Tap_state.of_int32 in
        _self#on_tap_default _proxy ~state
      | 7 ->
        let state = Msg.get_int _msg |> Imports.River_libinput_device_v1.Tap_state.of_int32 in
        _self#on_tap_current _proxy ~state
      | 8 ->
        let button_map = Msg.get_int _msg |> Imports.River_libinput_device_v1.Tap_button_map.of_int32 in
        _self#on_tap_button_map_default _proxy ~button_map
      | 9 ->
        let button_map = Msg.get_int _msg |> Imports.River_libinput_device_v1.Tap_button_map.of_int32 in
        _self#on_tap_button_map_current _proxy ~button_map
      | 10 ->
        let state = Msg.get_int _msg |> Imports.River_libinput_device_v1.Drag_state.of_int32 in
        _self#on_drag_default _proxy ~state
      | 11 ->
        let state = Msg.get_int _msg |> Imports.River_libinput_device_v1.Drag_state.of_int32 in
        _self#on_drag_current _proxy ~state
      | 12 ->
        let state = Msg.get_int _msg |> Imports.River_libinput_device_v1.Drag_lock_state.of_int32 in
        _self#on_drag_lock_default _proxy ~state
      | 13 ->
        let state = Msg.get_int _msg |> Imports.River_libinput_device_v1.Drag_lock_state.of_int32 in
        _self#on_drag_lock_current _proxy ~state
      | 14 ->
        let finger_count = Msg.get_int _msg in
        _self#on_three_finger_drag_support _proxy ~finger_count
      | 15 ->
        let state = Msg.get_int _msg |> Imports.River_libinput_device_v1.Three_finger_drag_state.of_int32 in
        _self#on_three_finger_drag_default _proxy ~state
      | 16 ->
        let state = Msg.get_int _msg |> Imports.River_libinput_device_v1.Three_finger_drag_state.of_int32 in
        _self#on_three_finger_drag_current _proxy ~state
      | 17 ->
        let supported = Msg.get_int _msg in
        _self#on_calibration_matrix_support _proxy ~supported
      | 18 ->
        let matrix = Msg.get_array _msg in
        _self#on_calibration_matrix_default _proxy ~matrix
      | 19 ->
        let matrix = Msg.get_array _msg in
        _self#on_calibration_matrix_current _proxy ~matrix
      | 20 ->
        let profiles = Msg.get_int _msg |> Imports.River_libinput_device_v1.Accel_profiles.of_int32 in
        _self#on_accel_profiles_support _proxy ~profiles
      | 21 ->
        let profile = Msg.get_int _msg |> Imports.River_libinput_device_v1.Accel_profile.of_int32 in
        _self#on_accel_profile_default _proxy ~profile
      | 22 ->
        let profile = Msg.get_int _msg |> Imports.River_libinput_device_v1.Accel_profile.of_int32 in
        _self#on_accel_profile_current _proxy ~profile
      | 23 ->
        let speed = Msg.get_array _msg in
        _self#on_accel_speed_default _proxy ~speed
      | 24 ->
        let speed = Msg.get_array _msg in
        _self#on_accel_speed_current _proxy ~speed
      | 25 ->
        let supported = Msg.get_int _msg in
        _self#on_natural_scroll_support _proxy ~supported
      | 26 ->
        let state = Msg.get_int _msg |> Imports.River_libinput_device_v1.Natural_scroll_state.of_int32 in
        _self#on_natural_scroll_default _proxy ~state
      | 27 ->
        let state = Msg.get_int _msg |> Imports.River_libinput_device_v1.Natural_scroll_state.of_int32 in
        _self#on_natural_scroll_current _proxy ~state
      | 28 ->
        let supported = Msg.get_int _msg in
        _self#on_left_handed_support _proxy ~supported
      | 29 ->
        let state = Msg.get_int _msg |> Imports.River_libinput_device_v1.Left_handed_state.of_int32 in
        _self#on_left_handed_default _proxy ~state
      | 30 ->
        let state = Msg.get_int _msg |> Imports.River_libinput_device_v1.Left_handed_state.of_int32 in
        _self#on_left_handed_current _proxy ~state
      | 31 ->
        let methods = Msg.get_int _msg |> Imports.River_libinput_device_v1.Click_methods.of_int32 in
        _self#on_click_method_support _proxy ~methods
      | 32 ->
        let method_ = Msg.get_int _msg |> Imports.River_libinput_device_v1.Click_method.of_int32 in
        _self#on_click_method_default _proxy ~method_
      | 33 ->
        let method_ = Msg.get_int _msg |> Imports.River_libinput_device_v1.Click_method.of_int32 in
        _self#on_click_method_current _proxy ~method_
      | 34 ->
        let button_map = Msg.get_int _msg |> Imports.River_libinput_device_v1.Clickfinger_button_map.of_int32 in
        _self#on_clickfinger_button_map_default _proxy ~button_map
      | 35 ->
        let button_map = Msg.get_int _msg |> Imports.River_libinput_device_v1.Clickfinger_button_map.of_int32 in
        _self#on_clickfinger_button_map_current _proxy ~button_map
      | 36 ->
        let supported = Msg.get_int _msg in
        _self#on_middle_emulation_support _proxy ~supported
      | 37 ->
        let state = Msg.get_int _msg |> Imports.River_libinput_device_v1.Middle_emulation_state.of_int32 in
        _self#on_middle_emulation_default _proxy ~state
      | 38 ->
        let state = Msg.get_int _msg |> Imports.River_libinput_device_v1.Middle_emulation_state.of_int32 in
        _self#on_middle_emulation_current _proxy ~state
      | 39 ->
        let methods = Msg.get_int _msg |> Imports.River_libinput_device_v1.Scroll_methods.of_int32 in
        _self#on_scroll_method_support _proxy ~methods
      | 40 ->
        let method_ = Msg.get_int _msg |> Imports.River_libinput_device_v1.Scroll_method.of_int32 in
        _self#on_scroll_method_default _proxy ~method_
      | 41 ->
        let method_ = Msg.get_int _msg |> Imports.River_libinput_device_v1.Scroll_method.of_int32 in
        _self#on_scroll_method_current _proxy ~method_
      | 42 ->
        let button = Msg.get_int _msg in
        _self#on_scroll_button_default _proxy ~button
      | 43 ->
        let button = Msg.get_int _msg in
        _self#on_scroll_button_current _proxy ~button
      | 44 ->
        let state = Msg.get_int _msg |> Imports.River_libinput_device_v1.Scroll_button_lock_state.of_int32 in
        _self#on_scroll_button_lock_default _proxy ~state
      | 45 ->
        let state = Msg.get_int _msg |> Imports.River_libinput_device_v1.Scroll_button_lock_state.of_int32 in
        _self#on_scroll_button_lock_current _proxy ~state
      | 46 ->
        let supported = Msg.get_int _msg in
        _self#on_dwt_support _proxy ~supported
      | 47 ->
        let state = Msg.get_int _msg |> Imports.River_libinput_device_v1.Dwt_state.of_int32 in
        _self#on_dwt_default _proxy ~state
      | 48 ->
        let state = Msg.get_int _msg |> Imports.River_libinput_device_v1.Dwt_state.of_int32 in
        _self#on_dwt_current _proxy ~state
      | 49 ->
        let supported = Msg.get_int _msg in
        _self#on_dwtp_support _proxy ~supported
      | 50 ->
        let state = Msg.get_int _msg |> Imports.River_libinput_device_v1.Dwtp_state.of_int32 in
        _self#on_dwtp_default _proxy ~state
      | 51 ->
        let state = Msg.get_int _msg |> Imports.River_libinput_device_v1.Dwtp_state.of_int32 in
        _self#on_dwtp_current _proxy ~state
      | 52 ->
        let supported = Msg.get_int _msg in
        _self#on_rotation_support _proxy ~supported
      | 53 ->
        let angle = Msg.get_int _msg in
        _self#on_rotation_default _proxy ~angle
      | 54 ->
        let angle = Msg.get_int _msg in
        _self#on_rotation_current _proxy ~angle
      | 55 ->
        _self#on_done _proxy 
      | _ -> assert false
  end
  (**/**)
  
  (** {2 Handlers}
      Note: Servers will always want to use [v1].
   *)
  
  
  (** Handler for a proxy with version >= 1. *)
  class virtual ['v] v1 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V1 | `V2] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_removed : [> `V1 | `V2] t -> unit
    
    (** The libinput device is removed.
        
        This event indicates that the libinput device has been removed.
        
        The server will send no further events on this object and ignore any
        request (other than river_libinput_device_v1.destroy) made after this
        event is sent. The client should destroy this object with the
        river_libinput_device_v1.destroy request to free up resources. *)
    
    method private virtual on_input_device : [> `V1 | `V2] t -> device:([`River_input_device_v1], [> Imports.River_input_device_v1.versions], [`Client]) Proxy.t ->
                                             unit
    
    (** Corresponding river input device.
        
        The river_input_device_v1 corresponding to this libinput device.
        This event will always be the first event sent on the
        river_libinput_device_v1 object, and it will be sent exactly once. *)
    
    method private virtual on_send_events_support : [> `V1 | `V2] t -> modes:Imports.River_libinput_device_v1.Send_events_modes.t ->
                                                    unit
    
    (** Supported send events modes.
        
        Supported send events modes. *)
    
    method private virtual on_send_events_default : [> `V1 | `V2] t -> mode:Imports.River_libinput_device_v1.Send_events_modes.t ->
                                                    unit
    
    (** Default send events mode.
        
        Default send events mode. *)
    
    method private virtual on_send_events_current : [> `V1 | `V2] t -> mode:Imports.River_libinput_device_v1.Send_events_modes.t ->
                                                    unit
    
    (** Current send events mode.
        
        Current send events mode. *)
    
    method private virtual on_tap_support : [> `V1 | `V2] t -> finger_count:int32 -> unit
    
    (** Tap-to-click/drag support.
        
        The number of fingers supported for tap-to-click/drag.
        If finger_count is 0, tap-to-click and drag are unsupported. *)
    
    method private virtual on_tap_default : [> `V1 | `V2] t -> state:Imports.River_libinput_device_v1.Tap_state.t ->
                                            unit
    
    (** Default tap-to-click state.
        
        Default tap-to-click state. *)
    
    method private virtual on_tap_current : [> `V1 | `V2] t -> state:Imports.River_libinput_device_v1.Tap_state.t ->
                                            unit
    
    (** Current tap-to-click state.
        
        Current tap-to-click state. *)
    
    method private virtual on_tap_button_map_default : [> `V1 | `V2] t -> button_map:Imports.River_libinput_device_v1.Tap_button_map.t ->
                                                       unit
    
    (** Default tap-to-click button map.
        
        Default tap-to-click button map. *)
    
    method private virtual on_tap_button_map_current : [> `V1 | `V2] t -> button_map:Imports.River_libinput_device_v1.Tap_button_map.t ->
                                                       unit
    
    (** Current tap-to-click button map.
        
        Current tap-to-click button map. *)
    
    method private virtual on_drag_default : [> `V1 | `V2] t -> state:Imports.River_libinput_device_v1.Drag_state.t ->
                                             unit
    
    (** Default tap-and-drag state.
        
        Default tap-and-drag state. *)
    
    method private virtual on_drag_current : [> `V1 | `V2] t -> state:Imports.River_libinput_device_v1.Drag_state.t ->
                                             unit
    
    (** Current tap-and-drag state.
        
        Current tap-and-drag state. *)
    
    method private virtual on_drag_lock_default : [> `V1 | `V2] t -> state:Imports.River_libinput_device_v1.Drag_lock_state.t ->
                                                  unit
    
    (** Default drag lock state.
        
        Default drag lock state. *)
    
    method private virtual on_drag_lock_current : [> `V1 | `V2] t -> state:Imports.River_libinput_device_v1.Drag_lock_state.t ->
                                                  unit
    
    (** Current drag lock state.
        
        Current drag lock state. *)
    
    method private virtual on_three_finger_drag_support : [> `V1 | `V2] t -> finger_count:int32 -> unit
    
    (** Three finger drag support.
        
        The number of fingers supported for three/four finger drag.
        If finger_count is less than 3, three finger drag is unsupported. *)
    
    method private virtual on_three_finger_drag_default : [> `V1 | `V2] t -> state:Imports.River_libinput_device_v1.Three_finger_drag_state.t ->
                                                          unit
    
    (** Default three finger drag state.
        
        Default three finger drag state. *)
    
    method private virtual on_three_finger_drag_current : [> `V1 | `V2] t -> state:Imports.River_libinput_device_v1.Three_finger_drag_state.t ->
                                                          unit
    
    (** Current three finger drag state.
        
        Current three finger drag state. *)
    
    method private virtual on_calibration_matrix_support : [> `V1 | `V2] t -> supported:int32 -> unit
    
    (** Support for a calibration matrix.
        
        A calibration matrix is supported if the supported argument is non-zero. *)
    
    method private virtual on_calibration_matrix_default : [> `V1 | `V2] t -> matrix:string -> unit
    
    (** Default calibration matrix.
        
        Default calibration matrix. *)
    
    method private virtual on_calibration_matrix_current : [> `V1 | `V2] t -> matrix:string -> unit
    
    (** Current calibration matrix.
        
        Current calibration matrix. *)
    
    method private virtual on_accel_profiles_support : [> `V1 | `V2] t -> profiles:Imports.River_libinput_device_v1.Accel_profiles.t ->
                                                       unit
    
    (** Supported acceleration profiles.
        
        Supported acceleration profiles. *)
    
    method private virtual on_accel_profile_default : [> `V1 | `V2] t -> profile:Imports.River_libinput_device_v1.Accel_profile.t ->
                                                      unit
    
    (** Default acceleration profile.
        
        Default acceleration profile. *)
    
    method private virtual on_accel_profile_current : [> `V1 | `V2] t -> profile:Imports.River_libinput_device_v1.Accel_profile.t ->
                                                      unit
    
    (** Current acceleration profile.
        
        Current acceleration profile. *)
    
    method private virtual on_accel_speed_default : [> `V1 | `V2] t -> speed:string -> unit
    
    (** Default acceleration speed.
        
        Default acceleration speed. *)
    
    method private virtual on_accel_speed_current : [> `V1 | `V2] t -> speed:string -> unit
    
    (** Current acceleration speed.
        
        Current acceleration speed. *)
    
    method private virtual on_natural_scroll_support : [> `V1 | `V2] t -> supported:int32 -> unit
    
    (** Support for natural scroll.
        
        Natural scroll is supported if the supported argument is non-zero. *)
    
    method private virtual on_natural_scroll_default : [> `V1 | `V2] t -> state:Imports.River_libinput_device_v1.Natural_scroll_state.t ->
                                                       unit
    
    (** Default natural scroll.
        
        Default natural scroll. *)
    
    method private virtual on_natural_scroll_current : [> `V1 | `V2] t -> state:Imports.River_libinput_device_v1.Natural_scroll_state.t ->
                                                       unit
    
    (** Current natural scroll state.
        
        Current natural scroll. *)
    
    method private virtual on_left_handed_support : [> `V1 | `V2] t -> supported:int32 -> unit
    
    (** Support for left-handed mode.
        
        Left-handed mode is supported if the supported argument is non-zero. *)
    
    method private virtual on_left_handed_default : [> `V1 | `V2] t -> state:Imports.River_libinput_device_v1.Left_handed_state.t ->
                                                    unit
    
    (** Default left-handed mode.
        
        Default left-handed mode. *)
    
    method private virtual on_left_handed_current : [> `V1 | `V2] t -> state:Imports.River_libinput_device_v1.Left_handed_state.t ->
                                                    unit
    
    (** Current left-handed mode state.
        
        Current left-handed mode. *)
    
    method private virtual on_click_method_support : [> `V1 | `V2] t -> methods:Imports.River_libinput_device_v1.Click_methods.t ->
                                                     unit
    
    (** Supported click methods.
        
        The click methods supported by the device. *)
    
    method private virtual on_click_method_default : [> `V1 | `V2] t -> method_:Imports.River_libinput_device_v1.Click_method.t ->
                                                     unit
    
    (** Default click method.
        
        Default click method. *)
    
    method private virtual on_click_method_current : [> `V1 | `V2] t -> method_:Imports.River_libinput_device_v1.Click_method.t ->
                                                     unit
    
    (** Current click method.
        
        Current click method. *)
    
    method private virtual on_clickfinger_button_map_default : [> `V1 | `V2] t -> button_map:Imports.River_libinput_device_v1.Clickfinger_button_map.t ->
                                                               unit
    
    (** Default clickfinger button map.
        
        Default clickfinger button map.
        Supported if click_methods.clickfinger is supported. *)
    
    method private virtual on_clickfinger_button_map_current : [> `V1 | `V2] t -> button_map:Imports.River_libinput_device_v1.Clickfinger_button_map.t ->
                                                               unit
    
    (** Current clickfinger button map.
        
        Current clickfinger button map.
        Supported if click_methods.clickfinger is supported. *)
    
    method private virtual on_middle_emulation_support : [> `V1 | `V2] t -> supported:int32 -> unit
    
    (** Support for middle mouse button emulation.
        
        Middle mouse button emulation is supported if the supported argument is
        non-zero. *)
    
    method private virtual on_middle_emulation_default : [> `V1 | `V2] t -> state:Imports.River_libinput_device_v1.Middle_emulation_state.t ->
                                                         unit
    
    (** Default middle mouse button emulation.
        
        Default middle mouse button emulation. *)
    
    method private virtual on_middle_emulation_current : [> `V1 | `V2] t -> state:Imports.River_libinput_device_v1.Middle_emulation_state.t ->
                                                         unit
    
    (** Current middle mouse button emulation state.
        
        Current middle mouse button emulation. *)
    
    method private virtual on_scroll_method_support : [> `V1 | `V2] t -> methods:Imports.River_libinput_device_v1.Scroll_methods.t ->
                                                      unit
    
    (** Supported scroll methods.
        
        The scroll methods supported by the device. *)
    
    method private virtual on_scroll_method_default : [> `V1 | `V2] t -> method_:Imports.River_libinput_device_v1.Scroll_method.t ->
                                                      unit
    
    (** Default scroll method.
        
        Default scroll method. *)
    
    method private virtual on_scroll_method_current : [> `V1 | `V2] t -> method_:Imports.River_libinput_device_v1.Scroll_method.t ->
                                                      unit
    
    (** Current scroll method.
        
        Current scroll method. *)
    
    method private virtual on_scroll_button_default : [> `V1 | `V2] t -> button:int32 -> unit
    
    (** Default scroll button.
        
        Default scroll button.
        Supported if scroll_methods.on_button_down is supported. *)
    
    method private virtual on_scroll_button_current : [> `V1 | `V2] t -> button:int32 -> unit
    
    (** Current scroll button.
        
        Current scroll button.
        Supported if scroll_methods.on_button_down is supported. *)
    
    method private virtual on_scroll_button_lock_default : [> `V1 | `V2] t -> state:Imports.River_libinput_device_v1.Scroll_button_lock_state.t ->
                                                           unit
    
    (** Default scroll button lock state.
        
        Default scroll button lock state.
        Supported if scroll_methods.on_button_down is supported. *)
    
    method private virtual on_scroll_button_lock_current : [> `V1 | `V2] t -> state:Imports.River_libinput_device_v1.Scroll_button_lock_state.t ->
                                                           unit
    
    (** Current scroll button lock state.
        
        Current scroll button lock state.
        Supported if scroll_methods.on_button_down is supported. *)
    
    method private virtual on_dwt_support : [> `V1 | `V2] t -> supported:int32 -> unit
    
    (** Support for disable-while-typing.
        
        Disable-while-typing is supported if the supported argument is
        non-zero. *)
    
    method private virtual on_dwt_default : [> `V1 | `V2] t -> state:Imports.River_libinput_device_v1.Dwt_state.t ->
                                            unit
    
    (** Default disable-while-typing state.
        
        Default disable-while-typing state. *)
    
    method private virtual on_dwt_current : [> `V1 | `V2] t -> state:Imports.River_libinput_device_v1.Dwt_state.t ->
                                            unit
    
    (** Current disable-while-typing state.
        
        Current disable-while-typing state. *)
    
    method private virtual on_dwtp_support : [> `V1 | `V2] t -> supported:int32 -> unit
    
    (** Support for disable-while-trackpointing.
        
        Disable-while-trackpointing is supported if the supported argument is
        non-zero. *)
    
    method private virtual on_dwtp_default : [> `V1 | `V2] t -> state:Imports.River_libinput_device_v1.Dwtp_state.t ->
                                             unit
    
    (** Default disable-while-trackpointing state.
        
        Default disable-while-trackpointing state. *)
    
    method private virtual on_dwtp_current : [> `V1 | `V2] t -> state:Imports.River_libinput_device_v1.Dwtp_state.t ->
                                             unit
    
    (** Current disable-while-trackpointing state.
        
        Current disable-while-trackpointing state. *)
    
    method private virtual on_rotation_support : [> `V1 | `V2] t -> supported:int32 -> unit
    
    (** Support for rotation.
        
        Rotation is supported if the supported argument is non-zero. *)
    
    method private virtual on_rotation_default : [> `V1 | `V2] t -> angle:int32 -> unit
    
    (** Default rotation angle.
        
        Default rotation angle. *)
    
    method private virtual on_rotation_current : [> `V1 | `V2] t -> angle:int32 -> unit
    
    (** Current rotation angle.
        
        Current rotation angle. *)
    
    method private virtual on_done : [> `V2] t -> unit
    
    (** All information has been sent.
        
        This event is sent after all information about the libinput device has
        been sent.
        
        This allows changes to one or more river_libinput_device_v1 properties
        to be seen as atomic, even if they happen via multiple events. *)
    
    method min_version = 1l
  end
  
  (** Handler for a proxy with version >= 2. *)
  class virtual ['v] v2 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V2] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_removed : [> `V2] t -> unit
    
    (** The libinput device is removed.
        
        This event indicates that the libinput device has been removed.
        
        The server will send no further events on this object and ignore any
        request (other than river_libinput_device_v1.destroy) made after this
        event is sent. The client should destroy this object with the
        river_libinput_device_v1.destroy request to free up resources. *)
    
    method private virtual on_input_device : [> `V2] t -> device:([`River_input_device_v1], [> Imports.River_input_device_v1.versions], [`Client]) Proxy.t ->
                                             unit
    
    (** Corresponding river input device.
        
        The river_input_device_v1 corresponding to this libinput device.
        This event will always be the first event sent on the
        river_libinput_device_v1 object, and it will be sent exactly once. *)
    
    method private virtual on_send_events_support : [> `V2] t -> modes:Imports.River_libinput_device_v1.Send_events_modes.t ->
                                                    unit
    
    (** Supported send events modes.
        
        Supported send events modes. *)
    
    method private virtual on_send_events_default : [> `V2] t -> mode:Imports.River_libinput_device_v1.Send_events_modes.t ->
                                                    unit
    
    (** Default send events mode.
        
        Default send events mode. *)
    
    method private virtual on_send_events_current : [> `V2] t -> mode:Imports.River_libinput_device_v1.Send_events_modes.t ->
                                                    unit
    
    (** Current send events mode.
        
        Current send events mode. *)
    
    method private virtual on_tap_support : [> `V2] t -> finger_count:int32 -> unit
    
    (** Tap-to-click/drag support.
        
        The number of fingers supported for tap-to-click/drag.
        If finger_count is 0, tap-to-click and drag are unsupported. *)
    
    method private virtual on_tap_default : [> `V2] t -> state:Imports.River_libinput_device_v1.Tap_state.t -> unit
    
    (** Default tap-to-click state.
        
        Default tap-to-click state. *)
    
    method private virtual on_tap_current : [> `V2] t -> state:Imports.River_libinput_device_v1.Tap_state.t -> unit
    
    (** Current tap-to-click state.
        
        Current tap-to-click state. *)
    
    method private virtual on_tap_button_map_default : [> `V2] t -> button_map:Imports.River_libinput_device_v1.Tap_button_map.t ->
                                                       unit
    
    (** Default tap-to-click button map.
        
        Default tap-to-click button map. *)
    
    method private virtual on_tap_button_map_current : [> `V2] t -> button_map:Imports.River_libinput_device_v1.Tap_button_map.t ->
                                                       unit
    
    (** Current tap-to-click button map.
        
        Current tap-to-click button map. *)
    
    method private virtual on_drag_default : [> `V2] t -> state:Imports.River_libinput_device_v1.Drag_state.t -> unit
    
    (** Default tap-and-drag state.
        
        Default tap-and-drag state. *)
    
    method private virtual on_drag_current : [> `V2] t -> state:Imports.River_libinput_device_v1.Drag_state.t -> unit
    
    (** Current tap-and-drag state.
        
        Current tap-and-drag state. *)
    
    method private virtual on_drag_lock_default : [> `V2] t -> state:Imports.River_libinput_device_v1.Drag_lock_state.t ->
                                                  unit
    
    (** Default drag lock state.
        
        Default drag lock state. *)
    
    method private virtual on_drag_lock_current : [> `V2] t -> state:Imports.River_libinput_device_v1.Drag_lock_state.t ->
                                                  unit
    
    (** Current drag lock state.
        
        Current drag lock state. *)
    
    method private virtual on_three_finger_drag_support : [> `V2] t -> finger_count:int32 -> unit
    
    (** Three finger drag support.
        
        The number of fingers supported for three/four finger drag.
        If finger_count is less than 3, three finger drag is unsupported. *)
    
    method private virtual on_three_finger_drag_default : [> `V2] t -> state:Imports.River_libinput_device_v1.Three_finger_drag_state.t ->
                                                          unit
    
    (** Default three finger drag state.
        
        Default three finger drag state. *)
    
    method private virtual on_three_finger_drag_current : [> `V2] t -> state:Imports.River_libinput_device_v1.Three_finger_drag_state.t ->
                                                          unit
    
    (** Current three finger drag state.
        
        Current three finger drag state. *)
    
    method private virtual on_calibration_matrix_support : [> `V2] t -> supported:int32 -> unit
    
    (** Support for a calibration matrix.
        
        A calibration matrix is supported if the supported argument is non-zero. *)
    
    method private virtual on_calibration_matrix_default : [> `V2] t -> matrix:string -> unit
    
    (** Default calibration matrix.
        
        Default calibration matrix. *)
    
    method private virtual on_calibration_matrix_current : [> `V2] t -> matrix:string -> unit
    
    (** Current calibration matrix.
        
        Current calibration matrix. *)
    
    method private virtual on_accel_profiles_support : [> `V2] t -> profiles:Imports.River_libinput_device_v1.Accel_profiles.t ->
                                                       unit
    
    (** Supported acceleration profiles.
        
        Supported acceleration profiles. *)
    
    method private virtual on_accel_profile_default : [> `V2] t -> profile:Imports.River_libinput_device_v1.Accel_profile.t ->
                                                      unit
    
    (** Default acceleration profile.
        
        Default acceleration profile. *)
    
    method private virtual on_accel_profile_current : [> `V2] t -> profile:Imports.River_libinput_device_v1.Accel_profile.t ->
                                                      unit
    
    (** Current acceleration profile.
        
        Current acceleration profile. *)
    
    method private virtual on_accel_speed_default : [> `V2] t -> speed:string -> unit
    
    (** Default acceleration speed.
        
        Default acceleration speed. *)
    
    method private virtual on_accel_speed_current : [> `V2] t -> speed:string -> unit
    
    (** Current acceleration speed.
        
        Current acceleration speed. *)
    
    method private virtual on_natural_scroll_support : [> `V2] t -> supported:int32 -> unit
    
    (** Support for natural scroll.
        
        Natural scroll is supported if the supported argument is non-zero. *)
    
    method private virtual on_natural_scroll_default : [> `V2] t -> state:Imports.River_libinput_device_v1.Natural_scroll_state.t ->
                                                       unit
    
    (** Default natural scroll.
        
        Default natural scroll. *)
    
    method private virtual on_natural_scroll_current : [> `V2] t -> state:Imports.River_libinput_device_v1.Natural_scroll_state.t ->
                                                       unit
    
    (** Current natural scroll state.
        
        Current natural scroll. *)
    
    method private virtual on_left_handed_support : [> `V2] t -> supported:int32 -> unit
    
    (** Support for left-handed mode.
        
        Left-handed mode is supported if the supported argument is non-zero. *)
    
    method private virtual on_left_handed_default : [> `V2] t -> state:Imports.River_libinput_device_v1.Left_handed_state.t ->
                                                    unit
    
    (** Default left-handed mode.
        
        Default left-handed mode. *)
    
    method private virtual on_left_handed_current : [> `V2] t -> state:Imports.River_libinput_device_v1.Left_handed_state.t ->
                                                    unit
    
    (** Current left-handed mode state.
        
        Current left-handed mode. *)
    
    method private virtual on_click_method_support : [> `V2] t -> methods:Imports.River_libinput_device_v1.Click_methods.t ->
                                                     unit
    
    (** Supported click methods.
        
        The click methods supported by the device. *)
    
    method private virtual on_click_method_default : [> `V2] t -> method_:Imports.River_libinput_device_v1.Click_method.t ->
                                                     unit
    
    (** Default click method.
        
        Default click method. *)
    
    method private virtual on_click_method_current : [> `V2] t -> method_:Imports.River_libinput_device_v1.Click_method.t ->
                                                     unit
    
    (** Current click method.
        
        Current click method. *)
    
    method private virtual on_clickfinger_button_map_default : [> `V2] t -> button_map:Imports.River_libinput_device_v1.Clickfinger_button_map.t ->
                                                               unit
    
    (** Default clickfinger button map.
        
        Default clickfinger button map.
        Supported if click_methods.clickfinger is supported. *)
    
    method private virtual on_clickfinger_button_map_current : [> `V2] t -> button_map:Imports.River_libinput_device_v1.Clickfinger_button_map.t ->
                                                               unit
    
    (** Current clickfinger button map.
        
        Current clickfinger button map.
        Supported if click_methods.clickfinger is supported. *)
    
    method private virtual on_middle_emulation_support : [> `V2] t -> supported:int32 -> unit
    
    (** Support for middle mouse button emulation.
        
        Middle mouse button emulation is supported if the supported argument is
        non-zero. *)
    
    method private virtual on_middle_emulation_default : [> `V2] t -> state:Imports.River_libinput_device_v1.Middle_emulation_state.t ->
                                                         unit
    
    (** Default middle mouse button emulation.
        
        Default middle mouse button emulation. *)
    
    method private virtual on_middle_emulation_current : [> `V2] t -> state:Imports.River_libinput_device_v1.Middle_emulation_state.t ->
                                                         unit
    
    (** Current middle mouse button emulation state.
        
        Current middle mouse button emulation. *)
    
    method private virtual on_scroll_method_support : [> `V2] t -> methods:Imports.River_libinput_device_v1.Scroll_methods.t ->
                                                      unit
    
    (** Supported scroll methods.
        
        The scroll methods supported by the device. *)
    
    method private virtual on_scroll_method_default : [> `V2] t -> method_:Imports.River_libinput_device_v1.Scroll_method.t ->
                                                      unit
    
    (** Default scroll method.
        
        Default scroll method. *)
    
    method private virtual on_scroll_method_current : [> `V2] t -> method_:Imports.River_libinput_device_v1.Scroll_method.t ->
                                                      unit
    
    (** Current scroll method.
        
        Current scroll method. *)
    
    method private virtual on_scroll_button_default : [> `V2] t -> button:int32 -> unit
    
    (** Default scroll button.
        
        Default scroll button.
        Supported if scroll_methods.on_button_down is supported. *)
    
    method private virtual on_scroll_button_current : [> `V2] t -> button:int32 -> unit
    
    (** Current scroll button.
        
        Current scroll button.
        Supported if scroll_methods.on_button_down is supported. *)
    
    method private virtual on_scroll_button_lock_default : [> `V2] t -> state:Imports.River_libinput_device_v1.Scroll_button_lock_state.t ->
                                                           unit
    
    (** Default scroll button lock state.
        
        Default scroll button lock state.
        Supported if scroll_methods.on_button_down is supported. *)
    
    method private virtual on_scroll_button_lock_current : [> `V2] t -> state:Imports.River_libinput_device_v1.Scroll_button_lock_state.t ->
                                                           unit
    
    (** Current scroll button lock state.
        
        Current scroll button lock state.
        Supported if scroll_methods.on_button_down is supported. *)
    
    method private virtual on_dwt_support : [> `V2] t -> supported:int32 -> unit
    
    (** Support for disable-while-typing.
        
        Disable-while-typing is supported if the supported argument is
        non-zero. *)
    
    method private virtual on_dwt_default : [> `V2] t -> state:Imports.River_libinput_device_v1.Dwt_state.t -> unit
    
    (** Default disable-while-typing state.
        
        Default disable-while-typing state. *)
    
    method private virtual on_dwt_current : [> `V2] t -> state:Imports.River_libinput_device_v1.Dwt_state.t -> unit
    
    (** Current disable-while-typing state.
        
        Current disable-while-typing state. *)
    
    method private virtual on_dwtp_support : [> `V2] t -> supported:int32 -> unit
    
    (** Support for disable-while-trackpointing.
        
        Disable-while-trackpointing is supported if the supported argument is
        non-zero. *)
    
    method private virtual on_dwtp_default : [> `V2] t -> state:Imports.River_libinput_device_v1.Dwtp_state.t -> unit
    
    (** Default disable-while-trackpointing state.
        
        Default disable-while-trackpointing state. *)
    
    method private virtual on_dwtp_current : [> `V2] t -> state:Imports.River_libinput_device_v1.Dwtp_state.t -> unit
    
    (** Current disable-while-trackpointing state.
        
        Current disable-while-trackpointing state. *)
    
    method private virtual on_rotation_support : [> `V2] t -> supported:int32 -> unit
    
    (** Support for rotation.
        
        Rotation is supported if the supported argument is non-zero. *)
    
    method private virtual on_rotation_default : [> `V2] t -> angle:int32 -> unit
    
    (** Default rotation angle.
        
        Default rotation angle. *)
    
    method private virtual on_rotation_current : [> `V2] t -> angle:int32 -> unit
    
    (** Current rotation angle.
        
        Current rotation angle. *)
    
    method private virtual on_done : [> `V2] t -> unit
    
    (** All information has been sent.
        
        This event is sent after all information about the libinput device has
        been sent.
        
        This allows changes to one or more river_libinput_device_v1 properties
        to be seen as atomic, even if they happen via multiple events. *)
    
    method min_version = 2l
  end
end

(** Acceleration config.
    
    The result returned by libinput on setting configuration for a device. *)
module River_libinput_accel_config_v1 = struct
  type 'v t = ([`River_libinput_accel_config_v1], 'v, [`Client]) Proxy.t
  module Error = River_libinput_config_v1_proto.River_libinput_accel_config_v1.Error
  
  module Accel_type = River_libinput_config_v1_proto.River_libinput_accel_config_v1.Accel_type
  
  (** {2 Version 1} *)
  
  (** Define custom acceleration function.
      
      Defines the acceleration function for a given movement type
      in an acceleration configuration with custom accel profile. *)
  let set_points (_t:([< `V1] as 'v) t) (result:([`River_libinput_result_v1], 'v, [`Client]) #Proxy.Handler.t) ~type_ ~step ~points =
    let __result = Proxy.spawn _t result in
    let _msg = Proxy.alloc _t ~op:1 ~ints:4 ~strings:[] ~arrays:[step;
    points] in
    Msg.add_int _msg (Proxy.id __result);
    Msg.add_int _msg (Imports.River_libinput_accel_config_v1.Accel_type.to_int32 type_);
    Msg.add_array _msg step;
    Msg.add_array _msg points;
    Proxy.send _t _msg;
    __result
  
  (** Destroy the accel object.
      
      This request indicates that the client will no longer use the accel
      config object and that it may be safely destroyed. *)
  let destroy (_t:([< `V1] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:0 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg;
    Proxy.shutdown_send _t
  
  (**/**)
  class ['v] _handlers_unsafe = object (_self : (_, 'v, _) #Proxy.Handler.t)
    method user_data = S.No_data
    method metadata = (module River_libinput_config_v1_proto.River_libinput_accel_config_v1)
    method max_version = 1l
    
    
    method dispatch (_proxy : 'v t) _msg =
      let _proxy = Proxy.cast_version _proxy in
      match Msg.op _msg with
      | _ -> assert false
  end
  (**/**)
  
  (** {2 Handlers}
      Note: Servers will always want to use [v1].
   *)
  
  
  (** Handler for a proxy with version >= 1. *)
  class ['v] v1 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V1] as 'v] _handlers_unsafe
    (**/**)
    method min_version = 1l
  end
end

(** Config application result.
    
    The result returned by libinput on setting configuration for a device. *)
module River_libinput_result_v1 = struct
  type 'v t = ([`River_libinput_result_v1], 'v, [`Client]) Proxy.t
  
  (** {2 Version 1} *)
  
  (**/**)
  class virtual ['v] _handlers_unsafe = object (_self : (_, 'v, _) #Proxy.Handler.t)
    method user_data = S.No_data
    method metadata = (module River_libinput_config_v1_proto.River_libinput_result_v1)
    method max_version = 1l
    
    method private virtual on_success :  unit
    
    method private virtual on_unsupported :  unit
    
    method private virtual on_invalid :  unit
    
    
    method dispatch (_proxy : 'v t) _msg =
      let _proxy = Proxy.cast_version _proxy in
      match Msg.op _msg with
      | 0 ->
        Proxy.shutdown_recv _proxy;
        _self#on_success 
      | 1 ->
        Proxy.shutdown_recv _proxy;
        _self#on_unsupported 
      | 2 ->
        Proxy.shutdown_recv _proxy;
        _self#on_invalid 
      | _ -> assert false
  end
  (**/**)
  
  (** {2 Handlers}
      Note: Servers will always want to use [v1].
   *)
  
  
  (** Handler for a proxy with version >= 1. *)
  class virtual ['v] v1 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V1] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_success :  unit
    
    (** Config success.
        
        The configuration was successfully applied to the device. *)
    
    method private virtual on_unsupported :  unit
    
    (** Config unsupported.
        
        The configuration is unsupported by the device and was ignored. *)
    
    method private virtual on_invalid :  unit
    
    (** Config invalid.
        
        The configuration is invalid and was ignored. *)
    
    method min_version = 1l
  end
end