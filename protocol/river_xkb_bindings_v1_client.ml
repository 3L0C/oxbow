(* This file was generated automatically by wayland-scanner-ocaml *)

[@@@ocaml.warning "-27-34"]

open struct
  module Imports = struct
    include River_xkb_bindings_v1_proto
    include River_window_management_v1_proto
  end

  module Proxy = Wayland.Proxy
  module Msg = Wayland.Msg
  module Fixed = Wayland.Fixed
  module Iface_reg = Wayland.Iface_reg
  module S = Wayland.S
end

(** Xkbcommon bindings global interface.

    This global interface should only be advertised to the client if the
    river_window_manager_v1 global is also advertised. *)
module River_xkb_bindings_v1 = struct
  type 'v t = ([ `River_xkb_bindings_v1 ], 'v, [ `Client ]) Proxy.t

  module Error = River_xkb_bindings_v1_proto.River_xkb_bindings_v1.Error

  (** {2 Version 1} *)

  (** Define a new xkbcommon key binding.

      Define a key binding for the given seat in terms of an xkbcommon keysym
      and other configurable properties.

      The new key binding is not enabled until initial configuration is
      completed and the enable request is made during a manage sequence. *)
  let get_xkb_binding
        (_t : ([< `V1 | `V2 | `V3 ] as 'v) t)
        ~(seat : ([ `River_seat_v1 ], _, [ `Client ]) Proxy.t)
        (id : ([ `River_xkb_binding_v1 ], 'v, [ `Client ]) #Proxy.Handler.t)
        ~keysym
        ~modifiers
    =
    let __id = Proxy.spawn _t id in
    let _msg = Proxy.alloc _t ~op:1 ~ints:4 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id seat);
    Msg.add_int _msg (Proxy.id __id);
    Msg.add_int _msg keysym;
    Msg.add_int _msg (Imports.River_seat_v1.Modifiers.to_int32 modifiers);
    Proxy.send _t _msg;
    __id
  ;;

  (** Destroy the river_xkb_bindings_v1 object.

      This request indicates that the client will no longer use the
      river_xkb_bindings_v1 object. *)
  let destroy (_t : ([< `V1 | `V2 | `V3 ] as 'v) t) =
    let _msg = Proxy.alloc _t ~op:0 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg;
    Proxy.shutdown_send _t
  ;;

  (** {2 Version 2, 3} *)

  (** Manage seat-specific state.

      Create an object to manage seat-specific xkb bindings state.

      It is a protocol error to make this request more than once for a given
      river_seat_v1 object. *)
  let get_seat
        (_t : ([< `V2 | `V3 ] as 'v) t)
        (id : ([ `River_xkb_bindings_seat_v1 ], 'v, [ `Client ]) #Proxy.Handler.t)
        ~(seat : ([ `River_seat_v1 ], _, [ `Client ]) Proxy.t)
    =
    let __id = Proxy.spawn _t id in
    let _msg = Proxy.alloc _t ~op:2 ~ints:2 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id __id);
    Msg.add_int _msg (Proxy.id seat);
    Proxy.send _t _msg;
    __id
  ;;

  (**/**)

  class ['v] _handlers_unsafe =
    object (_self : (_, 'v, _) #Proxy.Handler.t)
      method user_data = S.No_data
      method metadata = (module River_xkb_bindings_v1_proto.River_xkb_bindings_v1)
      method max_version = 3l

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

      inherit [[< `V1 | `V2 | `V3 ] as 'v] _handlers_unsafe

      (**/**)

      method min_version = 1l
      method bind_version : [ `V1 ] = `V1
    end

  (** Handler for a proxy with version >= 2. *)
  class ['v] v2 =
    object (_ : (_, 'v, _) #Proxy.Service_handler.t)

      (**/**)

      inherit [[< `V2 | `V3 ] as 'v] _handlers_unsafe

      (**/**)

      method min_version = 2l
      method bind_version : [ `V2 ] = `V2
    end

  (** Handler for a proxy with version >= 3. *)
  class ['v] v3 =
    object (_ : (_, 'v, _) #Proxy.Service_handler.t)

      (**/**)

      inherit [[< `V3 ] as 'v] _handlers_unsafe

      (**/**)

      method min_version = 3l
      method bind_version : [ `V3 ] = `V3
    end
end

(** Configure a xkb key binding, receive trigger events.

    This object allows the window manager to configure a xkbcommon key binding
    and receive events when the key binding is triggered.

    The new key binding is not enabled until the enable request is made during
    a manage sequence.

    Normally, all key events are sent to the surface with keyboard focus by
    the compositor. Key events that trigger a key binding are not sent to the
    surface with keyboard focus.

    If multiple key bindings would be triggered by a single physical key event
    on the compositor side, it is compositor policy which key binding(s) will
    receive press/release events or if all of the matched key bindings receive
    press/release events.

    Key bindings might be matched by the same physical key event due to shared
    keysym and modifiers. The layout override feature may also cause the same
    physical key event to trigger two key bindings with different keysyms and
    different layout overrides configured. *)
module River_xkb_binding_v1 = struct
  type 'v t = ([ `River_xkb_binding_v1 ], 'v, [ `Client ]) Proxy.t

  (** {2 Version 1} *)

  (** Disable the key binding.

      This request may be used to temporarily disable the key binding. It may
      be later re-enabled with the enable request.

      This request modifies window management state and may only be made as
      part of a manage sequence, see the river_window_manager_v1 description. *)
  let disable (_t : ([< `V1 | `V2 | `V3 ] as 'v) t) =
    let _msg = Proxy.alloc _t ~op:3 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  ;;

  (** Enable the key binding.

      This request should be made after all initial configuration has been
      completed and the window manager wishes the key binding to be able to be
      triggered.

      This request modifies window management state and may only be made as
      part of a manage sequence, see the river_window_manager_v1 description. *)
  let enable (_t : ([< `V1 | `V2 | `V3 ] as 'v) t) =
    let _msg = Proxy.alloc _t ~op:2 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  ;;

  (** Override currently active xkb layout.

      Specify an xkb layout that should be used to translate key events for
      the purpose of triggering this key binding irrespective of the currently
      active xkb layout.

      The layout argument is a 0-indexed xkbcommon layout number for the
      keyboard that generated the key event.

      If this request is never made, the currently active xkb layout of the
      keyboard that generated the key event will be used.

      This request modifies window management state and may only be made as
      part of a manage sequence, see the river_window_manager_v1 description. *)
  let set_layout_override (_t : ([< `V1 | `V2 | `V3 ] as 'v) t) ~layout =
    let _msg = Proxy.alloc _t ~op:1 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg layout;
    Proxy.send _t _msg
  ;;

  (** Destroy the xkb binding object.

      This request indicates that the client will no longer use the xkb key
      binding object and that it may be safely destroyed. *)
  let destroy (_t : ([< `V1 | `V2 | `V3 ] as 'v) t) =
    let _msg = Proxy.alloc _t ~op:0 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg;
    Proxy.shutdown_send _t
  ;;

  (** {2 Version 2, 3} *)

  (**/**)

  class virtual ['v] _handlers_unsafe =
    object (_self : (_, 'v, _) #Proxy.Handler.t)
      method user_data = S.No_data
      method metadata = (module River_xkb_bindings_v1_proto.River_xkb_binding_v1)
      method max_version = 3l
      method private virtual on_pressed : [> ] t -> unit
      method private virtual on_released : [> ] t -> unit
      method private virtual on_stop_repeat : [> ] t -> unit

      method dispatch (_proxy : 'v t) _msg =
        let _proxy = Proxy.cast_version _proxy in
        match Msg.op _msg with
        | 0 -> _self#on_pressed _proxy
        | 1 -> _self#on_released _proxy
        | 2 -> _self#on_stop_repeat _proxy
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

      inherit [[< `V1 | `V2 | `V3 ] as 'v] _handlers_unsafe

      (**/**)

      method private virtual on_pressed : [> `V1 | `V2 | `V3 ] t -> unit

      (** The key triggering the binding has been pressed.

        This event indicates that the physical key triggering the binding has
        been pressed.

        This event will be followed by a manage_start event after all other new
        state has been sent by the server.

        The compositor should wait for the manage sequence to complete before
        processing further input events. This allows the window manager client
        to, for example, modify key bindings and keyboard focus without racing
        against future input events. The window manager should of course respond
        as soon as possible as the capacity of the compositor to buffer incoming
        input events is finite. *)

      method private virtual on_released : [> `V1 | `V2 | `V3 ] t -> unit

      (** The key triggering the binding has been released.

        This event indicates that the physical key triggering the binding has
        been released.

        Releasing the modifiers for the binding without releasing the "main"
        physical key that produces the bound keysym does not trigger the release
        event. This event is sent when the "main" key is released, even if the
        modifiers have changed since the pressed event.

        This event will be followed by a manage_start event after all other new
        state has been sent by the server.

        The compositor should wait for the manage sequence to complete before
        processing further input events. This allows the window manager client
        to, for example, modify key bindings and keyboard focus without racing
        against future input events. The window manager should of course respond
        as soon as possible as the capacity of the compositor to buffer incoming
        input events is finite. *)

      method private virtual on_stop_repeat : [> `V2 | `V3 ] t -> unit

      (** Repeating should be stopped.

        This event indicates that repeating should be stopped for the binding if
        the window manager has been repeating some action since the pressed
        event.

        This event is generally sent when some other (possibly unbound) key is
        pressed after the pressed event is sent and before the released event
        is sent for this binding.

        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)

      method min_version = 1l
    end

  (** Handler for a proxy with version >= 2. *)
  class virtual ['v] v2 =
    object (_ : (_, 'v, _) #Proxy.Service_handler.t)

      (**/**)

      inherit [[< `V2 | `V3 ] as 'v] _handlers_unsafe

      (**/**)

      method private virtual on_pressed : [> `V2 | `V3 ] t -> unit

      (** The key triggering the binding has been pressed.

        This event indicates that the physical key triggering the binding has
        been pressed.

        This event will be followed by a manage_start event after all other new
        state has been sent by the server.

        The compositor should wait for the manage sequence to complete before
        processing further input events. This allows the window manager client
        to, for example, modify key bindings and keyboard focus without racing
        against future input events. The window manager should of course respond
        as soon as possible as the capacity of the compositor to buffer incoming
        input events is finite. *)

      method private virtual on_released : [> `V2 | `V3 ] t -> unit

      (** The key triggering the binding has been released.

        This event indicates that the physical key triggering the binding has
        been released.

        Releasing the modifiers for the binding without releasing the "main"
        physical key that produces the bound keysym does not trigger the release
        event. This event is sent when the "main" key is released, even if the
        modifiers have changed since the pressed event.

        This event will be followed by a manage_start event after all other new
        state has been sent by the server.

        The compositor should wait for the manage sequence to complete before
        processing further input events. This allows the window manager client
        to, for example, modify key bindings and keyboard focus without racing
        against future input events. The window manager should of course respond
        as soon as possible as the capacity of the compositor to buffer incoming
        input events is finite. *)

      method private virtual on_stop_repeat : [> `V2 | `V3 ] t -> unit

      (** Repeating should be stopped.

        This event indicates that repeating should be stopped for the binding if
        the window manager has been repeating some action since the pressed
        event.

        This event is generally sent when some other (possibly unbound) key is
        pressed after the pressed event is sent and before the released event
        is sent for this binding.

        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)

      method min_version = 2l
    end

  (** Handler for a proxy with version >= 3. *)
  class virtual ['v] v3 =
    object (_ : (_, 'v, _) #Proxy.Service_handler.t)

      (**/**)

      inherit [[< `V3 ] as 'v] _handlers_unsafe

      (**/**)

      method private virtual on_pressed : [> `V3 ] t -> unit

      (** The key triggering the binding has been pressed.

        This event indicates that the physical key triggering the binding has
        been pressed.

        This event will be followed by a manage_start event after all other new
        state has been sent by the server.

        The compositor should wait for the manage sequence to complete before
        processing further input events. This allows the window manager client
        to, for example, modify key bindings and keyboard focus without racing
        against future input events. The window manager should of course respond
        as soon as possible as the capacity of the compositor to buffer incoming
        input events is finite. *)

      method private virtual on_released : [> `V3 ] t -> unit

      (** The key triggering the binding has been released.

        This event indicates that the physical key triggering the binding has
        been released.

        Releasing the modifiers for the binding without releasing the "main"
        physical key that produces the bound keysym does not trigger the release
        event. This event is sent when the "main" key is released, even if the
        modifiers have changed since the pressed event.

        This event will be followed by a manage_start event after all other new
        state has been sent by the server.

        The compositor should wait for the manage sequence to complete before
        processing further input events. This allows the window manager client
        to, for example, modify key bindings and keyboard focus without racing
        against future input events. The window manager should of course respond
        as soon as possible as the capacity of the compositor to buffer incoming
        input events is finite. *)

      method private virtual on_stop_repeat : [> `V3 ] t -> unit

      (** Repeating should be stopped.

        This event indicates that repeating should be stopped for the binding if
        the window manager has been repeating some action since the pressed
        event.

        This event is generally sent when some other (possibly unbound) key is
        pressed after the pressed event is sent and before the released event
        is sent for this binding.

        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)

      method min_version = 3l
    end
end

(** Xkb bindings seat.

    This object manages xkb bindings state associated with a specific seat. *)
module River_xkb_bindings_seat_v1 = struct
  type 'v t = ([ `River_xkb_bindings_seat_v1 ], 'v, [ `Client ]) Proxy.t

  (** {2 Version 2} *)

  (** Cancel an ensure_next_key_eaten request.

      This requests cancels the effect of the latest ensure_next_key_eaten
      request if no key has been eaten due to the request yet. This request
      has no effect if a key has already been eaten or no
      ensure_next_key_eaten was made.

      Rationale: the window manager may wish cancel an uncompleted "chorded"
      keybinding after a timeout of a few seconds. Note that since this
      timeout use-case requires the window manager to trigger a manage sequence
      with the river_window_manager_v1.manage_dirty request it is possible that
      the ate_unbound_key key event may be sent before the window manager has
      a chance to make the cancel_ensure_next_key_eaten request.

      This request modifies window management state and may only be made as
      part of a manage sequence, see the river_window_manager_v1 description. *)
  let cancel_ensure_next_key_eaten (_t : ([< `V2 | `V3 ] as 'v) t) =
    let _msg = Proxy.alloc _t ~op:2 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  ;;

  (** Ensure the next key press event is eaten.

      Ensure that the next non-modifier key press and corresponding release
      events for this seat are not sent to the currently focused surface.

      If the next non-modifier key press triggers a binding, the
      pressed/released events are sent to the river_xkb_binding_v1 object as
      usual.

      If the next non-modifier key press does not trigger a binding, the
      ate_unbound_key event is sent instead.

      Rationale: the window manager may wish to implement "chorded"
      keybindings where triggering a binding activates a "submap" with a
      different set of keybindings. Without a way to eat the next key
      press event, there is no good way for the window manager to know that it
      should error out and exit the submap when a key not bound in the submap
      is pressed.

      This request modifies window management state and may only be made as
      part of a manage sequence, see the river_window_manager_v1 description. *)
  let ensure_next_key_eaten (_t : ([< `V2 | `V3 ] as 'v) t) =
    let _msg = Proxy.alloc _t ~op:1 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  ;;

  (** Destroy the object.

      This request indicates that the client will no longer use the object and
      that it may be safely destroyed. *)
  let destroy (_t : ([< `V2 | `V3 ] as 'v) t) =
    let _msg = Proxy.alloc _t ~op:0 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg;
    Proxy.shutdown_send _t
  ;;

  (** {2 Version 3} *)

  (** Watch for change in active modifiers.

      Request that the server send the modifiers_update event whenever a state
      change occurs for at least one of the modifiers specified by the
      modifiers argument.

      The window manager should make this request with the modifiers argument
      set to 0 when it no longer wishes to take action based on a change in
      modifiers.

      This request modifies window management state and may only be made as
      part of a manage sequence, see the river_window_manager_v1 description. *)
  let modifiers_watch (_t : ([< `V3 ] as 'v) t) ~modifiers =
    let _msg = Proxy.alloc _t ~op:3 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Imports.River_seat_v1.Modifiers.to_int32 modifiers);
    Proxy.send _t _msg
  ;;

  (**/**)

  class virtual ['v] _handlers_unsafe =
    object (_self : (_, 'v, _) #Proxy.Handler.t)
      method user_data = S.No_data
      method metadata = (module River_xkb_bindings_v1_proto.River_xkb_bindings_seat_v1)
      method max_version = 3l
      method private virtual on_ate_unbound_key : [> ] t -> unit

      method
        private
        virtual on_modifiers_update
        : [> ] t
          -> old:Imports.River_seat_v1.Modifiers.t
          -> new_:Imports.River_seat_v1.Modifiers.t
          -> unit

      method dispatch (_proxy : 'v t) _msg =
        let _proxy = Proxy.cast_version _proxy in
        match Msg.op _msg with
        | 0 -> _self#on_ate_unbound_key _proxy
        | 1 ->
          let old = Msg.get_int _msg |> Imports.River_seat_v1.Modifiers.of_int32 in
          let new_ = Msg.get_int _msg |> Imports.River_seat_v1.Modifiers.of_int32 in
          _self#on_modifiers_update _proxy ~old ~new_
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

      inherit [[< `V1 | `V2 | `V3 ] as 'v] _handlers_unsafe

      (**/**)

      method private virtual on_ate_unbound_key : [> `V2 | `V3 ] t -> unit

      (** An unbound key press event was eaten.

        An unbound key press event was eaten due to the ensure_next_key_eaten
        request.

        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)

      method
        private
        virtual on_modifiers_update
        : [> `V3 ] t
          -> old:Imports.River_seat_v1.Modifiers.t
          -> new_:Imports.River_seat_v1.Modifiers.t
          -> unit

      (** Active modifiers for the seat changed.

        The set of currently active modifiers for the seat changed. This event
        is only sent when there is a change in state for modifiers marked as
        watched using the modifiers_watch request.

        The old and new arguments convey the set of modifiers active before and
        after the change. All modifiers are included in the old and new
        arguments, including modifiers that are not watched.

        Since this event is only sent when there is a change in state for
        watched modifiers, it follows that at least one watched modifier is
        active in old but inactive in new or vice-versa.

        This event will be followed by a manage_start event after all other new
        state has been sent by the server.

        The compositor should wait for the manage sequence to complete before
        processing further input events. This allows the window manager client
        to, for example, modify key bindings and keyboard focus without racing
        against future input events. The window manager should of course respond
        as soon as possible as the capacity of the compositor to buffer incoming
        input events is finite. *)

      method min_version = 1l
    end

  (** Handler for a proxy with version >= 2. *)
  class virtual ['v] v2 =
    object (_ : (_, 'v, _) #Proxy.Service_handler.t)

      (**/**)

      inherit [[< `V2 | `V3 ] as 'v] _handlers_unsafe

      (**/**)

      method private virtual on_ate_unbound_key : [> `V2 | `V3 ] t -> unit

      (** An unbound key press event was eaten.

        An unbound key press event was eaten due to the ensure_next_key_eaten
        request.

        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)

      method
        private
        virtual on_modifiers_update
        : [> `V3 ] t
          -> old:Imports.River_seat_v1.Modifiers.t
          -> new_:Imports.River_seat_v1.Modifiers.t
          -> unit

      (** Active modifiers for the seat changed.

        The set of currently active modifiers for the seat changed. This event
        is only sent when there is a change in state for modifiers marked as
        watched using the modifiers_watch request.

        The old and new arguments convey the set of modifiers active before and
        after the change. All modifiers are included in the old and new
        arguments, including modifiers that are not watched.

        Since this event is only sent when there is a change in state for
        watched modifiers, it follows that at least one watched modifier is
        active in old but inactive in new or vice-versa.

        This event will be followed by a manage_start event after all other new
        state has been sent by the server.

        The compositor should wait for the manage sequence to complete before
        processing further input events. This allows the window manager client
        to, for example, modify key bindings and keyboard focus without racing
        against future input events. The window manager should of course respond
        as soon as possible as the capacity of the compositor to buffer incoming
        input events is finite. *)

      method min_version = 2l
    end

  (** Handler for a proxy with version >= 3. *)
  class virtual ['v] v3 =
    object (_ : (_, 'v, _) #Proxy.Service_handler.t)

      (**/**)

      inherit [[< `V3 ] as 'v] _handlers_unsafe

      (**/**)

      method private virtual on_ate_unbound_key : [> `V3 ] t -> unit

      (** An unbound key press event was eaten.

        An unbound key press event was eaten due to the ensure_next_key_eaten
        request.

        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)

      method
        private
        virtual on_modifiers_update
        : [> `V3 ] t
          -> old:Imports.River_seat_v1.Modifiers.t
          -> new_:Imports.River_seat_v1.Modifiers.t
          -> unit

      (** Active modifiers for the seat changed.

        The set of currently active modifiers for the seat changed. This event
        is only sent when there is a change in state for modifiers marked as
        watched using the modifiers_watch request.

        The old and new arguments convey the set of modifiers active before and
        after the change. All modifiers are included in the old and new
        arguments, including modifiers that are not watched.

        Since this event is only sent when there is a change in state for
        watched modifiers, it follows that at least one watched modifier is
        active in old but inactive in new or vice-versa.

        This event will be followed by a manage_start event after all other new
        state has been sent by the server.

        The compositor should wait for the manage sequence to complete before
        processing further input events. This allows the window manager client
        to, for example, modify key bindings and keyboard focus without racing
        against future input events. The window manager should of course respond
        as soon as possible as the capacity of the compositor to buffer incoming
        input events is finite. *)

      method min_version = 3l
    end
end
