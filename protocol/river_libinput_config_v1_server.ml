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
  type 'v t = ([ `River_libinput_config_v1 ], 'v, [ `Server ]) Proxy.t

  module Error = River_libinput_config_v1_proto.River_libinput_config_v1.Error

  (** {2 Version 1, 2} *)

  (** New libinput device.

      A new libinput device has been created. Not every river_input_device_v1
      is necessarily a libinput device as well. *)
  let libinput_device
        (_t : ([< `V1 | `V2 ] as 'v) t)
        (id : ([ `River_libinput_device_v1 ], 'v, [ `Server ]) #Proxy.Handler.t)
    =
    let __id = Proxy.spawn _t id in
    let _msg = Proxy.alloc _t ~op:1 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id __id);
    Proxy.send _t _msg;
    __id
  ;;

  (** The server has finished with the object.

      This event indicates that the server will send no further events on this
      object. The client should destroy the object. See
      river_libinput_config_v1.destroy for more information. *)
  let finished (_t : ([< `V1 | `V2 ] as 'v) t) =
    let _msg = Proxy.alloc _t ~op:0 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  ;;

  (**/**)

  class virtual ['v] _handlers_unsafe =
    object (_self : (_, 'v, _) #Proxy.Handler.t)
      method user_data = S.No_data
      method metadata = (module River_libinput_config_v1_proto.River_libinput_config_v1)
      method max_version = 2l
      method private virtual on_stop : [> ] t -> unit
      method private virtual on_destroy : [> ] t -> unit

      method
        private
        virtual on_create_accel_config
        : [> ] t
          -> ([ `River_libinput_accel_config_v1 ], 'v, [ `Server ]) Proxy.t
          -> profile:Imports.River_libinput_device_v1.Accel_profile.t
          -> unit

      method dispatch (_proxy : 'v t) _msg =
        let _proxy = Proxy.cast_version _proxy in
        match Msg.op _msg with
        | 0 -> _self#on_stop _proxy
        | 1 ->
          Proxy.shutdown_recv _proxy;
          _self#on_destroy _proxy
        | 2 ->
          let id : ([ `River_libinput_accel_config_v1 ], _, _) Proxy.t =
            Msg.get_int _msg
            |> Proxy.Handler.accept_new
                 _proxy
                 (module Imports.River_libinput_accel_config_v1)
          in
          let profile =
            Msg.get_int _msg |> Imports.River_libinput_device_v1.Accel_profile.of_int32
          in
          _self#on_create_accel_config _proxy id ~profile
        | _ -> assert false
    end

  (**/**)

  (** {2 Handlers}
      Note: Servers will always want to use [v1].
   *)

  (** Handler for a proxy with version >= 1. *)
  class virtual ['v] v1 =
    object (_ : (_, 'v, _) #Proxy.Service_handler.t)

      (**/**)

      inherit [[< `V1 | `V2 ] as 'v] _handlers_unsafe

      (**/**)

      method private virtual on_stop : [> `V1 | `V2 ] t -> unit

      (** Stop sending events.

        This request indicates that the client no longer wishes to receive
        events on this object.

        The Wayland protocol is asynchronous, which means the server may send
        further events until the stop request is processed. The client must wait
        for a river_libinput_config_v1.finished event before destroying this
        object. *)

      method private virtual on_destroy : [> `V1 | `V2 ] t -> unit

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

      method
        private
        virtual on_create_accel_config
        : [> `V1 | `V2 ] t
          -> ([ `River_libinput_accel_config_v1 ], 'v, [ `Server ]) Proxy.t
          -> profile:Imports.River_libinput_device_v1.Accel_profile.t
          -> unit

      (** Create a acceleration config.

        Create a acceleration config which can be applied
        with river_libinput_device_v1.apply_accel_config. *)

      method min_version = 1l
      method bind_version : [ `V1 ] = `V1
    end

  (** Handler for a proxy with version >= 2. *)
  class virtual ['v] v2 =
    object (_ : (_, 'v, _) #Proxy.Service_handler.t)

      (**/**)

      inherit [[< `V2 ] as 'v] _handlers_unsafe

      (**/**)

      method private virtual on_stop : [> `V2 ] t -> unit

      (** Stop sending events.

        This request indicates that the client no longer wishes to receive
        events on this object.

        The Wayland protocol is asynchronous, which means the server may send
        further events until the stop request is processed. The client must wait
        for a river_libinput_config_v1.finished event before destroying this
        object. *)

      method private virtual on_destroy : [> `V2 ] t -> unit

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

      method
        private
        virtual on_create_accel_config
        : [> `V2 ] t
          -> ([ `River_libinput_accel_config_v1 ], 'v, [ `Server ]) Proxy.t
          -> profile:Imports.River_libinput_device_v1.Accel_profile.t
          -> unit

      (** Create a acceleration config.

        Create a acceleration config which can be applied
        with river_libinput_device_v1.apply_accel_config. *)

      method min_version = 2l
      method bind_version : [ `V2 ] = `V2
    end
end

(** A libinput device.

    In general, *_support events will be sent exactly once directly after the
    river_libinput_device_v1 is created. *_default events will be sent after
    *_support events if the config option is supported, and *_current events
    willl be sent after the *_default events and again whenever the config
    option is changed. *)
module River_libinput_device_v1 = struct
  type 'v t = ([ `River_libinput_device_v1 ], 'v, [ `Server ]) Proxy.t

  module Error = River_libinput_config_v1_proto.River_libinput_device_v1.Error

  module Send_events_modes =
    River_libinput_config_v1_proto.River_libinput_device_v1.Send_events_modes

  module Tap_state = River_libinput_config_v1_proto.River_libinput_device_v1.Tap_state

  module Tap_button_map =
    River_libinput_config_v1_proto.River_libinput_device_v1.Tap_button_map

  module Drag_state = River_libinput_config_v1_proto.River_libinput_device_v1.Drag_state

  module Drag_lock_state =
    River_libinput_config_v1_proto.River_libinput_device_v1.Drag_lock_state

  module Three_finger_drag_state =
    River_libinput_config_v1_proto.River_libinput_device_v1.Three_finger_drag_state

  module Accel_profile =
    River_libinput_config_v1_proto.River_libinput_device_v1.Accel_profile

  module Accel_profiles =
    River_libinput_config_v1_proto.River_libinput_device_v1.Accel_profiles

  module Natural_scroll_state =
    River_libinput_config_v1_proto.River_libinput_device_v1.Natural_scroll_state

  module Left_handed_state =
    River_libinput_config_v1_proto.River_libinput_device_v1.Left_handed_state

  module Click_method =
    River_libinput_config_v1_proto.River_libinput_device_v1.Click_method

  module Click_methods =
    River_libinput_config_v1_proto.River_libinput_device_v1.Click_methods

  module Clickfinger_button_map =
    River_libinput_config_v1_proto.River_libinput_device_v1.Clickfinger_button_map

  module Middle_emulation_state =
    River_libinput_config_v1_proto.River_libinput_device_v1.Middle_emulation_state

  module Scroll_method =
    River_libinput_config_v1_proto.River_libinput_device_v1.Scroll_method

  module Scroll_methods =
    River_libinput_config_v1_proto.River_libinput_device_v1.Scroll_methods

  module Scroll_button_lock_state =
    River_libinput_config_v1_proto.River_libinput_device_v1.Scroll_button_lock_state

  module Dwt_state = River_libinput_config_v1_proto.River_libinput_device_v1.Dwt_state
  module Dwtp_state = River_libinput_config_v1_proto.River_libinput_device_v1.Dwtp_state

  (** {2 Version 1} *)

  (** Current rotation angle.

      Current rotation angle. *)
  let rotation_current (_t : ([< `V1 | `V2 ] as 'v) t) ~angle =
    let _msg = Proxy.alloc _t ~op:54 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg angle;
    Proxy.send _t _msg
  ;;

  (** Default rotation angle.

      Default rotation angle. *)
  let rotation_default (_t : ([< `V1 | `V2 ] as 'v) t) ~angle =
    let _msg = Proxy.alloc _t ~op:53 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg angle;
    Proxy.send _t _msg
  ;;

  (** Support for rotation.

      Rotation is supported if the supported argument is non-zero. *)
  let rotation_support (_t : ([< `V1 | `V2 ] as 'v) t) ~supported =
    let _msg = Proxy.alloc _t ~op:52 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg supported;
    Proxy.send _t _msg
  ;;

  (** Current disable-while-trackpointing state.

      Current disable-while-trackpointing state. *)
  let dwtp_current (_t : ([< `V1 | `V2 ] as 'v) t) ~state =
    let _msg = Proxy.alloc _t ~op:51 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Imports.River_libinput_device_v1.Dwtp_state.to_int32 state);
    Proxy.send _t _msg
  ;;

  (** Default disable-while-trackpointing state.

      Default disable-while-trackpointing state. *)
  let dwtp_default (_t : ([< `V1 | `V2 ] as 'v) t) ~state =
    let _msg = Proxy.alloc _t ~op:50 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Imports.River_libinput_device_v1.Dwtp_state.to_int32 state);
    Proxy.send _t _msg
  ;;

  (** Support for disable-while-trackpointing.

      Disable-while-trackpointing is supported if the supported argument is
      non-zero. *)
  let dwtp_support (_t : ([< `V1 | `V2 ] as 'v) t) ~supported =
    let _msg = Proxy.alloc _t ~op:49 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg supported;
    Proxy.send _t _msg
  ;;

  (** Current disable-while-typing state.

      Current disable-while-typing state. *)
  let dwt_current (_t : ([< `V1 | `V2 ] as 'v) t) ~state =
    let _msg = Proxy.alloc _t ~op:48 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Imports.River_libinput_device_v1.Dwt_state.to_int32 state);
    Proxy.send _t _msg
  ;;

  (** Default disable-while-typing state.

      Default disable-while-typing state. *)
  let dwt_default (_t : ([< `V1 | `V2 ] as 'v) t) ~state =
    let _msg = Proxy.alloc _t ~op:47 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Imports.River_libinput_device_v1.Dwt_state.to_int32 state);
    Proxy.send _t _msg
  ;;

  (** Support for disable-while-typing.

      Disable-while-typing is supported if the supported argument is
      non-zero. *)
  let dwt_support (_t : ([< `V1 | `V2 ] as 'v) t) ~supported =
    let _msg = Proxy.alloc _t ~op:46 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg supported;
    Proxy.send _t _msg
  ;;

  (** Current scroll button lock state.

      Current scroll button lock state.
      Supported if scroll_methods.on_button_down is supported. *)
  let scroll_button_lock_current (_t : ([< `V1 | `V2 ] as 'v) t) ~state =
    let _msg = Proxy.alloc _t ~op:45 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int
      _msg
      (Imports.River_libinput_device_v1.Scroll_button_lock_state.to_int32 state);
    Proxy.send _t _msg
  ;;

  (** Default scroll button lock state.

      Default scroll button lock state.
      Supported if scroll_methods.on_button_down is supported. *)
  let scroll_button_lock_default (_t : ([< `V1 | `V2 ] as 'v) t) ~state =
    let _msg = Proxy.alloc _t ~op:44 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int
      _msg
      (Imports.River_libinput_device_v1.Scroll_button_lock_state.to_int32 state);
    Proxy.send _t _msg
  ;;

  (** Current scroll button.

      Current scroll button.
      Supported if scroll_methods.on_button_down is supported. *)
  let scroll_button_current (_t : ([< `V1 | `V2 ] as 'v) t) ~button =
    let _msg = Proxy.alloc _t ~op:43 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg button;
    Proxy.send _t _msg
  ;;

  (** Default scroll button.

      Default scroll button.
      Supported if scroll_methods.on_button_down is supported. *)
  let scroll_button_default (_t : ([< `V1 | `V2 ] as 'v) t) ~button =
    let _msg = Proxy.alloc _t ~op:42 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg button;
    Proxy.send _t _msg
  ;;

  (** Current scroll method.

      Current scroll method. *)
  let scroll_method_current (_t : ([< `V1 | `V2 ] as 'v) t) ~method_ =
    let _msg = Proxy.alloc _t ~op:41 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Imports.River_libinput_device_v1.Scroll_method.to_int32 method_);
    Proxy.send _t _msg
  ;;

  (** Default scroll method.

      Default scroll method. *)
  let scroll_method_default (_t : ([< `V1 | `V2 ] as 'v) t) ~method_ =
    let _msg = Proxy.alloc _t ~op:40 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Imports.River_libinput_device_v1.Scroll_method.to_int32 method_);
    Proxy.send _t _msg
  ;;

  (** Supported scroll methods.

      The scroll methods supported by the device. *)
  let scroll_method_support (_t : ([< `V1 | `V2 ] as 'v) t) ~methods =
    let _msg = Proxy.alloc _t ~op:39 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Imports.River_libinput_device_v1.Scroll_methods.to_int32 methods);
    Proxy.send _t _msg
  ;;

  (** Current middle mouse button emulation state.

      Current middle mouse button emulation. *)
  let middle_emulation_current (_t : ([< `V1 | `V2 ] as 'v) t) ~state =
    let _msg = Proxy.alloc _t ~op:38 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int
      _msg
      (Imports.River_libinput_device_v1.Middle_emulation_state.to_int32 state);
    Proxy.send _t _msg
  ;;

  (** Default middle mouse button emulation.

      Default middle mouse button emulation. *)
  let middle_emulation_default (_t : ([< `V1 | `V2 ] as 'v) t) ~state =
    let _msg = Proxy.alloc _t ~op:37 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int
      _msg
      (Imports.River_libinput_device_v1.Middle_emulation_state.to_int32 state);
    Proxy.send _t _msg
  ;;

  (** Support for middle mouse button emulation.

      Middle mouse button emulation is supported if the supported argument is
      non-zero. *)
  let middle_emulation_support (_t : ([< `V1 | `V2 ] as 'v) t) ~supported =
    let _msg = Proxy.alloc _t ~op:36 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg supported;
    Proxy.send _t _msg
  ;;

  (** Current clickfinger button map.

      Current clickfinger button map.
      Supported if click_methods.clickfinger is supported. *)
  let clickfinger_button_map_current (_t : ([< `V1 | `V2 ] as 'v) t) ~button_map =
    let _msg = Proxy.alloc _t ~op:35 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int
      _msg
      (Imports.River_libinput_device_v1.Clickfinger_button_map.to_int32 button_map);
    Proxy.send _t _msg
  ;;

  (** Default clickfinger button map.

      Default clickfinger button map.
      Supported if click_methods.clickfinger is supported. *)
  let clickfinger_button_map_default (_t : ([< `V1 | `V2 ] as 'v) t) ~button_map =
    let _msg = Proxy.alloc _t ~op:34 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int
      _msg
      (Imports.River_libinput_device_v1.Clickfinger_button_map.to_int32 button_map);
    Proxy.send _t _msg
  ;;

  (** Current click method.

      Current click method. *)
  let click_method_current (_t : ([< `V1 | `V2 ] as 'v) t) ~method_ =
    let _msg = Proxy.alloc _t ~op:33 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Imports.River_libinput_device_v1.Click_method.to_int32 method_);
    Proxy.send _t _msg
  ;;

  (** Default click method.

      Default click method. *)
  let click_method_default (_t : ([< `V1 | `V2 ] as 'v) t) ~method_ =
    let _msg = Proxy.alloc _t ~op:32 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Imports.River_libinput_device_v1.Click_method.to_int32 method_);
    Proxy.send _t _msg
  ;;

  (** Supported click methods.

      The click methods supported by the device. *)
  let click_method_support (_t : ([< `V1 | `V2 ] as 'v) t) ~methods =
    let _msg = Proxy.alloc _t ~op:31 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Imports.River_libinput_device_v1.Click_methods.to_int32 methods);
    Proxy.send _t _msg
  ;;

  (** Current left-handed mode state.

      Current left-handed mode. *)
  let left_handed_current (_t : ([< `V1 | `V2 ] as 'v) t) ~state =
    let _msg = Proxy.alloc _t ~op:30 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Imports.River_libinput_device_v1.Left_handed_state.to_int32 state);
    Proxy.send _t _msg
  ;;

  (** Default left-handed mode.

      Default left-handed mode. *)
  let left_handed_default (_t : ([< `V1 | `V2 ] as 'v) t) ~state =
    let _msg = Proxy.alloc _t ~op:29 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Imports.River_libinput_device_v1.Left_handed_state.to_int32 state);
    Proxy.send _t _msg
  ;;

  (** Support for left-handed mode.

      Left-handed mode is supported if the supported argument is non-zero. *)
  let left_handed_support (_t : ([< `V1 | `V2 ] as 'v) t) ~supported =
    let _msg = Proxy.alloc _t ~op:28 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg supported;
    Proxy.send _t _msg
  ;;

  (** Current natural scroll state.

      Current natural scroll. *)
  let natural_scroll_current (_t : ([< `V1 | `V2 ] as 'v) t) ~state =
    let _msg = Proxy.alloc _t ~op:27 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int
      _msg
      (Imports.River_libinput_device_v1.Natural_scroll_state.to_int32 state);
    Proxy.send _t _msg
  ;;

  (** Default natural scroll.

      Default natural scroll. *)
  let natural_scroll_default (_t : ([< `V1 | `V2 ] as 'v) t) ~state =
    let _msg = Proxy.alloc _t ~op:26 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int
      _msg
      (Imports.River_libinput_device_v1.Natural_scroll_state.to_int32 state);
    Proxy.send _t _msg
  ;;

  (** Support for natural scroll.

      Natural scroll is supported if the supported argument is non-zero. *)
  let natural_scroll_support (_t : ([< `V1 | `V2 ] as 'v) t) ~supported =
    let _msg = Proxy.alloc _t ~op:25 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg supported;
    Proxy.send _t _msg
  ;;

  (** Current acceleration speed.

      Current acceleration speed. *)
  let accel_speed_current (_t : ([< `V1 | `V2 ] as 'v) t) ~speed =
    let _msg = Proxy.alloc _t ~op:24 ~ints:1 ~strings:[] ~arrays:[ speed ] in
    Msg.add_array _msg speed;
    Proxy.send _t _msg
  ;;

  (** Default acceleration speed.

      Default acceleration speed. *)
  let accel_speed_default (_t : ([< `V1 | `V2 ] as 'v) t) ~speed =
    let _msg = Proxy.alloc _t ~op:23 ~ints:1 ~strings:[] ~arrays:[ speed ] in
    Msg.add_array _msg speed;
    Proxy.send _t _msg
  ;;

  (** Current acceleration profile.

      Current acceleration profile. *)
  let accel_profile_current (_t : ([< `V1 | `V2 ] as 'v) t) ~profile =
    let _msg = Proxy.alloc _t ~op:22 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Imports.River_libinput_device_v1.Accel_profile.to_int32 profile);
    Proxy.send _t _msg
  ;;

  (** Default acceleration profile.

      Default acceleration profile. *)
  let accel_profile_default (_t : ([< `V1 | `V2 ] as 'v) t) ~profile =
    let _msg = Proxy.alloc _t ~op:21 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Imports.River_libinput_device_v1.Accel_profile.to_int32 profile);
    Proxy.send _t _msg
  ;;

  (** Supported acceleration profiles.

      Supported acceleration profiles. *)
  let accel_profiles_support (_t : ([< `V1 | `V2 ] as 'v) t) ~profiles =
    let _msg = Proxy.alloc _t ~op:20 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Imports.River_libinput_device_v1.Accel_profiles.to_int32 profiles);
    Proxy.send _t _msg
  ;;

  (** Current calibration matrix.

      Current calibration matrix. *)
  let calibration_matrix_current (_t : ([< `V1 | `V2 ] as 'v) t) ~matrix =
    let _msg = Proxy.alloc _t ~op:19 ~ints:1 ~strings:[] ~arrays:[ matrix ] in
    Msg.add_array _msg matrix;
    Proxy.send _t _msg
  ;;

  (** Default calibration matrix.

      Default calibration matrix. *)
  let calibration_matrix_default (_t : ([< `V1 | `V2 ] as 'v) t) ~matrix =
    let _msg = Proxy.alloc _t ~op:18 ~ints:1 ~strings:[] ~arrays:[ matrix ] in
    Msg.add_array _msg matrix;
    Proxy.send _t _msg
  ;;

  (** Support for a calibration matrix.

      A calibration matrix is supported if the supported argument is non-zero. *)
  let calibration_matrix_support (_t : ([< `V1 | `V2 ] as 'v) t) ~supported =
    let _msg = Proxy.alloc _t ~op:17 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg supported;
    Proxy.send _t _msg
  ;;

  (** Current three finger drag state.

      Current three finger drag state. *)
  let three_finger_drag_current (_t : ([< `V1 | `V2 ] as 'v) t) ~state =
    let _msg = Proxy.alloc _t ~op:16 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int
      _msg
      (Imports.River_libinput_device_v1.Three_finger_drag_state.to_int32 state);
    Proxy.send _t _msg
  ;;

  (** Default three finger drag state.

      Default three finger drag state. *)
  let three_finger_drag_default (_t : ([< `V1 | `V2 ] as 'v) t) ~state =
    let _msg = Proxy.alloc _t ~op:15 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int
      _msg
      (Imports.River_libinput_device_v1.Three_finger_drag_state.to_int32 state);
    Proxy.send _t _msg
  ;;

  (** Three finger drag support.

      The number of fingers supported for three/four finger drag.
      If finger_count is less than 3, three finger drag is unsupported. *)
  let three_finger_drag_support (_t : ([< `V1 | `V2 ] as 'v) t) ~finger_count =
    let _msg = Proxy.alloc _t ~op:14 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg finger_count;
    Proxy.send _t _msg
  ;;

  (** Current drag lock state.

      Current drag lock state. *)
  let drag_lock_current (_t : ([< `V1 | `V2 ] as 'v) t) ~state =
    let _msg = Proxy.alloc _t ~op:13 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Imports.River_libinput_device_v1.Drag_lock_state.to_int32 state);
    Proxy.send _t _msg
  ;;

  (** Default drag lock state.

      Default drag lock state. *)
  let drag_lock_default (_t : ([< `V1 | `V2 ] as 'v) t) ~state =
    let _msg = Proxy.alloc _t ~op:12 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Imports.River_libinput_device_v1.Drag_lock_state.to_int32 state);
    Proxy.send _t _msg
  ;;

  (** Current tap-and-drag state.

      Current tap-and-drag state. *)
  let drag_current (_t : ([< `V1 | `V2 ] as 'v) t) ~state =
    let _msg = Proxy.alloc _t ~op:11 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Imports.River_libinput_device_v1.Drag_state.to_int32 state);
    Proxy.send _t _msg
  ;;

  (** Default tap-and-drag state.

      Default tap-and-drag state. *)
  let drag_default (_t : ([< `V1 | `V2 ] as 'v) t) ~state =
    let _msg = Proxy.alloc _t ~op:10 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Imports.River_libinput_device_v1.Drag_state.to_int32 state);
    Proxy.send _t _msg
  ;;

  (** Current tap-to-click button map.

      Current tap-to-click button map. *)
  let tap_button_map_current (_t : ([< `V1 | `V2 ] as 'v) t) ~button_map =
    let _msg = Proxy.alloc _t ~op:9 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Imports.River_libinput_device_v1.Tap_button_map.to_int32 button_map);
    Proxy.send _t _msg
  ;;

  (** Default tap-to-click button map.

      Default tap-to-click button map. *)
  let tap_button_map_default (_t : ([< `V1 | `V2 ] as 'v) t) ~button_map =
    let _msg = Proxy.alloc _t ~op:8 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Imports.River_libinput_device_v1.Tap_button_map.to_int32 button_map);
    Proxy.send _t _msg
  ;;

  (** Current tap-to-click state.

      Current tap-to-click state. *)
  let tap_current (_t : ([< `V1 | `V2 ] as 'v) t) ~state =
    let _msg = Proxy.alloc _t ~op:7 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Imports.River_libinput_device_v1.Tap_state.to_int32 state);
    Proxy.send _t _msg
  ;;

  (** Default tap-to-click state.

      Default tap-to-click state. *)
  let tap_default (_t : ([< `V1 | `V2 ] as 'v) t) ~state =
    let _msg = Proxy.alloc _t ~op:6 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Imports.River_libinput_device_v1.Tap_state.to_int32 state);
    Proxy.send _t _msg
  ;;

  (** Tap-to-click/drag support.

      The number of fingers supported for tap-to-click/drag.
      If finger_count is 0, tap-to-click and drag are unsupported. *)
  let tap_support (_t : ([< `V1 | `V2 ] as 'v) t) ~finger_count =
    let _msg = Proxy.alloc _t ~op:5 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg finger_count;
    Proxy.send _t _msg
  ;;

  (** Current send events mode.

      Current send events mode. *)
  let send_events_current (_t : ([< `V1 | `V2 ] as 'v) t) ~mode =
    let _msg = Proxy.alloc _t ~op:4 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Imports.River_libinput_device_v1.Send_events_modes.to_int32 mode);
    Proxy.send _t _msg
  ;;

  (** Default send events mode.

      Default send events mode. *)
  let send_events_default (_t : ([< `V1 | `V2 ] as 'v) t) ~mode =
    let _msg = Proxy.alloc _t ~op:3 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Imports.River_libinput_device_v1.Send_events_modes.to_int32 mode);
    Proxy.send _t _msg
  ;;

  (** Supported send events modes.

      Supported send events modes. *)
  let send_events_support (_t : ([< `V1 | `V2 ] as 'v) t) ~modes =
    let _msg = Proxy.alloc _t ~op:2 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Imports.River_libinput_device_v1.Send_events_modes.to_int32 modes);
    Proxy.send _t _msg
  ;;

  (** Corresponding river input device.

      The river_input_device_v1 corresponding to this libinput device.
      This event will always be the first event sent on the
      river_libinput_device_v1 object, and it will be sent exactly once. *)
  let input_device
        (_t : ([< `V1 | `V2 ] as 'v) t)
        ~(device : ([ `River_input_device_v1 ], _, [ `Server ]) Proxy.t)
    =
    let _msg = Proxy.alloc _t ~op:1 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id device);
    Proxy.send _t _msg
  ;;

  (** The libinput device is removed.

      This event indicates that the libinput device has been removed.

      The server will send no further events on this object and ignore any
      request (other than river_libinput_device_v1.destroy) made after this
      event is sent. The client should destroy this object with the
      river_libinput_device_v1.destroy request to free up resources. *)
  let removed (_t : ([< `V1 | `V2 ] as 'v) t) =
    let _msg = Proxy.alloc _t ~op:0 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  ;;

  (** {2 Version 2} *)

  (** All information has been sent.

      This event is sent after all information about the libinput device has
      been sent.

      This allows changes to one or more river_libinput_device_v1 properties
      to be seen as atomic, even if they happen via multiple events. *)
  let done_ (_t : ([< `V2 ] as 'v) t) =
    let _msg = Proxy.alloc _t ~op:55 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  ;;

  (**/**)

  class virtual ['v] _handlers_unsafe =
    object (_self : (_, 'v, _) #Proxy.Handler.t)
      method user_data = S.No_data
      method metadata = (module River_libinput_config_v1_proto.River_libinput_device_v1)
      method max_version = 2l
      method private virtual on_destroy : [> ] t -> unit

      method
        private
        virtual on_set_send_events
        : [> ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> mode:Imports.River_libinput_device_v1.Send_events_modes.t
          -> unit

      method
        private
        virtual on_set_tap
        : [> ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> state:Imports.River_libinput_device_v1.Tap_state.t
          -> unit

      method
        private
        virtual on_set_tap_button_map
        : [> ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> button_map:Imports.River_libinput_device_v1.Tap_button_map.t
          -> unit

      method
        private
        virtual on_set_drag
        : [> ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> state:Imports.River_libinput_device_v1.Drag_state.t
          -> unit

      method
        private
        virtual on_set_drag_lock
        : [> ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> state:Imports.River_libinput_device_v1.Drag_lock_state.t
          -> unit

      method
        private
        virtual on_set_three_finger_drag
        : [> ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> state:Imports.River_libinput_device_v1.Three_finger_drag_state.t
          -> unit

      method
        private
        virtual on_set_calibration_matrix
        : [> ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> matrix:string
          -> unit

      method
        private
        virtual on_set_accel_profile
        : [> ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> profile:Imports.River_libinput_device_v1.Accel_profile.t
          -> unit

      method
        private
        virtual on_set_accel_speed
        : [> ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> speed:string
          -> unit

      method
        private
        virtual on_apply_accel_config
        : [> ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> config:
               ( [ `River_libinput_accel_config_v1 ]
                 , [> Imports.River_libinput_accel_config_v1.versions ]
                 , [ `Server ] )
                 Proxy.t
          -> unit

      method
        private
        virtual on_set_natural_scroll
        : [> ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> state:Imports.River_libinput_device_v1.Natural_scroll_state.t
          -> unit

      method
        private
        virtual on_set_left_handed
        : [> ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> state:Imports.River_libinput_device_v1.Left_handed_state.t
          -> unit

      method
        private
        virtual on_set_click_method
        : [> ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> method_:Imports.River_libinput_device_v1.Click_method.t
          -> unit

      method
        private
        virtual on_set_clickfinger_button_map
        : [> ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> button_map:Imports.River_libinput_device_v1.Clickfinger_button_map.t
          -> unit

      method
        private
        virtual on_set_middle_emulation
        : [> ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> state:Imports.River_libinput_device_v1.Middle_emulation_state.t
          -> unit

      method
        private
        virtual on_set_scroll_method
        : [> ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> method_:Imports.River_libinput_device_v1.Scroll_method.t
          -> unit

      method
        private
        virtual on_set_scroll_button
        : [> ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> button:int32
          -> unit

      method
        private
        virtual on_set_scroll_button_lock
        : [> ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> state:Imports.River_libinput_device_v1.Scroll_button_lock_state.t
          -> unit

      method
        private
        virtual on_set_dwt
        : [> ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> state:Imports.River_libinput_device_v1.Dwt_state.t
          -> unit

      method
        private
        virtual on_set_dwtp
        : [> ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> state:Imports.River_libinput_device_v1.Dwtp_state.t
          -> unit

      method
        private
        virtual on_set_rotation
        : [> ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> angle:int32
          -> unit

      method dispatch (_proxy : 'v t) _msg =
        let _proxy = Proxy.cast_version _proxy in
        match Msg.op _msg with
        | 0 ->
          Proxy.shutdown_recv _proxy;
          _self#on_destroy _proxy
        | 1 ->
          let result : ([ `River_libinput_result_v1 ], _, _) Proxy.t =
            Msg.get_int _msg
            |> Proxy.Handler.accept_new _proxy (module Imports.River_libinput_result_v1)
          in
          let mode =
            Msg.get_int _msg
            |> Imports.River_libinput_device_v1.Send_events_modes.of_int32
          in
          _self#on_set_send_events _proxy result ~mode
        | 2 ->
          let result : ([ `River_libinput_result_v1 ], _, _) Proxy.t =
            Msg.get_int _msg
            |> Proxy.Handler.accept_new _proxy (module Imports.River_libinput_result_v1)
          in
          let state =
            Msg.get_int _msg |> Imports.River_libinput_device_v1.Tap_state.of_int32
          in
          _self#on_set_tap _proxy result ~state
        | 3 ->
          let result : ([ `River_libinput_result_v1 ], _, _) Proxy.t =
            Msg.get_int _msg
            |> Proxy.Handler.accept_new _proxy (module Imports.River_libinput_result_v1)
          in
          let button_map =
            Msg.get_int _msg |> Imports.River_libinput_device_v1.Tap_button_map.of_int32
          in
          _self#on_set_tap_button_map _proxy result ~button_map
        | 4 ->
          let result : ([ `River_libinput_result_v1 ], _, _) Proxy.t =
            Msg.get_int _msg
            |> Proxy.Handler.accept_new _proxy (module Imports.River_libinput_result_v1)
          in
          let state =
            Msg.get_int _msg |> Imports.River_libinput_device_v1.Drag_state.of_int32
          in
          _self#on_set_drag _proxy result ~state
        | 5 ->
          let result : ([ `River_libinput_result_v1 ], _, _) Proxy.t =
            Msg.get_int _msg
            |> Proxy.Handler.accept_new _proxy (module Imports.River_libinput_result_v1)
          in
          let state =
            Msg.get_int _msg |> Imports.River_libinput_device_v1.Drag_lock_state.of_int32
          in
          _self#on_set_drag_lock _proxy result ~state
        | 6 ->
          let result : ([ `River_libinput_result_v1 ], _, _) Proxy.t =
            Msg.get_int _msg
            |> Proxy.Handler.accept_new _proxy (module Imports.River_libinput_result_v1)
          in
          let state =
            Msg.get_int _msg
            |> Imports.River_libinput_device_v1.Three_finger_drag_state.of_int32
          in
          _self#on_set_three_finger_drag _proxy result ~state
        | 7 ->
          let result : ([ `River_libinput_result_v1 ], _, _) Proxy.t =
            Msg.get_int _msg
            |> Proxy.Handler.accept_new _proxy (module Imports.River_libinput_result_v1)
          in
          let matrix = Msg.get_array _msg in
          _self#on_set_calibration_matrix _proxy result ~matrix
        | 8 ->
          let result : ([ `River_libinput_result_v1 ], _, _) Proxy.t =
            Msg.get_int _msg
            |> Proxy.Handler.accept_new _proxy (module Imports.River_libinput_result_v1)
          in
          let profile =
            Msg.get_int _msg |> Imports.River_libinput_device_v1.Accel_profile.of_int32
          in
          _self#on_set_accel_profile _proxy result ~profile
        | 9 ->
          let result : ([ `River_libinput_result_v1 ], _, _) Proxy.t =
            Msg.get_int _msg
            |> Proxy.Handler.accept_new _proxy (module Imports.River_libinput_result_v1)
          in
          let speed = Msg.get_array _msg in
          _self#on_set_accel_speed _proxy result ~speed
        | 10 ->
          let result : ([ `River_libinput_result_v1 ], _, _) Proxy.t =
            Msg.get_int _msg
            |> Proxy.Handler.accept_new _proxy (module Imports.River_libinput_result_v1)
          in
          let config : ([ `River_libinput_accel_config_v1 ], _, _) Proxy.t =
            let (Proxy.Proxy p) = Msg.get_int _msg |> Proxy.lookup_other _proxy in
            match Proxy.ty p with
            | Imports.River_libinput_accel_config_v1.T -> p
            | _ ->
              Proxy.wrong_type ~parent:_proxy ~expected:"river_libinput_accel_config_v1" p
          in
          _self#on_apply_accel_config _proxy result ~config
        | 11 ->
          let result : ([ `River_libinput_result_v1 ], _, _) Proxy.t =
            Msg.get_int _msg
            |> Proxy.Handler.accept_new _proxy (module Imports.River_libinput_result_v1)
          in
          let state =
            Msg.get_int _msg
            |> Imports.River_libinput_device_v1.Natural_scroll_state.of_int32
          in
          _self#on_set_natural_scroll _proxy result ~state
        | 12 ->
          let result : ([ `River_libinput_result_v1 ], _, _) Proxy.t =
            Msg.get_int _msg
            |> Proxy.Handler.accept_new _proxy (module Imports.River_libinput_result_v1)
          in
          let state =
            Msg.get_int _msg
            |> Imports.River_libinput_device_v1.Left_handed_state.of_int32
          in
          _self#on_set_left_handed _proxy result ~state
        | 13 ->
          let result : ([ `River_libinput_result_v1 ], _, _) Proxy.t =
            Msg.get_int _msg
            |> Proxy.Handler.accept_new _proxy (module Imports.River_libinput_result_v1)
          in
          let method_ =
            Msg.get_int _msg |> Imports.River_libinput_device_v1.Click_method.of_int32
          in
          _self#on_set_click_method _proxy result ~method_
        | 14 ->
          let result : ([ `River_libinput_result_v1 ], _, _) Proxy.t =
            Msg.get_int _msg
            |> Proxy.Handler.accept_new _proxy (module Imports.River_libinput_result_v1)
          in
          let button_map =
            Msg.get_int _msg
            |> Imports.River_libinput_device_v1.Clickfinger_button_map.of_int32
          in
          _self#on_set_clickfinger_button_map _proxy result ~button_map
        | 15 ->
          let result : ([ `River_libinput_result_v1 ], _, _) Proxy.t =
            Msg.get_int _msg
            |> Proxy.Handler.accept_new _proxy (module Imports.River_libinput_result_v1)
          in
          let state =
            Msg.get_int _msg
            |> Imports.River_libinput_device_v1.Middle_emulation_state.of_int32
          in
          _self#on_set_middle_emulation _proxy result ~state
        | 16 ->
          let result : ([ `River_libinput_result_v1 ], _, _) Proxy.t =
            Msg.get_int _msg
            |> Proxy.Handler.accept_new _proxy (module Imports.River_libinput_result_v1)
          in
          let method_ =
            Msg.get_int _msg |> Imports.River_libinput_device_v1.Scroll_method.of_int32
          in
          _self#on_set_scroll_method _proxy result ~method_
        | 17 ->
          let result : ([ `River_libinput_result_v1 ], _, _) Proxy.t =
            Msg.get_int _msg
            |> Proxy.Handler.accept_new _proxy (module Imports.River_libinput_result_v1)
          in
          let button = Msg.get_int _msg in
          _self#on_set_scroll_button _proxy result ~button
        | 18 ->
          let result : ([ `River_libinput_result_v1 ], _, _) Proxy.t =
            Msg.get_int _msg
            |> Proxy.Handler.accept_new _proxy (module Imports.River_libinput_result_v1)
          in
          let state =
            Msg.get_int _msg
            |> Imports.River_libinput_device_v1.Scroll_button_lock_state.of_int32
          in
          _self#on_set_scroll_button_lock _proxy result ~state
        | 19 ->
          let result : ([ `River_libinput_result_v1 ], _, _) Proxy.t =
            Msg.get_int _msg
            |> Proxy.Handler.accept_new _proxy (module Imports.River_libinput_result_v1)
          in
          let state =
            Msg.get_int _msg |> Imports.River_libinput_device_v1.Dwt_state.of_int32
          in
          _self#on_set_dwt _proxy result ~state
        | 20 ->
          let result : ([ `River_libinput_result_v1 ], _, _) Proxy.t =
            Msg.get_int _msg
            |> Proxy.Handler.accept_new _proxy (module Imports.River_libinput_result_v1)
          in
          let state =
            Msg.get_int _msg |> Imports.River_libinput_device_v1.Dwtp_state.of_int32
          in
          _self#on_set_dwtp _proxy result ~state
        | 21 ->
          let result : ([ `River_libinput_result_v1 ], _, _) Proxy.t =
            Msg.get_int _msg
            |> Proxy.Handler.accept_new _proxy (module Imports.River_libinput_result_v1)
          in
          let angle = Msg.get_int _msg in
          _self#on_set_rotation _proxy result ~angle
        | _ -> assert false
    end

  (**/**)

  (** {2 Handlers}
      Note: Servers will always want to use [v1].
   *)

  (** Handler for a proxy with version >= 1. *)
  class virtual ['v] v1 =
    object (_ : (_, 'v, _) #Proxy.Service_handler.t)

      (**/**)

      inherit [[< `V1 | `V2 ] as 'v] _handlers_unsafe

      (**/**)

      method private virtual on_destroy : [> `V1 | `V2 ] t -> unit

      (** Destroy the libinput device object.

        This request indicates that the client will no longer use the input
        device object and that it may be safely destroyed. *)

      method
        private
        virtual on_set_send_events
        : [> `V1 | `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> mode:Imports.River_libinput_device_v1.Send_events_modes.t
          -> unit

      (** Set send events mode.

        Set the send events mode for the device. *)

      method
        private
        virtual on_set_tap
        : [> `V1 | `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> state:Imports.River_libinput_device_v1.Tap_state.t
          -> unit

      (** Enable/disable tap-to-click.

        Configure tap-to-click on this device, with a default mapping of
        1, 2, 3 finger tap mapping to left, right, middle click, respectively. *)

      method
        private
        virtual on_set_tap_button_map
        : [> `V1 | `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> button_map:Imports.River_libinput_device_v1.Tap_button_map.t
          -> unit

      (** Set tap-to-click button map.

        Set the finger number to button number mapping for tap-to-click. The
        default mapping on most devices is to have a 1, 2 and 3 finger tap to
        map to the left, right and middle button, respectively. *)

      method
        private
        virtual on_set_drag
        : [> `V1 | `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> state:Imports.River_libinput_device_v1.Drag_state.t
          -> unit

      (** Set tap-and-drag state.

        Configure tap-and-drag functionality on the device. *)

      method
        private
        virtual on_set_drag_lock
        : [> `V1 | `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> state:Imports.River_libinput_device_v1.Drag_lock_state.t
          -> unit

      (** Set drag lock state.

        Configure drag-lock during tapping on this device. When enabled, a
        finger may be lifted and put back on the touchpad and the drag process
        continues. A timeout for lifting the finger is optional. When disabled,
        lifting the finger during a tap-and-drag will immediately stop the drag.
        See the libinput documentation for more details. *)

      method
        private
        virtual on_set_three_finger_drag
        : [> `V1 | `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> state:Imports.River_libinput_device_v1.Three_finger_drag_state.t
          -> unit

      (** Set three finger drag state.

        Configure three finger drag functionality for the device. *)

      method
        private
        virtual on_set_calibration_matrix
        : [> `V1 | `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> matrix:string
          -> unit

      (** Set calibration matrix.

        Set calibration matrix. *)

      method
        private
        virtual on_set_accel_profile
        : [> `V1 | `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> profile:Imports.River_libinput_device_v1.Accel_profile.t
          -> unit

      (** Set acceleration profile.

        Set the acceleration profile. *)

      method
        private
        virtual on_set_accel_speed
        : [> `V1 | `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> speed:string
          -> unit

      (** Set acceleration speed.

        Set the acceleration speed within a range of [-1, 1], where 0 is
        the default acceleration for this device, -1 is the slowest acceleration
        and 1 is the maximum acceleration available on this device. *)

      method
        private
        virtual on_apply_accel_config
        : [> `V1 | `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> config:
               ( [ `River_libinput_accel_config_v1 ]
                 , [> Imports.River_libinput_accel_config_v1.versions ]
                 , [ `Server ] )
                 Proxy.t
          -> unit

      (** Apply acceleration config.

        Apply a pointer accleration config. *)

      method
        private
        virtual on_set_natural_scroll
        : [> `V1 | `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> state:Imports.River_libinput_device_v1.Natural_scroll_state.t
          -> unit

      (** Set natural scroll state.

        Set natural scroll state. *)

      method
        private
        virtual on_set_left_handed
        : [> `V1 | `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> state:Imports.River_libinput_device_v1.Left_handed_state.t
          -> unit

      (** Set left-handed mode state.

        Set left-handed mode state. *)

      method
        private
        virtual on_set_click_method
        : [> `V1 | `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> method_:Imports.River_libinput_device_v1.Click_method.t
          -> unit

      (** Set click method.

        Set click method. *)

      method
        private
        virtual on_set_clickfinger_button_map
        : [> `V1 | `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> button_map:Imports.River_libinput_device_v1.Clickfinger_button_map.t
          -> unit

      (** Set clickfinger button map.

        Set clickfinger button map.
        Supported if click_methods.clickfinger is supported. *)

      method
        private
        virtual on_set_middle_emulation
        : [> `V1 | `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> state:Imports.River_libinput_device_v1.Middle_emulation_state.t
          -> unit

      (** Set middle mouse button emulation state.

        Set middle mouse button emulation state. *)

      method
        private
        virtual on_set_scroll_method
        : [> `V1 | `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> method_:Imports.River_libinput_device_v1.Scroll_method.t
          -> unit

      (** Set scroll method.

        Set scroll method. *)

      method
        private
        virtual on_set_scroll_button
        : [> `V1 | `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> button:int32
          -> unit

      (** Set scroll button.

        Set scroll button.
        Supported if scroll_methods.on_button_down is supported. *)

      method
        private
        virtual on_set_scroll_button_lock
        : [> `V1 | `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> state:Imports.River_libinput_device_v1.Scroll_button_lock_state.t
          -> unit

      (** Set scroll button lock state.

        Set scroll button lock state.
        Supported if scroll_methods.on_button_down is supported. *)

      method
        private
        virtual on_set_dwt
        : [> `V1 | `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> state:Imports.River_libinput_device_v1.Dwt_state.t
          -> unit

      (** Set disable-while-typing state.

        Set disable-while-typing state. *)

      method
        private
        virtual on_set_dwtp
        : [> `V1 | `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> state:Imports.River_libinput_device_v1.Dwtp_state.t
          -> unit

      (** Set disable-while-trackpointing state.

        Set disable-while-trackpointing state. *)

      method
        private
        virtual on_set_rotation
        : [> `V1 | `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> angle:int32
          -> unit

      (** Set rotation angle.

        Set rotation angle in degrees clockwise off the logical neutral
        position. Angle must be in the range [0-360). *)

      method min_version = 1l
    end

  (** Handler for a proxy with version >= 2. *)
  class virtual ['v] v2 =
    object (_ : (_, 'v, _) #Proxy.Service_handler.t)

      (**/**)

      inherit [[< `V2 ] as 'v] _handlers_unsafe

      (**/**)

      method private virtual on_destroy : [> `V2 ] t -> unit

      (** Destroy the libinput device object.

        This request indicates that the client will no longer use the input
        device object and that it may be safely destroyed. *)

      method
        private
        virtual on_set_send_events
        : [> `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> mode:Imports.River_libinput_device_v1.Send_events_modes.t
          -> unit

      (** Set send events mode.

        Set the send events mode for the device. *)

      method
        private
        virtual on_set_tap
        : [> `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> state:Imports.River_libinput_device_v1.Tap_state.t
          -> unit

      (** Enable/disable tap-to-click.

        Configure tap-to-click on this device, with a default mapping of
        1, 2, 3 finger tap mapping to left, right, middle click, respectively. *)

      method
        private
        virtual on_set_tap_button_map
        : [> `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> button_map:Imports.River_libinput_device_v1.Tap_button_map.t
          -> unit

      (** Set tap-to-click button map.

        Set the finger number to button number mapping for tap-to-click. The
        default mapping on most devices is to have a 1, 2 and 3 finger tap to
        map to the left, right and middle button, respectively. *)

      method
        private
        virtual on_set_drag
        : [> `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> state:Imports.River_libinput_device_v1.Drag_state.t
          -> unit

      (** Set tap-and-drag state.

        Configure tap-and-drag functionality on the device. *)

      method
        private
        virtual on_set_drag_lock
        : [> `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> state:Imports.River_libinput_device_v1.Drag_lock_state.t
          -> unit

      (** Set drag lock state.

        Configure drag-lock during tapping on this device. When enabled, a
        finger may be lifted and put back on the touchpad and the drag process
        continues. A timeout for lifting the finger is optional. When disabled,
        lifting the finger during a tap-and-drag will immediately stop the drag.
        See the libinput documentation for more details. *)

      method
        private
        virtual on_set_three_finger_drag
        : [> `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> state:Imports.River_libinput_device_v1.Three_finger_drag_state.t
          -> unit

      (** Set three finger drag state.

        Configure three finger drag functionality for the device. *)

      method
        private
        virtual on_set_calibration_matrix
        : [> `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> matrix:string
          -> unit

      (** Set calibration matrix.

        Set calibration matrix. *)

      method
        private
        virtual on_set_accel_profile
        : [> `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> profile:Imports.River_libinput_device_v1.Accel_profile.t
          -> unit

      (** Set acceleration profile.

        Set the acceleration profile. *)

      method
        private
        virtual on_set_accel_speed
        : [> `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> speed:string
          -> unit

      (** Set acceleration speed.

        Set the acceleration speed within a range of [-1, 1], where 0 is
        the default acceleration for this device, -1 is the slowest acceleration
        and 1 is the maximum acceleration available on this device. *)

      method
        private
        virtual on_apply_accel_config
        : [> `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> config:
               ( [ `River_libinput_accel_config_v1 ]
                 , [> Imports.River_libinput_accel_config_v1.versions ]
                 , [ `Server ] )
                 Proxy.t
          -> unit

      (** Apply acceleration config.

        Apply a pointer accleration config. *)

      method
        private
        virtual on_set_natural_scroll
        : [> `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> state:Imports.River_libinput_device_v1.Natural_scroll_state.t
          -> unit

      (** Set natural scroll state.

        Set natural scroll state. *)

      method
        private
        virtual on_set_left_handed
        : [> `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> state:Imports.River_libinput_device_v1.Left_handed_state.t
          -> unit

      (** Set left-handed mode state.

        Set left-handed mode state. *)

      method
        private
        virtual on_set_click_method
        : [> `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> method_:Imports.River_libinput_device_v1.Click_method.t
          -> unit

      (** Set click method.

        Set click method. *)

      method
        private
        virtual on_set_clickfinger_button_map
        : [> `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> button_map:Imports.River_libinput_device_v1.Clickfinger_button_map.t
          -> unit

      (** Set clickfinger button map.

        Set clickfinger button map.
        Supported if click_methods.clickfinger is supported. *)

      method
        private
        virtual on_set_middle_emulation
        : [> `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> state:Imports.River_libinput_device_v1.Middle_emulation_state.t
          -> unit

      (** Set middle mouse button emulation state.

        Set middle mouse button emulation state. *)

      method
        private
        virtual on_set_scroll_method
        : [> `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> method_:Imports.River_libinput_device_v1.Scroll_method.t
          -> unit

      (** Set scroll method.

        Set scroll method. *)

      method
        private
        virtual on_set_scroll_button
        : [> `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> button:int32
          -> unit

      (** Set scroll button.

        Set scroll button.
        Supported if scroll_methods.on_button_down is supported. *)

      method
        private
        virtual on_set_scroll_button_lock
        : [> `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> state:Imports.River_libinput_device_v1.Scroll_button_lock_state.t
          -> unit

      (** Set scroll button lock state.

        Set scroll button lock state.
        Supported if scroll_methods.on_button_down is supported. *)

      method
        private
        virtual on_set_dwt
        : [> `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> state:Imports.River_libinput_device_v1.Dwt_state.t
          -> unit

      (** Set disable-while-typing state.

        Set disable-while-typing state. *)

      method
        private
        virtual on_set_dwtp
        : [> `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> state:Imports.River_libinput_device_v1.Dwtp_state.t
          -> unit

      (** Set disable-while-trackpointing state.

        Set disable-while-trackpointing state. *)

      method
        private
        virtual on_set_rotation
        : [> `V2 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> angle:int32
          -> unit

      (** Set rotation angle.

        Set rotation angle in degrees clockwise off the logical neutral
        position. Angle must be in the range [0-360). *)

      method min_version = 2l
    end
end

(** Acceleration config.

    The result returned by libinput on setting configuration for a device. *)
module River_libinput_accel_config_v1 = struct
  type 'v t = ([ `River_libinput_accel_config_v1 ], 'v, [ `Server ]) Proxy.t

  module Error = River_libinput_config_v1_proto.River_libinput_accel_config_v1.Error

  module Accel_type =
    River_libinput_config_v1_proto.River_libinput_accel_config_v1.Accel_type

  (** {2 Version 1} *)

  (**/**)

  class virtual ['v] _handlers_unsafe =
    object (_self : (_, 'v, _) #Proxy.Handler.t)
      method user_data = S.No_data

      method metadata =
        (module River_libinput_config_v1_proto.River_libinput_accel_config_v1)

      method max_version = 1l
      method private virtual on_destroy : [> ] t -> unit

      method
        private
        virtual on_set_points
        : [> ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> type_:Imports.River_libinput_accel_config_v1.Accel_type.t
          -> step:string
          -> points:string
          -> unit

      method dispatch (_proxy : 'v t) _msg =
        let _proxy = Proxy.cast_version _proxy in
        match Msg.op _msg with
        | 0 ->
          Proxy.shutdown_recv _proxy;
          _self#on_destroy _proxy
        | 1 ->
          let result : ([ `River_libinput_result_v1 ], _, _) Proxy.t =
            Msg.get_int _msg
            |> Proxy.Handler.accept_new _proxy (module Imports.River_libinput_result_v1)
          in
          let type_ =
            Msg.get_int _msg |> Imports.River_libinput_accel_config_v1.Accel_type.of_int32
          in
          let step = Msg.get_array _msg in
          let points = Msg.get_array _msg in
          _self#on_set_points _proxy result ~type_ ~step ~points
        | _ -> assert false
    end

  (**/**)

  (** {2 Handlers}
      Note: Servers will always want to use [v1].
   *)

  (** Handler for a proxy with version >= 1. *)
  class virtual ['v] v1 =
    object (_ : (_, 'v, _) #Proxy.Service_handler.t)

      (**/**)

      inherit [[< `V1 ] as 'v] _handlers_unsafe

      (**/**)

      method private virtual on_destroy : [> `V1 ] t -> unit

      (** Destroy the accel object.

        This request indicates that the client will no longer use the accel
        config object and that it may be safely destroyed. *)

      method
        private
        virtual on_set_points
        : [> `V1 ] t
          -> ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t
          -> type_:Imports.River_libinput_accel_config_v1.Accel_type.t
          -> step:string
          -> points:string
          -> unit

      (** Define custom acceleration function.

        Defines the acceleration function for a given movement type
        in an acceleration configuration with custom accel profile. *)

      method min_version = 1l
    end
end

(** Config application result.

    The result returned by libinput on setting configuration for a device. *)
module River_libinput_result_v1 = struct
  type 'v t = ([ `River_libinput_result_v1 ], 'v, [ `Server ]) Proxy.t

  (** {2 Version 1} *)

  (** Config invalid.

      The configuration is invalid and was ignored. *)
  let invalid (_t : ([< `V1 ] as 'v) t) =
    let _msg = Proxy.alloc _t ~op:2 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg;
    Proxy.shutdown_send _t
  ;;

  (** Config unsupported.

      The configuration is unsupported by the device and was ignored. *)
  let unsupported (_t : ([< `V1 ] as 'v) t) =
    let _msg = Proxy.alloc _t ~op:1 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg;
    Proxy.shutdown_send _t
  ;;

  (** Config success.

      The configuration was successfully applied to the device. *)
  let success (_t : ([< `V1 ] as 'v) t) =
    let _msg = Proxy.alloc _t ~op:0 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg;
    Proxy.shutdown_send _t
  ;;

  (**/**)

  class ['v] _handlers_unsafe =
    object (_self : (_, 'v, _) #Proxy.Handler.t)
      method user_data = S.No_data
      method metadata = (module River_libinput_config_v1_proto.River_libinput_result_v1)
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
  class ['v] v1 =
    object (_ : (_, 'v, _) #Proxy.Service_handler.t)

      (**/**)

      inherit [[< `V1 ] as 'v] _handlers_unsafe

      (**/**)

      method min_version = 1l
    end
end
