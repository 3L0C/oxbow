(* This file was generated automatically by wayland-scanner-ocaml *)

[@@@ocaml.warning "-27-34"]

open struct
  module Imports = struct
    include River_xkb_config_v1_proto
    include River_input_management_v1_proto
  end

  module Proxy = Wayland.Proxy
  module Msg = Wayland.Msg
  module Fixed = Wayland.Fixed
  module Iface_reg = Wayland.Iface_reg
  module S = Wayland.S
end

(** Xkb config global interface.

    Global interface for configuring xkb devices.

    This global should only be advertised if river_input_manager_v1 is
    advertised as well. *)
module River_xkb_config_v1 = struct
  type 'v t = ([ `River_xkb_config_v1 ], 'v, [ `Server ]) Proxy.t

  module Error = River_xkb_config_v1_proto.River_xkb_config_v1.Error
  module Keymap_format = River_xkb_config_v1_proto.River_xkb_config_v1.Keymap_format

  (** {2 Version 1, 2} *)

  (** New xkb keyboard.

      A new xkbcommon keyboard has been created. Not every
      river_input_device_v1 is necessarily an xkbcommon keyboard as well. *)
  let xkb_keyboard
        (_t : ([< `V1 | `V2 ] as 'v) t)
        (id : ([ `River_xkb_keyboard_v1 ], 'v, [ `Server ]) #Proxy.Handler.t)
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
      river_xkb_config_v1.destroy for more information. *)
  let finished (_t : ([< `V1 | `V2 ] as 'v) t) =
    let _msg = Proxy.alloc _t ~op:0 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  ;;

  (**/**)

  class virtual ['v] _handlers_unsafe =
    object (_self : (_, 'v, _) #Proxy.Handler.t)
      method user_data = S.No_data
      method metadata = (module River_xkb_config_v1_proto.River_xkb_config_v1)
      method max_version = 2l
      method private virtual on_stop : [> ] t -> unit
      method private virtual on_destroy : [> ] t -> unit

      method
        private
        virtual on_create_keymap
        : [> ] t
          -> ([ `River_xkb_keymap_v1 ], 'v, [ `Server ]) Proxy.t
          -> fd:Unix.file_descr
          -> format:Imports.River_xkb_config_v1.Keymap_format.t
          -> unit

      method dispatch (_proxy : 'v t) _msg =
        let _proxy = Proxy.cast_version _proxy in
        match Msg.op _msg with
        | 0 -> _self#on_stop _proxy
        | 1 ->
          Proxy.shutdown_recv _proxy;
          _self#on_destroy _proxy
        | 2 ->
          let id : ([ `River_xkb_keymap_v1 ], _, _) Proxy.t =
            Msg.get_int _msg
            |> Proxy.Handler.accept_new _proxy (module Imports.River_xkb_keymap_v1)
          in
          let fd = Msg.get_fd _msg in
          let format =
            Msg.get_int _msg |> Imports.River_xkb_config_v1.Keymap_format.of_int32
          in
          _self#on_create_keymap _proxy id ~fd ~format
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
        for a river_xkb_config_v1.finished event before destroying this object. *)

      method private virtual on_destroy : [> `V1 | `V2 ] t -> unit

      (** Destroy the river_xkb_config_v1 object.

        This request should be called after the finished event has been received
        to complete destruction of the object.

        It is a protocol error to make this request before the finished event
        has been received.

        If a client wishes to destroy this object it should send a
        river_xkb_config_v1.stop request and wait for a
        river_xkb_config_v1.finished event. Once the finished event is received
        it is safe to destroy this object and any other objects created through
        this interface. *)

      method
        private
        virtual on_create_keymap
        : [> `V1 | `V2 ] t
          -> ([ `River_xkb_keymap_v1 ], 'v, [ `Server ]) Proxy.t
          -> fd:Unix.file_descr
          -> format:Imports.River_xkb_config_v1.Keymap_format.t
          -> unit

      (** Create a keymap object.

        The server must be able to mmap the fd with MAP_PRIVATE.
        The server will fstat the fd to obtain the size of the keymap.
        The client must not modify the contents of the fd after making this request.
        The client should seal the fd with fcntl. *)

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
        for a river_xkb_config_v1.finished event before destroying this object. *)

      method private virtual on_destroy : [> `V2 ] t -> unit

      (** Destroy the river_xkb_config_v1 object.

        This request should be called after the finished event has been received
        to complete destruction of the object.

        It is a protocol error to make this request before the finished event
        has been received.

        If a client wishes to destroy this object it should send a
        river_xkb_config_v1.stop request and wait for a
        river_xkb_config_v1.finished event. Once the finished event is received
        it is safe to destroy this object and any other objects created through
        this interface. *)

      method
        private
        virtual on_create_keymap
        : [> `V2 ] t
          -> ([ `River_xkb_keymap_v1 ], 'v, [ `Server ]) Proxy.t
          -> fd:Unix.file_descr
          -> format:Imports.River_xkb_config_v1.Keymap_format.t
          -> unit

      (** Create a keymap object.

        The server must be able to mmap the fd with MAP_PRIVATE.
        The server will fstat the fd to obtain the size of the keymap.
        The client must not modify the contents of the fd after making this request.
        The client should seal the fd with fcntl. *)

      method min_version = 2l
      method bind_version : [ `V2 ] = `V2
    end
end

(** Xkbcommon keymap.

    This object is the result of attempting to create an xkbcommon keymap. *)
module River_xkb_keymap_v1 = struct
  type 'v t = ([ `River_xkb_keymap_v1 ], 'v, [ `Server ]) Proxy.t

  (** {2 Version 1, 2} *)

  (** Keymap creation failed.

      The compositor failed to create a keymap from the given parameters.

      It is a protocol error to use this keymap object with
      river_xkb_keyboard_v1.set_keymap. *)
  let failure (_t : ([< `V1 | `V2 ] as 'v) t) ~error_msg =
    let _msg = Proxy.alloc _t ~op:1 ~ints:1 ~strings:[ Some error_msg ] ~arrays:[] in
    Msg.add_string _msg error_msg;
    Proxy.send _t _msg
  ;;

  (** Keymap creation succeeded.

      The keymap object was successfully created and may be used with the
      river_xkb_keyboard_v1.set_keymap request. *)
  let success (_t : ([< `V1 | `V2 ] as 'v) t) =
    let _msg = Proxy.alloc _t ~op:0 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  ;;

  (**/**)

  class virtual ['v] _handlers_unsafe =
    object (_self : (_, 'v, _) #Proxy.Handler.t)
      method user_data = S.No_data
      method metadata = (module River_xkb_config_v1_proto.River_xkb_keymap_v1)
      method max_version = 2l
      method private virtual on_destroy : [> ] t -> unit

      method dispatch (_proxy : 'v t) _msg =
        let _proxy = Proxy.cast_version _proxy in
        match Msg.op _msg with
        | 0 ->
          Proxy.shutdown_recv _proxy;
          _self#on_destroy _proxy
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

      (** Destroy the keymap object.

        This request indicates that the client will no longer use the keymap
        object and that it may be safely destroyed. *)

      method min_version = 1l
    end

  (** Handler for a proxy with version >= 2. *)
  class virtual ['v] v2 =
    object (_ : (_, 'v, _) #Proxy.Service_handler.t)

      (**/**)

      inherit [[< `V2 ] as 'v] _handlers_unsafe

      (**/**)

      method private virtual on_destroy : [> `V2 ] t -> unit

      (** Destroy the keymap object.

        This request indicates that the client will no longer use the keymap
        object and that it may be safely destroyed. *)

      method min_version = 2l
    end
end

(** Xkbcommon keyboard device.

    This object represent a physical keyboard which has its configuration and
    state managed by xkbcommon. *)
module River_xkb_keyboard_v1 = struct
  type 'v t = ([ `River_xkb_keyboard_v1 ], 'v, [ `Server ]) Proxy.t

  module Error = River_xkb_config_v1_proto.River_xkb_keyboard_v1.Error

  (** {2 Version 1} *)

  (** Numlock is currently disabled.

      Numlock is currently disabled for the keyboard.

      This event is sent once when the river_xkb_keyboard_v1 is created and
      again whenever the numlock state changes. *)
  let numlock_disabled (_t : ([< `V1 | `V2 ] as 'v) t) =
    let _msg = Proxy.alloc _t ~op:6 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  ;;

  (** Numlock is currently enabled.

      Numlock is currently enabled for the keyboard.

      This event is sent once when the river_xkb_keyboard_v1 is created and
      again whenever the numlock state changes. *)
  let numlock_enabled (_t : ([< `V1 | `V2 ] as 'v) t) =
    let _msg = Proxy.alloc _t ~op:5 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  ;;

  (** Capslock is currently disabled.

      Capslock is currently disabled for the keyboard.

      This event is sent once when the river_xkb_keyboard_v1 is created and
      again whenever the capslock state changes. *)
  let capslock_disabled (_t : ([< `V1 | `V2 ] as 'v) t) =
    let _msg = Proxy.alloc _t ~op:4 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  ;;

  (** Capslock is currently enabled.

      Capslock is currently enabled for the keyboard.

      This event is sent once when the river_xkb_keyboard_v1 is created and
      again whenever the capslock state changes. *)
  let capslock_enabled (_t : ([< `V1 | `V2 ] as 'v) t) =
    let _msg = Proxy.alloc _t ~op:3 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  ;;

  (** Currently active layout.

      The currently active layout index and name. The name arg may be null if
      the active layout does not have a name.

      This event is sent once when the river_xkb_keyboard_v1 is created and
      again whenever the layout changes. *)
  let layout (_t : ([< `V1 | `V2 ] as 'v) t) ~index ~name =
    let _msg = Proxy.alloc _t ~op:2 ~ints:2 ~strings:[ name ] ~arrays:[] in
    Msg.add_int _msg index;
    Msg.add_string_opt _msg name;
    Proxy.send _t _msg
  ;;

  (** Corresponding river input device.

      The river_input_device_v1 corresponding to this xkb keyboard. This event
      will always be the first event sent on the river_xkb_keyboard_v1 object,
      and it will be sent exactly once. *)
  let input_device
        (_t : ([< `V1 | `V2 ] as 'v) t)
        ~(device : ([ `River_input_device_v1 ], _, [ `Server ]) Proxy.t)
    =
    let _msg = Proxy.alloc _t ~op:1 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id device);
    Proxy.send _t _msg
  ;;

  (** The xkb keyboard is removed.

      This event indicates that the xkb keyboard has been removed.

      The server will send no further events on this object and ignore any
      request (other than river_xkb_keyboard_v1.destroy) made after this event
      is sent. The client should destroy this object with the
      river_xkb_keyboard_v1.destroy request to free up resources. *)
  let removed (_t : ([< `V1 | `V2 ] as 'v) t) =
    let _msg = Proxy.alloc _t ~op:0 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  ;;

  (** {2 Version 2} *)

  (** All information has been sent.

      This event is sent after all information about the keyboard has been
      sent.

      This allows changes to one or more river_xkb_keyboard_v1 properties to
      be seen as atomic, even if they happen via multiple events. *)
  let done_ (_t : ([< `V2 ] as 'v) t) =
    let _msg = Proxy.alloc _t ~op:7 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  ;;

  (**/**)

  class virtual ['v] _handlers_unsafe =
    object (_self : (_, 'v, _) #Proxy.Handler.t)
      method user_data = S.No_data
      method metadata = (module River_xkb_config_v1_proto.River_xkb_keyboard_v1)
      method max_version = 2l
      method private virtual on_destroy : [> ] t -> unit

      method
        private
        virtual on_set_keymap
        : [> ] t
          -> keymap:
               ( [ `River_xkb_keymap_v1 ]
                 , [> Imports.River_xkb_keymap_v1.versions ]
                 , [ `Server ] )
                 Proxy.t
          -> unit

      method private virtual on_set_layout_by_index : [> ] t -> index:int32 -> unit
      method private virtual on_set_layout_by_name : [> ] t -> name:string -> unit
      method private virtual on_capslock_enable : [> ] t -> unit
      method private virtual on_capslock_disable : [> ] t -> unit
      method private virtual on_numlock_enable : [> ] t -> unit
      method private virtual on_numlock_disable : [> ] t -> unit

      method dispatch (_proxy : 'v t) _msg =
        let _proxy = Proxy.cast_version _proxy in
        match Msg.op _msg with
        | 0 ->
          Proxy.shutdown_recv _proxy;
          _self#on_destroy _proxy
        | 1 ->
          let keymap : ([ `River_xkb_keymap_v1 ], _, _) Proxy.t =
            let (Proxy.Proxy p) = Msg.get_int _msg |> Proxy.lookup_other _proxy in
            match Proxy.ty p with
            | Imports.River_xkb_keymap_v1.T -> p
            | _ -> Proxy.wrong_type ~parent:_proxy ~expected:"river_xkb_keymap_v1" p
          in
          _self#on_set_keymap _proxy ~keymap
        | 2 ->
          let index = Msg.get_int _msg in
          _self#on_set_layout_by_index _proxy ~index
        | 3 ->
          let name = Msg.get_string _msg in
          _self#on_set_layout_by_name _proxy ~name
        | 4 -> _self#on_capslock_enable _proxy
        | 5 -> _self#on_capslock_disable _proxy
        | 6 -> _self#on_numlock_enable _proxy
        | 7 -> _self#on_numlock_disable _proxy
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

      (** Destroy the xkb keyboard object.

        This request indicates that the client will no longer use the keyboard
        object and that it may be safely destroyed. *)

      method
        private
        virtual on_set_keymap
        : [> `V1 | `V2 ] t
          -> keymap:
               ( [ `River_xkb_keymap_v1 ]
                 , [> Imports.River_xkb_keymap_v1.versions ]
                 , [ `Server ] )
                 Proxy.t
          -> unit

      (** Set the keymap.

        Set the keymap for the keyboard.

        Setting a keymap will reset all layout/modifier state.

        It is a protocol error to pass a keymap object for which the
        river_xkb_keymap_v1.success event was not received. *)

      method
        private
        virtual on_set_layout_by_index
        : [> `V1 | `V2 ] t -> index:int32 -> unit

      (** Set the active layout by index.

        Set the active layout for the keyboard's keymap. Has no effect if the
        layout index is out of bounds for the current keymap. *)

      method
        private
        virtual on_set_layout_by_name
        : [> `V1 | `V2 ] t -> name:string -> unit

      (** Set the active layout by name.

        Set the active layout for the keyboard's keymap. Has no effect if there
        is no layout with the give name for the keyboard's keymap. *)

      method private virtual on_capslock_enable : [> `V1 | `V2 ] t -> unit

      (** Enable capslock.

        Enable capslock for the keyboard. *)

      method private virtual on_capslock_disable : [> `V1 | `V2 ] t -> unit

      (** Disable capslock.

        Disable capslock for the keyboard. *)

      method private virtual on_numlock_enable : [> `V1 | `V2 ] t -> unit

      (** Enable numlock.

        Enable numlock for the keyboard. *)

      method private virtual on_numlock_disable : [> `V1 | `V2 ] t -> unit

      (** Disable numlock.

        Disable numlock for the keyboard. *)

      method min_version = 1l
    end

  (** Handler for a proxy with version >= 2. *)
  class virtual ['v] v2 =
    object (_ : (_, 'v, _) #Proxy.Service_handler.t)

      (**/**)

      inherit [[< `V2 ] as 'v] _handlers_unsafe

      (**/**)

      method private virtual on_destroy : [> `V2 ] t -> unit

      (** Destroy the xkb keyboard object.

        This request indicates that the client will no longer use the keyboard
        object and that it may be safely destroyed. *)

      method
        private
        virtual on_set_keymap
        : [> `V2 ] t
          -> keymap:
               ( [ `River_xkb_keymap_v1 ]
                 , [> Imports.River_xkb_keymap_v1.versions ]
                 , [ `Server ] )
                 Proxy.t
          -> unit

      (** Set the keymap.

        Set the keymap for the keyboard.

        Setting a keymap will reset all layout/modifier state.

        It is a protocol error to pass a keymap object for which the
        river_xkb_keymap_v1.success event was not received. *)

      method private virtual on_set_layout_by_index : [> `V2 ] t -> index:int32 -> unit

      (** Set the active layout by index.

        Set the active layout for the keyboard's keymap. Has no effect if the
        layout index is out of bounds for the current keymap. *)

      method private virtual on_set_layout_by_name : [> `V2 ] t -> name:string -> unit

      (** Set the active layout by name.

        Set the active layout for the keyboard's keymap. Has no effect if there
        is no layout with the give name for the keyboard's keymap. *)

      method private virtual on_capslock_enable : [> `V2 ] t -> unit

      (** Enable capslock.

        Enable capslock for the keyboard. *)

      method private virtual on_capslock_disable : [> `V2 ] t -> unit

      (** Disable capslock.

        Disable capslock for the keyboard. *)

      method private virtual on_numlock_enable : [> `V2 ] t -> unit

      (** Enable numlock.

        Enable numlock for the keyboard. *)

      method private virtual on_numlock_disable : [> `V2 ] t -> unit

      (** Disable numlock.

        Disable numlock for the keyboard. *)

      method min_version = 2l
    end
end
