(* This file was generated automatically by wayland-scanner-ocaml *)

[@@@ocaml.warning "-27-34"]
open struct
  module Imports = struct
    include River_window_management_v1_proto
    include Wayland.Wayland_proto
  end
  
  module Proxy = Wayland.Proxy
  module Msg = Wayland.Msg
  module Fixed = Wayland.Fixed
  module Iface_reg = Wayland.Iface_reg
  module S = Wayland.S
end


(** Window manager global interface.
    
    This global interface should only be advertised to the window manager
    process. Only one window management client may be active at a time. The
    compositor should use the unavailable event if necessary to enforce this.
    
    There are two disjoint categories of state managed by this protocol:
    
    Window management state influences the communication between the
    compositor and individual windows (e.g. xdg_toplevels). Window management
    state includes window dimensions, fullscreen state, keyboard focus,
    keyboard bindings, and more.
    
    Rendering state only affects the rendered output of the compositor and
    does not influence communication between the compositor and individual
    windows. Rendering state includes the position and rendering order of
    windows, shell surfaces, decoration surfaces, borders, and more.
    
    Window management state may only be modified by the window manager as part
    of a manage sequence. A manage sequence is started with the manage_start
    event and ended with the manage_finish request. It is a protocol error to
    modify window management state outside of a manage sequence.
    
    A manage sequence is always followed by at least one render sequence. A
    render sequence is started with the render_start event and ended with the
    render_finish request.
    
    Rendering state may be modified by the window manager during a manage
    sequence or a render sequence. Regardless of when the rendering state is
    modified, it is applied with the next render_finish request. It is a
    protocol error to modify rendering state outside of a manage or render
    sequence.
    
    The server will start a manage sequence by sending new state and the
    manage_start event as soon as possible whenever there is a change in state
    that must be communicated with the window manager.
    
    If the window manager client needs to ensure a manage sequence is started
    due to a state change the compositor is not aware of, it may send the
    manage_dirty request.
    
    The server will start a render sequence by sending new state and the
    render_start event as soon as possible whenever there is a change in
    window dimensions that must be communicated with the window manager.
    Multiple render sequences may be made consecutively without a manage
    sequence in between, for example if a window independently changes its own
    dimensions.
    
    To summarize, the main loop of this protocol is as follows:
    
    1. The server sends events indicating all changes since the last
    manage sequence followed by the manage_start event.
    
    2. The client sends requests modifying window management state or
    rendering state (as defined above) followed by the manage_finish
    request.
    
    3. The server sends new state to windows and waits for responses.
    
    4. The server sends new window dimensions to the client followed by the
    render_start event.
    
    5. The client sends requests modifying rendering state (as defined above)
    followed by the render_finish request.
    
    6. If window dimensions change, loop back to step 4.
    If state that requires a manage sequence changes or if the client makes
    a manage_dirty request, loop back to step 1.
    
    For the purposes of frame perfection, the server may delay rendering new
    state committed by the windows in step 3 until after step 5 is finished.
    
    It is a protocol error for the client to make a manage_finish or
    render_finish request that violates this ordering. *)
module River_window_manager_v1 = struct
  type 'v t = ([`River_window_manager_v1], 'v, [`Client]) Proxy.t
  module Error = River_window_management_v1_proto.River_window_manager_v1.Error
  
  (** {2 Version 1, 2, 3} *)
  
  (** Assign the river_shell_surface_v1 surface role.
      
      Create a new shell surface for window manager UI and assign the
      river_shell_surface_v1 role to the surface.
      
      Providing a wl_surface which already has a role or already has a buffer
      attached or committed is a protocol error. *)
  let get_shell_surface (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) 
    (id:([`River_shell_surface_v1], 'v, [`Client]) #Proxy.Handler.t) ~(surface:([`Wl_surface], _, [`Client]) Proxy.t) =
    let __id = Proxy.spawn _t id in
    let _msg = Proxy.alloc _t ~op:5 ~ints:2 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id __id);
    Msg.add_int _msg (Proxy.id surface);
    Proxy.send _t _msg;
    __id
  
  (** Finish a render sequence.
      
      This request indicates that the client has made all changes to rendering
      state it wishes to include in the current manage sequence and that the
      server should atomically apply and display these state changes to the
      user.
      
      After sending this request, it is a protocol error for the client to
      make further changes to rendering state until the next manage_start or
      render_start event is received, whichever comes first.
      
      See the description of the river_window_manager_v1 interface for a
      complete overview of the manage/render sequence loop. *)
  let render_finish (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:4 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (** Ensure a manage sequence is started.
      
      This request ensures a manage sequence is started and that a
      manage_start event is sent by the server. If this request is made during
      an ongoing manage sequence, a new manage sequence will be started as
      soon as the current one is completed.
      
      The client may want to use this request due to an internal state change
      that the compositor is not aware of (e.g. a dbus event) which should
      affect window management or rendering state. *)
  let manage_dirty (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:3 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (** Finish a manage sequence.
      
      This request indicates that the client has made all changes to window
      management state it wishes to include in the current manage sequence and
      that the server should atomically send these state changes to the
      windows and continue with the manage sequence.
      
      After sending this request, it is a protocol error for the client to
      make further changes to window management state until the next
      manage_start event is received.
      
      See the description of the river_window_manager_v1 interface for a
      complete overview of the manage/render sequence loop. *)
  let manage_finish (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:2 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (** Destroy the river_window_manager_v1 object.
      
      This request should be called after the finished event has been received
      to complete destruction of the object.
      
      If a client wishes to destroy this object it should send a
      river_window_manager_v1.stop request and wait for a
      river_window_manager_v1.finished event. Once the finished event is
      received it is safe to destroy this object and any other objects created
      through this interface. *)
  let destroy (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:1 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg;
    Proxy.shutdown_send _t
  
  (** Stop sending events.
      
      This request indicates that the client no longer wishes to receive
      events on this object.
      
      The Wayland protocol is asynchronous, which means the server may send
      further events until the stop request is processed. The client must wait
      for a river_window_manager_v1.finished event before destroying this
      object. *)
  let stop (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:0 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  
  (** {2 Version 4, 5} *)
  
  (** Exit the Wayland session.
      
      End the current Wayland session and exit the compositor.
      All Wayland clients running in the current session, including
      the window manager, will be disconnected.
      
      Window managers should only make this request if the user explicitly
      asks to exit the Wayland session, not for example on normal window
      manager termination. *)
  let exit_session (_t:([< `V4 | `V5] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:6 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (**/**)
  class virtual ['v] _handlers_unsafe = object (_self : (_, 'v, _) #Proxy.Handler.t)
    method user_data = S.No_data
    method metadata = (module River_window_management_v1_proto.River_window_manager_v1)
    method max_version = 5l
    
    method private virtual on_unavailable : [> ] t -> unit
    
    method private virtual on_finished : [> ] t -> unit
    
    method private virtual on_manage_start : [> ] t -> unit
    
    method private virtual on_render_start : [> ] t -> unit
    
    method private virtual on_session_locked : [> ] t -> unit
    
    method private virtual on_session_unlocked : [> ] t -> unit
    
    method private virtual on_window : [> ] t -> ([`River_window_v1], 'v, [`Client]) Proxy.t -> unit
    
    method private virtual on_output : [> ] t -> ([`River_output_v1], 'v, [`Client]) Proxy.t -> unit
    
    method private virtual on_seat : [> ] t -> ([`River_seat_v1], 'v, [`Client]) Proxy.t -> unit
    
    
    method dispatch (_proxy : 'v t) _msg =
      let _proxy = Proxy.cast_version _proxy in
      match Msg.op _msg with
      | 0 ->
        _self#on_unavailable _proxy 
      | 1 ->
        _self#on_finished _proxy 
      | 2 ->
        _self#on_manage_start _proxy 
      | 3 ->
        _self#on_render_start _proxy 
      | 4 ->
        _self#on_session_locked _proxy 
      | 5 ->
        _self#on_session_unlocked _proxy 
      | 6 ->
        let id : ([`River_window_v1], _, _) Proxy.t =
          Msg.get_int _msg |> Proxy.Handler.accept_new _proxy (module Imports.River_window_v1) in
        _self#on_window _proxy id
      | 7 ->
        let id : ([`River_output_v1], _, _) Proxy.t =
          Msg.get_int _msg |> Proxy.Handler.accept_new _proxy (module Imports.River_output_v1) in
        _self#on_output _proxy id
      | 8 ->
        let id : ([`River_seat_v1], _, _) Proxy.t =
          Msg.get_int _msg |> Proxy.Handler.accept_new _proxy (module Imports.River_seat_v1) in
        _self#on_seat _proxy id
      | _ -> assert false
  end
  (**/**)
  
  (** {2 Handlers}
      Note: Servers will always want to use [v1].
   *)
  
  
  (** Handler for a proxy with version >= 1. *)
  class virtual ['v] v1 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V1 | `V2 | `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_unavailable : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Window management unavailable.
        
        This event indicates that window management is not available to the
        client, perhaps due to another window management client already running.
        The circumstances causing this event to be sent are compositor policy.
        
        If sent, this event is guaranteed to be the first and only event sent by
        the server.
        
        The server will send no further events on this object. The client should
        destroy this object and all objects created through this interface. *)
    
    method private virtual on_finished : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** The server has finished with the window manager.
        
        This event indicates that the server will send no further events on this
        object. The client should destroy the object. See
        river_window_manager_v1.destroy for more information. *)
    
    method private virtual on_manage_start : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Start a manage sequence.
        
        This event indicates that the server has sent events indicating all
        state changes since the last manage sequence.
        
        In response to this event, the client should make requests modifying
        window management state as it chooses. Then, the client must make the
        manage_finish request.
        
        See the description of the river_window_manager_v1 interface for a
        complete overview of the manage/render sequence loop. *)
    
    method private virtual on_render_start : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Start a render sequence.
        
        This event indicates that the server has sent all
        river_window_v1.dimensions events necessary.
        
        In response to this event, the client should make requests modifying
        rendering state as it chooses. Then, the client must make the
        render_finish request.
        
        See the description of the river_window_manager_v1 interface for a
        complete overview of the manage/render sequence loop. *)
    
    method private virtual on_session_locked : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** The session has been locked.
        
        This event indicates that the session has been locked.
        
        The window manager may wish to restrict which key bindings are available
        while locked or otherwise use this information.
        
        If the session is currently locked when the river_window_manager_v1
        object is created, the session_locked event will be sent in the first
        manage sequence.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_session_unlocked : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** The session has been unlocked.
        
        This event indicates that the session has been unlocked.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_window : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> ([`River_window_v1], 'v, [`Client]) Proxy.t ->
                                       unit
    
    (** New window.
        
        A new window has been created.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_output : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> ([`River_output_v1], 'v, [`Client]) Proxy.t ->
                                       unit
    
    (** New output.
        
        A new logical output has been created, perhaps due to a new physical
        monitor being plugged in or perhaps due to a change in configuration.
        
        This event will be followed by river_output_v1.position and dimensions
        events as well as a manage_start event after all other new state has
        been sent by the server. *)
    
    method private virtual on_seat : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> ([`River_seat_v1], 'v, [`Client]) Proxy.t ->
                                     unit
    
    (** New seat.
        
        A new seat has been created.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method min_version = 1l
    method bind_version : [`V1] = `V1
  end
  
  (** Handler for a proxy with version >= 2. *)
  class virtual ['v] v2 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V2 | `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_unavailable : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Window management unavailable.
        
        This event indicates that window management is not available to the
        client, perhaps due to another window management client already running.
        The circumstances causing this event to be sent are compositor policy.
        
        If sent, this event is guaranteed to be the first and only event sent by
        the server.
        
        The server will send no further events on this object. The client should
        destroy this object and all objects created through this interface. *)
    
    method private virtual on_finished : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** The server has finished with the window manager.
        
        This event indicates that the server will send no further events on this
        object. The client should destroy the object. See
        river_window_manager_v1.destroy for more information. *)
    
    method private virtual on_manage_start : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Start a manage sequence.
        
        This event indicates that the server has sent events indicating all
        state changes since the last manage sequence.
        
        In response to this event, the client should make requests modifying
        window management state as it chooses. Then, the client must make the
        manage_finish request.
        
        See the description of the river_window_manager_v1 interface for a
        complete overview of the manage/render sequence loop. *)
    
    method private virtual on_render_start : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Start a render sequence.
        
        This event indicates that the server has sent all
        river_window_v1.dimensions events necessary.
        
        In response to this event, the client should make requests modifying
        rendering state as it chooses. Then, the client must make the
        render_finish request.
        
        See the description of the river_window_manager_v1 interface for a
        complete overview of the manage/render sequence loop. *)
    
    method private virtual on_session_locked : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** The session has been locked.
        
        This event indicates that the session has been locked.
        
        The window manager may wish to restrict which key bindings are available
        while locked or otherwise use this information.
        
        If the session is currently locked when the river_window_manager_v1
        object is created, the session_locked event will be sent in the first
        manage sequence.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_session_unlocked : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** The session has been unlocked.
        
        This event indicates that the session has been unlocked.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_window : [> `V2 | `V3 | `V4 | `V5] t -> ([`River_window_v1], 'v, [`Client]) Proxy.t ->
                                       unit
    
    (** New window.
        
        A new window has been created.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_output : [> `V2 | `V3 | `V4 | `V5] t -> ([`River_output_v1], 'v, [`Client]) Proxy.t ->
                                       unit
    
    (** New output.
        
        A new logical output has been created, perhaps due to a new physical
        monitor being plugged in or perhaps due to a change in configuration.
        
        This event will be followed by river_output_v1.position and dimensions
        events as well as a manage_start event after all other new state has
        been sent by the server. *)
    
    method private virtual on_seat : [> `V2 | `V3 | `V4 | `V5] t -> ([`River_seat_v1], 'v, [`Client]) Proxy.t -> unit
    
    (** New seat.
        
        A new seat has been created.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method min_version = 2l
    method bind_version : [`V2] = `V2
  end
  
  (** Handler for a proxy with version >= 3. *)
  class virtual ['v] v3 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_unavailable : [> `V3 | `V4 | `V5] t -> unit
    
    (** Window management unavailable.
        
        This event indicates that window management is not available to the
        client, perhaps due to another window management client already running.
        The circumstances causing this event to be sent are compositor policy.
        
        If sent, this event is guaranteed to be the first and only event sent by
        the server.
        
        The server will send no further events on this object. The client should
        destroy this object and all objects created through this interface. *)
    
    method private virtual on_finished : [> `V3 | `V4 | `V5] t -> unit
    
    (** The server has finished with the window manager.
        
        This event indicates that the server will send no further events on this
        object. The client should destroy the object. See
        river_window_manager_v1.destroy for more information. *)
    
    method private virtual on_manage_start : [> `V3 | `V4 | `V5] t -> unit
    
    (** Start a manage sequence.
        
        This event indicates that the server has sent events indicating all
        state changes since the last manage sequence.
        
        In response to this event, the client should make requests modifying
        window management state as it chooses. Then, the client must make the
        manage_finish request.
        
        See the description of the river_window_manager_v1 interface for a
        complete overview of the manage/render sequence loop. *)
    
    method private virtual on_render_start : [> `V3 | `V4 | `V5] t -> unit
    
    (** Start a render sequence.
        
        This event indicates that the server has sent all
        river_window_v1.dimensions events necessary.
        
        In response to this event, the client should make requests modifying
        rendering state as it chooses. Then, the client must make the
        render_finish request.
        
        See the description of the river_window_manager_v1 interface for a
        complete overview of the manage/render sequence loop. *)
    
    method private virtual on_session_locked : [> `V3 | `V4 | `V5] t -> unit
    
    (** The session has been locked.
        
        This event indicates that the session has been locked.
        
        The window manager may wish to restrict which key bindings are available
        while locked or otherwise use this information.
        
        If the session is currently locked when the river_window_manager_v1
        object is created, the session_locked event will be sent in the first
        manage sequence.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_session_unlocked : [> `V3 | `V4 | `V5] t -> unit
    
    (** The session has been unlocked.
        
        This event indicates that the session has been unlocked.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_window : [> `V3 | `V4 | `V5] t -> ([`River_window_v1], 'v, [`Client]) Proxy.t -> unit
    
    (** New window.
        
        A new window has been created.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_output : [> `V3 | `V4 | `V5] t -> ([`River_output_v1], 'v, [`Client]) Proxy.t -> unit
    
    (** New output.
        
        A new logical output has been created, perhaps due to a new physical
        monitor being plugged in or perhaps due to a change in configuration.
        
        This event will be followed by river_output_v1.position and dimensions
        events as well as a manage_start event after all other new state has
        been sent by the server. *)
    
    method private virtual on_seat : [> `V3 | `V4 | `V5] t -> ([`River_seat_v1], 'v, [`Client]) Proxy.t -> unit
    
    (** New seat.
        
        A new seat has been created.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method min_version = 3l
    method bind_version : [`V3] = `V3
  end
  
  (** Handler for a proxy with version >= 4. *)
  class virtual ['v] v4 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_unavailable : [> `V4 | `V5] t -> unit
    
    (** Window management unavailable.
        
        This event indicates that window management is not available to the
        client, perhaps due to another window management client already running.
        The circumstances causing this event to be sent are compositor policy.
        
        If sent, this event is guaranteed to be the first and only event sent by
        the server.
        
        The server will send no further events on this object. The client should
        destroy this object and all objects created through this interface. *)
    
    method private virtual on_finished : [> `V4 | `V5] t -> unit
    
    (** The server has finished with the window manager.
        
        This event indicates that the server will send no further events on this
        object. The client should destroy the object. See
        river_window_manager_v1.destroy for more information. *)
    
    method private virtual on_manage_start : [> `V4 | `V5] t -> unit
    
    (** Start a manage sequence.
        
        This event indicates that the server has sent events indicating all
        state changes since the last manage sequence.
        
        In response to this event, the client should make requests modifying
        window management state as it chooses. Then, the client must make the
        manage_finish request.
        
        See the description of the river_window_manager_v1 interface for a
        complete overview of the manage/render sequence loop. *)
    
    method private virtual on_render_start : [> `V4 | `V5] t -> unit
    
    (** Start a render sequence.
        
        This event indicates that the server has sent all
        river_window_v1.dimensions events necessary.
        
        In response to this event, the client should make requests modifying
        rendering state as it chooses. Then, the client must make the
        render_finish request.
        
        See the description of the river_window_manager_v1 interface for a
        complete overview of the manage/render sequence loop. *)
    
    method private virtual on_session_locked : [> `V4 | `V5] t -> unit
    
    (** The session has been locked.
        
        This event indicates that the session has been locked.
        
        The window manager may wish to restrict which key bindings are available
        while locked or otherwise use this information.
        
        If the session is currently locked when the river_window_manager_v1
        object is created, the session_locked event will be sent in the first
        manage sequence.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_session_unlocked : [> `V4 | `V5] t -> unit
    
    (** The session has been unlocked.
        
        This event indicates that the session has been unlocked.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_window : [> `V4 | `V5] t -> ([`River_window_v1], 'v, [`Client]) Proxy.t -> unit
    
    (** New window.
        
        A new window has been created.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_output : [> `V4 | `V5] t -> ([`River_output_v1], 'v, [`Client]) Proxy.t -> unit
    
    (** New output.
        
        A new logical output has been created, perhaps due to a new physical
        monitor being plugged in or perhaps due to a change in configuration.
        
        This event will be followed by river_output_v1.position and dimensions
        events as well as a manage_start event after all other new state has
        been sent by the server. *)
    
    method private virtual on_seat : [> `V4 | `V5] t -> ([`River_seat_v1], 'v, [`Client]) Proxy.t -> unit
    
    (** New seat.
        
        A new seat has been created.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method min_version = 4l
    method bind_version : [`V4] = `V4
  end
  
  (** Handler for a proxy with version >= 5. *)
  class virtual ['v] v5 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_unavailable : [> `V5] t -> unit
    
    (** Window management unavailable.
        
        This event indicates that window management is not available to the
        client, perhaps due to another window management client already running.
        The circumstances causing this event to be sent are compositor policy.
        
        If sent, this event is guaranteed to be the first and only event sent by
        the server.
        
        The server will send no further events on this object. The client should
        destroy this object and all objects created through this interface. *)
    
    method private virtual on_finished : [> `V5] t -> unit
    
    (** The server has finished with the window manager.
        
        This event indicates that the server will send no further events on this
        object. The client should destroy the object. See
        river_window_manager_v1.destroy for more information. *)
    
    method private virtual on_manage_start : [> `V5] t -> unit
    
    (** Start a manage sequence.
        
        This event indicates that the server has sent events indicating all
        state changes since the last manage sequence.
        
        In response to this event, the client should make requests modifying
        window management state as it chooses. Then, the client must make the
        manage_finish request.
        
        See the description of the river_window_manager_v1 interface for a
        complete overview of the manage/render sequence loop. *)
    
    method private virtual on_render_start : [> `V5] t -> unit
    
    (** Start a render sequence.
        
        This event indicates that the server has sent all
        river_window_v1.dimensions events necessary.
        
        In response to this event, the client should make requests modifying
        rendering state as it chooses. Then, the client must make the
        render_finish request.
        
        See the description of the river_window_manager_v1 interface for a
        complete overview of the manage/render sequence loop. *)
    
    method private virtual on_session_locked : [> `V5] t -> unit
    
    (** The session has been locked.
        
        This event indicates that the session has been locked.
        
        The window manager may wish to restrict which key bindings are available
        while locked or otherwise use this information.
        
        If the session is currently locked when the river_window_manager_v1
        object is created, the session_locked event will be sent in the first
        manage sequence.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_session_unlocked : [> `V5] t -> unit
    
    (** The session has been unlocked.
        
        This event indicates that the session has been unlocked.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_window : [> `V5] t -> ([`River_window_v1], 'v, [`Client]) Proxy.t -> unit
    
    (** New window.
        
        A new window has been created.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_output : [> `V5] t -> ([`River_output_v1], 'v, [`Client]) Proxy.t -> unit
    
    (** New output.
        
        A new logical output has been created, perhaps due to a new physical
        monitor being plugged in or perhaps due to a change in configuration.
        
        This event will be followed by river_output_v1.position and dimensions
        events as well as a manage_start event after all other new state has
        been sent by the server. *)
    
    method private virtual on_seat : [> `V5] t -> ([`River_seat_v1], 'v, [`Client]) Proxy.t -> unit
    
    (** New seat.
        
        A new seat has been created.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method min_version = 5l
    method bind_version : [`V5] = `V5
  end
end

(** A logical window.
    
    This represents a logical window. For example, a window may correspond to
    an xdg_toplevel or Xwayland window.
    
    A newly created window will not be displayed until the window manager
    makes a propose_dimensions or fullscreen request as part of a manage
    sequence, the server replies with a dimensions event as part of a render
    sequence, and that render sequence is finished. *)
module River_window_v1 = struct
  type 'v t = ([`River_window_v1], 'v, [`Client]) Proxy.t
  module Error = River_window_management_v1_proto.River_window_v1.Error
  
  module Decoration_hint = River_window_management_v1_proto.River_window_v1.Decoration_hint
  
  module Edges = River_window_management_v1_proto.River_window_v1.Edges
  
  module Capabilities = River_window_management_v1_proto.River_window_v1.Capabilities
  
  (** {2 Version 1} *)
  
  (** Make the window not fullscreen.
      
      Make the window not fullscreen.
      
      The position and dimensions are undefined after this request is made
      until a manage sequence in which the window manager makes the
      propose_dimensions and set_position requests is completed.
      
      The window manager should make propose_dimensions and set_position
      requests in the same manage sequence as the exit_fullscreen request for
      frame perfection.
      
      This request does not inform the window that it is fullscreen, see the
      river_window_v1.inform_fullscreen and inform_not_fullscreen requests.
      
      This request modifies window management state and may only be made as
      part of a manage sequence, see the river_window_manager_v1 description. *)
  let exit_fullscreen (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) 
     =
    let _msg = Proxy.alloc _t ~op:20 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (** Make the window fullscreen.
      
      Make the window fullscreen on the given output. If multiple windows are
      fullscreen on the same output at the same time only the "top" window in
      rendering order shall be displayed.
      
      All river_shell_surface_v1 objects above the top fullscreen window in
      the rendering order will continue to be rendered.
      
      The compositor will handle the position and dimensions of the window
      while it is fullscreen. The set_position and propose_dimensions requests
      shall not affect the current position and dimensions of a fullscreen
      window.
      
      When a fullscreen request is made, the server must send a dimensions
      event in response as soon as possible. It may not be possible to send a
      dimensions event in the very next render sequence if, for example, the
      window takes too long to respond. In this case, the server will send the
      dimensions event in a future render sequence.
      
      The compositor will clip window content, decoration surfaces, and
      borders to the given output's dimensions while the window is fullscreen.
      The effects of set_clip_box and set_content_clip_box are ignored while
      the window is fullscreen.
      
      If the output on which a window is currently fullscreen is removed, the
      windowing state is modified as if there were an exit_fullscreen request
      made in the same manage sequence as the river_output_v1.removed event.
      
      This request does not inform the window that it is fullscreen, see the
      river_window_v1.inform_fullscreen and inform_not_fullscreen requests.
      
      This request modifies window management state and may only be made as
      part of a manage sequence, see the river_window_manager_v1 description. *)
  let fullscreen (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) ~(output:([`River_output_v1], _, [`Client]) Proxy.t) =
    let _msg = Proxy.alloc _t ~op:19 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id output);
    Proxy.send _t _msg
  
  (** Inform the window that it is not fullscreen.
      
      Inform the window that it is not fullscreen. The window might use this
      information to adapt the style of its client-side window decorations for
      example.
      
      This request does not affect the size/position of the window or cause it
      to become the only window rendered, see the river_window_v1.fullscreen
      and exit_fullscreen requests for that.
      
      This request modifies window management state and may only be made as
      part of a manage sequence, see the river_window_manager_v1 description. *)
  let inform_not_fullscreen (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) 
     =
    let _msg = Proxy.alloc _t ~op:18 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (** Inform the window that it is fullscreen.
      
      Inform the window that it is fullscreen. The window might use this
      information to adapt the style of its client-side window decorations for
      example.
      
      This request does not affect the size/position of the window or cause it
      to become the only window rendered, see the river_window_v1.fullscreen
      and exit_fullscreen requests for that.
      
      This request modifies window management state and may only be made as
      part of a manage sequence, see the river_window_manager_v1 description. *)
  let inform_fullscreen (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) 
     =
    let _msg = Proxy.alloc _t ~op:17 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (** Inform the window that it is unmaximized.
      
      Inform the window that it is unmaximized. The window might use this
      information to adapt the style of its client-side window decorations for
      example.
      
      This request modifies window management state and may only be made as
      part of a manage sequence, see the river_window_manager_v1 description. *)
  let inform_unmaximized (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) 
     =
    let _msg = Proxy.alloc _t ~op:16 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (** Inform the window that it is maximized.
      
      Inform the window that it is maximized. The window might use this
      information to adapt the style of its client-side window decorations for
      example.
      
      The window manager remains responsible for handling the position and
      dimensions of the window while it is maximized.
      
      This request modifies window management state and may only be made as
      part of a manage sequence, see the river_window_manager_v1 description. *)
  let inform_maximized (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) 
     =
    let _msg = Proxy.alloc _t ~op:15 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (** Inform window of supported capabilities.
      
      This request informs the window of the capabilities supported by the
      window manager. If the window manager, for example, ignores requests to
      be maximized from the window it should not tell the window that it
      supports the maximize capability.
      
      The window might use this information to, for example, only show a
      maximize button if the window manager supports the maximize capability.
      
      The window manager client should use this request to set capabilities
      for all new windows. If this request is never made, the compositor will
      inform windows that all capabilities are supported.
      
      This request modifies window management state and may only be made as
      part of a manage sequence, see the river_window_manager_v1 description. *)
  let set_capabilities (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) 
    ~caps =
    let _msg = Proxy.alloc _t ~op:14 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Imports.River_window_v1.Capabilities.to_int32 caps);
    Proxy.send _t _msg
  
  (** Inform the window it no longer being resized.
      
      Inform the window that it is no longer being resized. The window manager
      should use this request to inform windows that are the target of an
      interactive resize that the interactive resize has ended for example.
      
      This request modifies window management state and may only be made as
      part of a manage sequence, see the river_window_manager_v1 description. *)
  let inform_resize_end (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) 
     =
    let _msg = Proxy.alloc _t ~op:13 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (** Inform the window it is being resized.
      
      Inform the window that it is being resized. The window manager should
      use this request to inform windows that are the target of an interactive
      resize for example.
      
      The window manager remains responsible for handling the position and
      dimensions of the window while it is resizing.
      
      This request modifies window management state and may only be made as
      part of a manage sequence, see the river_window_manager_v1 description. *)
  let inform_resize_start (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) 
     =
    let _msg = Proxy.alloc _t ~op:12 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (** Create a decoration below the window in z-order.
      
      Create a decoration surface and assign the river_decoration_v1 role to
      the surface. The created decoration is placed below the window in
      rendering order, see the description of river_decoration_v1.
      
      Providing a wl_surface which already has a role or already has a buffer
      attached or committed is a protocol error. *)
  let get_decoration_below (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) 
    (id:([`River_decoration_v1], 'v, [`Client]) #Proxy.Handler.t) ~(surface:([`Wl_surface], _, [`Client]) Proxy.t) =
    let __id = Proxy.spawn _t id in
    let _msg = Proxy.alloc _t ~op:11 ~ints:2 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id __id);
    Msg.add_int _msg (Proxy.id surface);
    Proxy.send _t _msg;
    __id
  
  (** Create a decoration above the window in z-order.
      
      Create a decoration surface and assign the river_decoration_v1 role to
      the surface. The created decoration is placed above the window in
      rendering order, see the description of river_decoration_v1.
      
      Providing a wl_surface which already has a role or already has a buffer
      attached or committed is a protocol error. *)
  let get_decoration_above (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) 
    (id:([`River_decoration_v1], 'v, [`Client]) #Proxy.Handler.t) ~(surface:([`Wl_surface], _, [`Client]) Proxy.t) =
    let __id = Proxy.spawn _t id in
    let _msg = Proxy.alloc _t ~op:10 ~ints:2 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id __id);
    Msg.add_int _msg (Proxy.id surface);
    Proxy.send _t _msg;
    __id
  
  (** Set window tiled state.
      
      Inform the window that it is part of a tiled layout and adjacent to
      other elements in the tiled layout on the given edges.
      
      The window should use this information to change the style of its client
      side decorations and avoid drawing e.g. drop shadows outside of the
      window dimensions on the tiled edges.
      
      Setting the edges argument to none informs the window that it is not
      part of a tiled layout. If this request is never made, the window is
      informed that it is not part of a tiled layout.
      
      This request modifies window management state and may only be made as
      part of a manage sequence, see the river_window_manager_v1 description. *)
  let set_tiled (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) ~edges =
    let _msg = Proxy.alloc _t ~op:9 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Imports.River_window_v1.Edges.to_int32 edges);
    Proxy.send _t _msg
  
  (** Set window borders.
      
      This request decorates the window with borders drawn by the compositor
      on the specified edges of the window. Borders are drawn above the window
      content.
      
      Corners are drawn only between borders on adjacent edges. If e.g. the
      left edge has a border and the top edge does not, the border drawn on
      the left edge will not extend vertically beyond the top edge of the
      window.
      
      Borders are not drawn while the window is fullscreen.
      
      The color is defined by four 32-bit RGBA values. Unless specified in
      another protocol extension, the RGBA values use pre-multiplied alpha.
      
      The valid range for the RGBA values is from 0x00000000 to 0xffffffff.
      These values are interpreted as a percentage:
      - 0x00000000 means 0% of the given color component
      - 0xffffffff means 100% of the given color component
      
      Setting the edges to none or the width to 0 disables the borders.
      Setting a negative width is a protocol error.
      
      This request completely overrides all previous set_borders requests.
      Only the most recent set_borders request has an effect.
      
      Note that the position/dimensions of a river_window_v1 refer to the
      position/dimensions of the window content and are unaffected by the
      presence of borders or decoration surfaces.
      
      This request modifies rendering state and may only be made as part of a
      render sequence, see the river_window_manager_v1 description. *)
  let set_borders (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) ~edges ~width ~r ~g ~b ~a =
    let _msg = Proxy.alloc _t ~op:8 ~ints:6 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Imports.River_window_v1.Edges.to_int32 edges);
    Msg.add_int _msg width;
    Msg.add_int _msg r;
    Msg.add_int _msg g;
    Msg.add_int _msg b;
    Msg.add_int _msg a;
    Proxy.send _t _msg
  
  (** Tell the client to use SSD.
      
      Tell the client to use server side decoration and not draw any client
      side decorations.
      
      This request will have no effect if the client only supports client side
      decoration, see the decoration_hint event.
      
      This request modifies window management state and may only be made as
      part of a manage sequence, see the river_window_manager_v1 description. *)
  let use_ssd (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:7 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (** Tell the client to use CSD.
      
      Tell the client to use client side decoration and draw its own title
      bar, borders, etc.
      
      This is the default if neither this request nor the use_ssd request is
      ever made.
      
      This request modifies window management state and may only be made as
      part of a manage sequence, see the river_window_manager_v1 description. *)
  let use_csd (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:6 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (** Request that the window be shown.
      
      Request that the window be shown. Has no effect if the window is not
      hidden. Does not guarantee that the window is visible as it may be
      completely obscured by other windows placed above it for example.
      
      Newly created windows are considered shown unless explicitly hidden with
      the hide request.
      
      This request modifies rendering state and may only be made as part of a
      render sequence, see the river_window_manager_v1 description. *)
  let show (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:5 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (** Request that the window be hidden.
      
      Request that the window be hidden. Has no effect if the window is
      already hidden. Hides any window borders and decorations as well.
      
      Newly created windows are considered shown unless explicitly hidden with
      the hide request.
      
      This request modifies rendering state and may only be made as part of a
      render sequence, see the river_window_manager_v1 description. *)
  let hide (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:4 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (** Propose window dimensions.
      
      This request proposes dimensions for the window in the compositor's
      logical coordinate space.
      
      The width and height must be greater than or equal to zero. If the width
      or height is zero the window will be allowed to decide its own
      dimensions.
      
      The window may not take the exact dimensions proposed. The actual
      dimensions taken by the window will be sent in a subsequent
      river_window_v1.dimensions event. For example, a terminal emulator may
      only allow dimensions that are multiple of the cell size.
      
      When a propose_dimensions request is made, the server must send a
      dimensions event in response as soon as possible. It may not be possible
      to send a dimensions event in the very next render sequence if, for
      example, the window takes too long to respond to the proposed
      dimensions. In this case, the server will send the dimensions event in a
      future render sequence.
      
      Note that the dimensions of a river_window_v1 refer to the dimensions of
      the window content and are unaffected by the presence of borders or
      decoration surfaces.
      
      This request modifies window management state and may only be made as
      part of a manage sequence, see the river_window_manager_v1 description. *)
  let propose_dimensions (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) 
    ~width ~height =
    let _msg = Proxy.alloc _t ~op:3 ~ints:2 ~strings:[] ~arrays:[] in
    Msg.add_int _msg width;
    Msg.add_int _msg height;
    Proxy.send _t _msg
  
  (** Get the window's render list node.
      
      Get the node in the render list corresponding to the window.
      
      It is a protocol error to make this request more than once for a single
      window. *)
  let get_node (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) (id:([`River_node_v1], 'v, [`Client]) #Proxy.Handler.t) =
    let __id = Proxy.spawn _t id in
    let _msg = Proxy.alloc _t ~op:2 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id __id);
    Proxy.send _t _msg;
    __id
  
  (** Request that the window be closed.
      
      Request that the window be closed. The window may ignore this request or
      only close after some delay, perhaps opening a dialog asking the user to
      save their work or similar.
      
      The server will send a river_window_v1.closed event if/when the window
      has been closed.
      
      This request modifies window management state and may only be made as
      part of a manage sequence, see the river_window_manager_v1 description. *)
  let close (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:1 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (** Destroy the window object.
      
      This request indicates that the client will no longer use the window
      object and that it may be safely destroyed.
      
      This request should be made after the river_window_v1.closed event or
      river_window_manager_v1.finished is received to complete destruction of
      the window. *)
  let destroy (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:0 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg;
    Proxy.shutdown_send _t
  
  
  (** {2 Version 2} *)
  
  (** Clip the window to a given box.
      
      Clip the window, including borders and decoration surfaces, to the box
      specified by the x, y, width, and height arguments. The x/y position of
      the box is relative to the top left corner of the window.
      
      The width and height arguments must be greater than or equal to 0.
      
      Setting a clip box with 0 width or height disables clipping.
      
      The clip box is ignored while the window is fullscreen.
      
      Both set_clip_box and set_content_clip_box may be enabled simultaneously.
      
      This request modifies rendering state and may only be made as part of a
      render sequence, see the river_window_manager_v1 description. *)
  let set_clip_box (_t:([< `V2 | `V3 | `V4 | `V5] as 'v) t) ~x ~y ~width ~height =
    let _msg = Proxy.alloc _t ~op:21 ~ints:4 ~strings:[] ~arrays:[] in
    Msg.add_int _msg x;
    Msg.add_int _msg y;
    Msg.add_int _msg width;
    Msg.add_int _msg height;
    Proxy.send _t _msg
  
  
  (** {2 Version 3} *)
  
  (** Clip the window content to a given box.
      
      Clip the content of the window, excluding borders and decoration
      surfaces, to the box specified by the x, y, width, and height arguments.
      The x/y position of the box is relative to the top left corner of the
      window.
      
      Borders drawn by the compositor (see set_borders) are placed around the
      intersection of the window content (as defined by the dimensions event)
      and the content clip box when content clipping is enabled.
      
      The width and height arguments must be greater than or equal to 0.
      
      Setting a box with 0 width or height disables content clipping.
      
      The content clip box is ignored while the window is fullscreen.
      
      Both set_clip_box and set_content_clip_box may be enabled simultaneously.
      
      This request modifies rendering state and may only be made as part of a
      render sequence, see the river_window_manager_v1 description. *)
  let set_content_clip_box (_t:([< `V3 | `V4 | `V5] as 'v) t) ~x ~y ~width ~height =
    let _msg = Proxy.alloc _t ~op:22 ~ints:4 ~strings:[] ~arrays:[] in
    Msg.add_int _msg x;
    Msg.add_int _msg y;
    Msg.add_int _msg width;
    Msg.add_int _msg height;
    Proxy.send _t _msg
  
  
  (** {2 Version 4} *)
  
  (** Recommend maximum dimensions to the window.
      
      Recommend that the window keep its dimensions within a given
      maximum width/height. This recommendation is only a hint and the window
      may ignore it.
      
      Setting the width and height to 0 indicates that there are no bounds
      and is equivalent to having never made this request.
      
      Setting width or height to a negative value is a protocol error.
      
      The server should communicate this hint to an xdg_toplevel window with
      the xdg_toplevel.configure_bounds event for example.
      
      This request modifies window management state and may only be made as
      part of a manage sequence, see the river_window_manager_v1 description. *)
  let set_dimension_bounds (_t:([< `V4 | `V5] as 'v) t) ~max_width ~max_height =
    let _msg = Proxy.alloc _t ~op:23 ~ints:2 ~strings:[] ~arrays:[] in
    Msg.add_int _msg max_width;
    Msg.add_int _msg max_height;
    Proxy.send _t _msg
  
  
  (** {2 Version 5} *)
  
  (**/**)
  class virtual ['v] _handlers_unsafe = object (_self : (_, 'v, _) #Proxy.Handler.t)
    method user_data = S.No_data
    method metadata = (module River_window_management_v1_proto.River_window_v1)
    method max_version = 5l
    
    method private virtual on_closed : [> ] t -> unit
    
    method private virtual on_dimensions_hint : [> ] t -> min_width:int32 -> min_height:int32 -> max_width:int32 ->
                                                max_height:int32 -> unit
    
    method private virtual on_dimensions : [> ] t -> width:int32 -> height:int32 -> unit
    
    method private virtual on_app_id : [> ] t -> app_id:string option -> unit
    
    method private virtual on_title : [> ] t -> title:string option -> unit
    
    method private virtual on_parent : [> ] t -> parent:([`River_window_v1], [> Imports.River_window_v1.versions], [`Client]) Proxy.t option ->
                                       unit
    
    method private virtual on_decoration_hint : [> ] t -> hint:Imports.River_window_v1.Decoration_hint.t -> unit
    
    method private virtual on_pointer_move_requested : [> ] t -> seat:([`River_seat_v1], [> Imports.River_seat_v1.versions], [`Client]) Proxy.t ->
                                                       unit
    
    method private virtual on_pointer_resize_requested : [> ] t -> seat:([`River_seat_v1], [> Imports.River_seat_v1.versions], [`Client]) Proxy.t ->
                                                         edges:Imports.River_window_v1.Edges.t -> unit
    
    method private virtual on_show_window_menu_requested : [> ] t -> x:int32 -> y:int32 -> unit
    
    method private virtual on_maximize_requested : [> ] t -> unit
    
    method private virtual on_unmaximize_requested : [> ] t -> unit
    
    method private virtual on_fullscreen_requested : [> ] t -> output:([`River_output_v1], [> Imports.River_output_v1.versions], [`Client]) Proxy.t option ->
                                                     unit
    
    method private virtual on_exit_fullscreen_requested : [> ] t -> unit
    
    method private virtual on_minimize_requested : [> ] t -> unit
    
    method private virtual on_unreliable_pid : [> ] t -> unreliable_pid:int32 -> unit
    
    method private virtual on_presentation_hint : [> ] t -> hint:Imports.River_output_v1.Presentation_mode.t -> unit
    
    method private virtual on_identifier : [> ] t -> identifier:string -> unit
    
    method private virtual on_capture_sessions : [> ] t -> count:int32 -> unit
    
    
    method dispatch (_proxy : 'v t) _msg =
      let _proxy = Proxy.cast_version _proxy in
      match Msg.op _msg with
      | 0 ->
        _self#on_closed _proxy 
      | 1 ->
        let min_width = Msg.get_int _msg in
        let min_height = Msg.get_int _msg in
        let max_width = Msg.get_int _msg in
        let max_height = Msg.get_int _msg in
        _self#on_dimensions_hint _proxy ~min_width ~min_height ~max_width ~max_height
      | 2 ->
        let width = Msg.get_int _msg in
        let height = Msg.get_int _msg in
        _self#on_dimensions _proxy ~width ~height
      | 3 ->
        let app_id = Msg.get_string_opt _msg in
        _self#on_app_id _proxy ~app_id
      | 4 ->
        let title = Msg.get_string_opt _msg in
        _self#on_title _proxy ~title
      | 5 ->
        let parent : ([`River_window_v1], _, _) Proxy.t option =
          match Msg.get_int _msg with
          | 0l -> None
          | id ->
            let Proxy.Proxy p = Proxy.lookup_other _proxy id in
            match Proxy.ty p with
            | Imports.River_window_v1.T -> Some p
            | _ -> Proxy.wrong_type ~parent:_proxy ~expected:"river_window_v1" p
          in
        _self#on_parent _proxy ~parent
      | 6 ->
        let hint = Msg.get_int _msg |> Imports.River_window_v1.Decoration_hint.of_int32 in
        _self#on_decoration_hint _proxy ~hint
      | 7 ->
        let seat : ([`River_seat_v1], _, _) Proxy.t =
          let Proxy.Proxy p = Msg.get_int _msg |> Proxy.lookup_other _proxy in
          match Proxy.ty p with
          | Imports.River_seat_v1.T -> p
          | _ -> Proxy.wrong_type ~parent:_proxy ~expected:"river_seat_v1" p
          in
        _self#on_pointer_move_requested _proxy ~seat
      | 8 ->
        let seat : ([`River_seat_v1], _, _) Proxy.t =
          let Proxy.Proxy p = Msg.get_int _msg |> Proxy.lookup_other _proxy in
          match Proxy.ty p with
          | Imports.River_seat_v1.T -> p
          | _ -> Proxy.wrong_type ~parent:_proxy ~expected:"river_seat_v1" p
          in
        let edges = Msg.get_int _msg |> Imports.River_window_v1.Edges.of_int32 in
        _self#on_pointer_resize_requested _proxy ~seat ~edges
      | 9 ->
        let x = Msg.get_int _msg in
        let y = Msg.get_int _msg in
        _self#on_show_window_menu_requested _proxy ~x ~y
      | 10 ->
        _self#on_maximize_requested _proxy 
      | 11 ->
        _self#on_unmaximize_requested _proxy 
      | 12 ->
        let output : ([`River_output_v1], _, _) Proxy.t option =
          match Msg.get_int _msg with
          | 0l -> None
          | id ->
            let Proxy.Proxy p = Proxy.lookup_other _proxy id in
            match Proxy.ty p with
            | Imports.River_output_v1.T -> Some p
            | _ -> Proxy.wrong_type ~parent:_proxy ~expected:"river_output_v1" p
          in
        _self#on_fullscreen_requested _proxy ~output
      | 13 ->
        _self#on_exit_fullscreen_requested _proxy 
      | 14 ->
        _self#on_minimize_requested _proxy 
      | 15 ->
        let unreliable_pid = Msg.get_int _msg in
        _self#on_unreliable_pid _proxy ~unreliable_pid
      | 16 ->
        let hint = Msg.get_int _msg |> Imports.River_output_v1.Presentation_mode.of_int32 in
        _self#on_presentation_hint _proxy ~hint
      | 17 ->
        let identifier = Msg.get_string _msg in
        _self#on_identifier _proxy ~identifier
      | 18 ->
        let count = Msg.get_int _msg in
        _self#on_capture_sessions _proxy ~count
      | _ -> assert false
  end
  (**/**)
  
  (** {2 Handlers}
      Note: Servers will always want to use [v1].
   *)
  
  
  (** Handler for a proxy with version >= 1. *)
  class virtual ['v] v1 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V1 | `V2 | `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_closed : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** The window has been closed.
        
        The window has been closed by the server, perhaps due to an
        xdg_toplevel.close request or similar.
        
        The server will send no further events on this object and ignore any
        request other than river_window_v1.destroy made after this event is
        sent. The client should destroy this object with the
        river_window_v1.destroy request to free up resources.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_dimensions_hint : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> min_width:int32 ->
                                                min_height:int32 -> max_width:int32 -> max_height:int32 -> unit
    
    (** The window's preferred min/max dimensions.
        
        This event informs the window manager of the window's preferred min/max
        dimensions. These preferences are a hint, and the window manager is free
        to propose dimensions outside of these bounds.
        
        All min/max width/height values must be strictly greater than or equal
        to 0. A value of 0 indicates that the window has no preference for that
        value.
        
        If the max_width/max_height is greater than 0, the min_width/min_height
        must be strictly less than or equal to the max_width/max_height.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_dimensions : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> width:int32 -> height:int32 -> unit
    
    (** Window dimensions.
        
        This event indicates the dimensions of the window in the compositor's
        logical coordinate space. The width and height must be strictly greater
        than zero.
        
        Note that the dimensions of a river_window_v1 refer to the dimensions of
        the window content and are unaffected by the presence of borders or
        decoration surfaces.
        
        This event is sent as part of a render sequence before the render_start
        event.
        
        It may be sent due to a propose_dimensions or fullscreen request in a
        previous manage sequence or because a window independently decides to
        change its dimensions.
        
        The window will not be displayed until the first dimensions event is
        received and the render sequence is finished. *)
    
    method private virtual on_app_id : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> app_id:string option -> unit
    
    (** The window set an application ID.
        
        The window set an application ID.
        
        The app_id argument will be null if the window has never set an
        application ID or if the window cleared its application ID. (Xwayland
        windows may do this for example, though xdg-toplevels may not.)
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_title : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> title:string option -> unit
    
    (** The window set a title.
        
        The window set a title.
        
        The title argument will be null if the window has never set a title or
        if the window cleared its title. (Xwayland windows may do this for
        example, though xdg-toplevels may not.)
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_parent : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> parent:([`River_window_v1], [> Imports.River_window_v1.versions], [`Client]) Proxy.t option ->
                                       unit
    
    (** The window set a parent.
        
        The window set a parent window. If this event is never received or if
        the parent argument is null then the window has no parent.
        
        A surface with a parent set might be a dialog, file picker, or similar
        for the parent window.
        
        Child windows should generally be rendered directly above their parent.
        
        The compositor must guarantee that there are no loops in the window
        tree: a parent must not be the descendant of one of its children.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_decoration_hint : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> hint:Imports.River_window_v1.Decoration_hint.t ->
                                                unit
    
    (** Supported/preferred decoration style.
        
        Information from the window about the supported and preferred client
        side/server side decoration options.
        
        This event may be sent multiple times over the lifetime of the window if
        the window changes its preferences.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_pointer_move_requested : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> seat:([`River_seat_v1], [> Imports.River_seat_v1.versions], [`Client]) Proxy.t ->
                                                       unit
    
    (** Window requested interactive pointer move.
        
        This event informs the window manager that the window has requested to
        be interactively moved using the pointer. The seat argument indicates the
        seat for the move.
        
        The xdg-shell protocol for example allows windows to request that an
        interactive move be started, perhaps when a client-side rendered
        titlebar is dragged.
        
        The window manager may use the river_seat_v1.op_start_pointer request to
        interactively move the window or ignore this event entirely.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_pointer_resize_requested : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> seat:([`River_seat_v1], [> Imports.River_seat_v1.versions], [`Client]) Proxy.t ->
                                                         edges:Imports.River_window_v1.Edges.t -> unit
    
    (** Window requested interactive pointer resize.
        
        This event informs the window manager that the window has requested to
        be interactively resized using the pointer. The seat argument indicates
        the seat for the resize.
        
        The edges argument indicates which edges the window has requested to be
        resized from. The edges argument will never be none and will never have
        both top and bottom or both left and right edges set.
        
        The xdg-shell protocol for example allows windows to request that an
        interactive resize be started, perhaps when the corner of client-side
        rendered decorations is dragged.
        
        The window manager may use the river_seat_v1.op_start_pointer request to
        interactively resize the window or ignore this event entirely.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_show_window_menu_requested : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> x:int32 -> y:int32 ->
                                                           unit
    
    (** Window requested that the window menu be shown.
        
        The xdg-shell protocol for example allows windows to request that a
        window menu be shown, for example when the user right clicks on client
        side window decorations.
        
        A window menu might include options to maximize or minimize the window.
        
        The window manager is free to ignore this request and decide what the
        window menu contains if it does choose to show one.
        
        The x and y arguments indicate where the window requested that the
        window menu be shown.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_maximize_requested : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** The window requested to be maximized.
        
        The xdg-shell protocol for example allows windows to request to be
        maximized.
        
        The window manager is free to honor this request using
        river_window_v1.inform_maximized or ignore it.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_unmaximize_requested : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** The window requested to be unmaximized.
        
        The xdg-shell protocol for example allows windows to request to be
        unmaximized.
        
        The window manager is free to honor this request using
        river_window_v1.inform_unmaximized or ignore it.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_fullscreen_requested : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> output:([`River_output_v1], [> Imports.River_output_v1.versions], [`Client]) Proxy.t option ->
                                                     unit
    
    (** The window requested to be fullscreen.
        
        The xdg-shell protocol for example allows windows to request that they
        be made fullscreen and allows them to provide an optional output hint.
        
        If the output argument is null, the window has no preference and the
        window manager should choose an output.
        
        The window manager is free to honor this request using
        river_window_v1.fullscreen or ignore it.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_exit_fullscreen_requested : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** The window requested to exit fullscreen.
        
        The xdg-shell protocol for example allows windows to request to exit
        fullscreen.
        
        The window manager is free to honor this request using
        river_window_v1.exit_fullscreen or ignore it.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_minimize_requested : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** The window requested to be minimized.
        
        The xdg-shell protocol for example allows windows to request to be
        minimized.
        
        The window manager is free to ignore this request, hide the window, or
        do whatever else it chooses.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_unreliable_pid : [> `V2 | `V3 | `V4 | `V5] t -> unreliable_pid:int32 -> unit
    
    (** Unreliable PID of the window's creator.
        
        This event gives an unreliable PID of the process that created the
        window. Obtaining this information is inherently racy due to PID reuse.
        Therefore, this PID must not be used for anything security sensitive.
        
        Note also that a single process may create multiple windows, so there is
        not necessarily a 1-to-1 mapping from PID to window. Multiple windows
        may have the same PID.
        
        This event is sent once when the river_window_v1 is created and never
        sent again. *)
    
    method private virtual on_presentation_hint : [> `V4 | `V5] t -> hint:Imports.River_output_v1.Presentation_mode.t ->
                                                  unit
    
    (** Presentation hint set by the window.
        
        This event communicates the window's preferred presentation mode.
        
        This event will be followed by a render_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_identifier : [> `V4 | `V5] t -> identifier:string -> unit
    
    (** Unique window identifier.
        
        The identifier is a string that contains up to 32 printable ASCII bytes.
        The identifier must not be an empty string.
        
        It is compositor policy how the identifier is generated, but the following
        properties must be upheld:
        
        1. The identifier must uniquely identify the window. Two windows must not
        share the same identifier.
        
        2. The identifier must not be reused. This avoids races around window
        creation/destruction when identifiers are used in out-of-band IPC.
        
        If the compositor implements the ext-foreign-toplevel-list-v1 protocol,
        the river_window_v1.identifier event must match the corresponding
        ext_foreign_toplevel_handle_v1.identifier event.
        
        This event is sent once when the river_window_v1 is created and never
        sent again. *)
    
    method private virtual on_capture_sessions : [> `V5] t -> count:int32 -> unit
    
    (** Window screen capture sessions.
        
        This event informs the window manager of the number of active screen
        capture sessions for the window.
        
        This event is sent once when the river_window_v1 is created and again
        whenever the number of capture sessions changes.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method min_version = 1l
  end
  
  (** Handler for a proxy with version >= 2. *)
  class virtual ['v] v2 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V2 | `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_closed : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** The window has been closed.
        
        The window has been closed by the server, perhaps due to an
        xdg_toplevel.close request or similar.
        
        The server will send no further events on this object and ignore any
        request other than river_window_v1.destroy made after this event is
        sent. The client should destroy this object with the
        river_window_v1.destroy request to free up resources.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_dimensions_hint : [> `V2 | `V3 | `V4 | `V5] t -> min_width:int32 -> min_height:int32 ->
                                                max_width:int32 -> max_height:int32 -> unit
    
    (** The window's preferred min/max dimensions.
        
        This event informs the window manager of the window's preferred min/max
        dimensions. These preferences are a hint, and the window manager is free
        to propose dimensions outside of these bounds.
        
        All min/max width/height values must be strictly greater than or equal
        to 0. A value of 0 indicates that the window has no preference for that
        value.
        
        If the max_width/max_height is greater than 0, the min_width/min_height
        must be strictly less than or equal to the max_width/max_height.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_dimensions : [> `V2 | `V3 | `V4 | `V5] t -> width:int32 -> height:int32 -> unit
    
    (** Window dimensions.
        
        This event indicates the dimensions of the window in the compositor's
        logical coordinate space. The width and height must be strictly greater
        than zero.
        
        Note that the dimensions of a river_window_v1 refer to the dimensions of
        the window content and are unaffected by the presence of borders or
        decoration surfaces.
        
        This event is sent as part of a render sequence before the render_start
        event.
        
        It may be sent due to a propose_dimensions or fullscreen request in a
        previous manage sequence or because a window independently decides to
        change its dimensions.
        
        The window will not be displayed until the first dimensions event is
        received and the render sequence is finished. *)
    
    method private virtual on_app_id : [> `V2 | `V3 | `V4 | `V5] t -> app_id:string option -> unit
    
    (** The window set an application ID.
        
        The window set an application ID.
        
        The app_id argument will be null if the window has never set an
        application ID or if the window cleared its application ID. (Xwayland
        windows may do this for example, though xdg-toplevels may not.)
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_title : [> `V2 | `V3 | `V4 | `V5] t -> title:string option -> unit
    
    (** The window set a title.
        
        The window set a title.
        
        The title argument will be null if the window has never set a title or
        if the window cleared its title. (Xwayland windows may do this for
        example, though xdg-toplevels may not.)
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_parent : [> `V2 | `V3 | `V4 | `V5] t -> parent:([`River_window_v1], [> Imports.River_window_v1.versions], [`Client]) Proxy.t option ->
                                       unit
    
    (** The window set a parent.
        
        The window set a parent window. If this event is never received or if
        the parent argument is null then the window has no parent.
        
        A surface with a parent set might be a dialog, file picker, or similar
        for the parent window.
        
        Child windows should generally be rendered directly above their parent.
        
        The compositor must guarantee that there are no loops in the window
        tree: a parent must not be the descendant of one of its children.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_decoration_hint : [> `V2 | `V3 | `V4 | `V5] t -> hint:Imports.River_window_v1.Decoration_hint.t ->
                                                unit
    
    (** Supported/preferred decoration style.
        
        Information from the window about the supported and preferred client
        side/server side decoration options.
        
        This event may be sent multiple times over the lifetime of the window if
        the window changes its preferences.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_pointer_move_requested : [> `V2 | `V3 | `V4 | `V5] t -> seat:([`River_seat_v1], [> Imports.River_seat_v1.versions], [`Client]) Proxy.t ->
                                                       unit
    
    (** Window requested interactive pointer move.
        
        This event informs the window manager that the window has requested to
        be interactively moved using the pointer. The seat argument indicates the
        seat for the move.
        
        The xdg-shell protocol for example allows windows to request that an
        interactive move be started, perhaps when a client-side rendered
        titlebar is dragged.
        
        The window manager may use the river_seat_v1.op_start_pointer request to
        interactively move the window or ignore this event entirely.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_pointer_resize_requested : [> `V2 | `V3 | `V4 | `V5] t -> seat:([`River_seat_v1], [> Imports.River_seat_v1.versions], [`Client]) Proxy.t ->
                                                         edges:Imports.River_window_v1.Edges.t -> unit
    
    (** Window requested interactive pointer resize.
        
        This event informs the window manager that the window has requested to
        be interactively resized using the pointer. The seat argument indicates
        the seat for the resize.
        
        The edges argument indicates which edges the window has requested to be
        resized from. The edges argument will never be none and will never have
        both top and bottom or both left and right edges set.
        
        The xdg-shell protocol for example allows windows to request that an
        interactive resize be started, perhaps when the corner of client-side
        rendered decorations is dragged.
        
        The window manager may use the river_seat_v1.op_start_pointer request to
        interactively resize the window or ignore this event entirely.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_show_window_menu_requested : [> `V2 | `V3 | `V4 | `V5] t -> x:int32 -> y:int32 -> unit
    
    (** Window requested that the window menu be shown.
        
        The xdg-shell protocol for example allows windows to request that a
        window menu be shown, for example when the user right clicks on client
        side window decorations.
        
        A window menu might include options to maximize or minimize the window.
        
        The window manager is free to ignore this request and decide what the
        window menu contains if it does choose to show one.
        
        The x and y arguments indicate where the window requested that the
        window menu be shown.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_maximize_requested : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** The window requested to be maximized.
        
        The xdg-shell protocol for example allows windows to request to be
        maximized.
        
        The window manager is free to honor this request using
        river_window_v1.inform_maximized or ignore it.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_unmaximize_requested : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** The window requested to be unmaximized.
        
        The xdg-shell protocol for example allows windows to request to be
        unmaximized.
        
        The window manager is free to honor this request using
        river_window_v1.inform_unmaximized or ignore it.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_fullscreen_requested : [> `V2 | `V3 | `V4 | `V5] t -> output:([`River_output_v1], [> Imports.River_output_v1.versions], [`Client]) Proxy.t option ->
                                                     unit
    
    (** The window requested to be fullscreen.
        
        The xdg-shell protocol for example allows windows to request that they
        be made fullscreen and allows them to provide an optional output hint.
        
        If the output argument is null, the window has no preference and the
        window manager should choose an output.
        
        The window manager is free to honor this request using
        river_window_v1.fullscreen or ignore it.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_exit_fullscreen_requested : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** The window requested to exit fullscreen.
        
        The xdg-shell protocol for example allows windows to request to exit
        fullscreen.
        
        The window manager is free to honor this request using
        river_window_v1.exit_fullscreen or ignore it.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_minimize_requested : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** The window requested to be minimized.
        
        The xdg-shell protocol for example allows windows to request to be
        minimized.
        
        The window manager is free to ignore this request, hide the window, or
        do whatever else it chooses.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_unreliable_pid : [> `V2 | `V3 | `V4 | `V5] t -> unreliable_pid:int32 -> unit
    
    (** Unreliable PID of the window's creator.
        
        This event gives an unreliable PID of the process that created the
        window. Obtaining this information is inherently racy due to PID reuse.
        Therefore, this PID must not be used for anything security sensitive.
        
        Note also that a single process may create multiple windows, so there is
        not necessarily a 1-to-1 mapping from PID to window. Multiple windows
        may have the same PID.
        
        This event is sent once when the river_window_v1 is created and never
        sent again. *)
    
    method private virtual on_presentation_hint : [> `V4 | `V5] t -> hint:Imports.River_output_v1.Presentation_mode.t ->
                                                  unit
    
    (** Presentation hint set by the window.
        
        This event communicates the window's preferred presentation mode.
        
        This event will be followed by a render_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_identifier : [> `V4 | `V5] t -> identifier:string -> unit
    
    (** Unique window identifier.
        
        The identifier is a string that contains up to 32 printable ASCII bytes.
        The identifier must not be an empty string.
        
        It is compositor policy how the identifier is generated, but the following
        properties must be upheld:
        
        1. The identifier must uniquely identify the window. Two windows must not
        share the same identifier.
        
        2. The identifier must not be reused. This avoids races around window
        creation/destruction when identifiers are used in out-of-band IPC.
        
        If the compositor implements the ext-foreign-toplevel-list-v1 protocol,
        the river_window_v1.identifier event must match the corresponding
        ext_foreign_toplevel_handle_v1.identifier event.
        
        This event is sent once when the river_window_v1 is created and never
        sent again. *)
    
    method private virtual on_capture_sessions : [> `V5] t -> count:int32 -> unit
    
    (** Window screen capture sessions.
        
        This event informs the window manager of the number of active screen
        capture sessions for the window.
        
        This event is sent once when the river_window_v1 is created and again
        whenever the number of capture sessions changes.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method min_version = 2l
  end
  
  (** Handler for a proxy with version >= 3. *)
  class virtual ['v] v3 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_closed : [> `V3 | `V4 | `V5] t -> unit
    
    (** The window has been closed.
        
        The window has been closed by the server, perhaps due to an
        xdg_toplevel.close request or similar.
        
        The server will send no further events on this object and ignore any
        request other than river_window_v1.destroy made after this event is
        sent. The client should destroy this object with the
        river_window_v1.destroy request to free up resources.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_dimensions_hint : [> `V3 | `V4 | `V5] t -> min_width:int32 -> min_height:int32 ->
                                                max_width:int32 -> max_height:int32 -> unit
    
    (** The window's preferred min/max dimensions.
        
        This event informs the window manager of the window's preferred min/max
        dimensions. These preferences are a hint, and the window manager is free
        to propose dimensions outside of these bounds.
        
        All min/max width/height values must be strictly greater than or equal
        to 0. A value of 0 indicates that the window has no preference for that
        value.
        
        If the max_width/max_height is greater than 0, the min_width/min_height
        must be strictly less than or equal to the max_width/max_height.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_dimensions : [> `V3 | `V4 | `V5] t -> width:int32 -> height:int32 -> unit
    
    (** Window dimensions.
        
        This event indicates the dimensions of the window in the compositor's
        logical coordinate space. The width and height must be strictly greater
        than zero.
        
        Note that the dimensions of a river_window_v1 refer to the dimensions of
        the window content and are unaffected by the presence of borders or
        decoration surfaces.
        
        This event is sent as part of a render sequence before the render_start
        event.
        
        It may be sent due to a propose_dimensions or fullscreen request in a
        previous manage sequence or because a window independently decides to
        change its dimensions.
        
        The window will not be displayed until the first dimensions event is
        received and the render sequence is finished. *)
    
    method private virtual on_app_id : [> `V3 | `V4 | `V5] t -> app_id:string option -> unit
    
    (** The window set an application ID.
        
        The window set an application ID.
        
        The app_id argument will be null if the window has never set an
        application ID or if the window cleared its application ID. (Xwayland
        windows may do this for example, though xdg-toplevels may not.)
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_title : [> `V3 | `V4 | `V5] t -> title:string option -> unit
    
    (** The window set a title.
        
        The window set a title.
        
        The title argument will be null if the window has never set a title or
        if the window cleared its title. (Xwayland windows may do this for
        example, though xdg-toplevels may not.)
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_parent : [> `V3 | `V4 | `V5] t -> parent:([`River_window_v1], [> Imports.River_window_v1.versions], [`Client]) Proxy.t option ->
                                       unit
    
    (** The window set a parent.
        
        The window set a parent window. If this event is never received or if
        the parent argument is null then the window has no parent.
        
        A surface with a parent set might be a dialog, file picker, or similar
        for the parent window.
        
        Child windows should generally be rendered directly above their parent.
        
        The compositor must guarantee that there are no loops in the window
        tree: a parent must not be the descendant of one of its children.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_decoration_hint : [> `V3 | `V4 | `V5] t -> hint:Imports.River_window_v1.Decoration_hint.t ->
                                                unit
    
    (** Supported/preferred decoration style.
        
        Information from the window about the supported and preferred client
        side/server side decoration options.
        
        This event may be sent multiple times over the lifetime of the window if
        the window changes its preferences.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_pointer_move_requested : [> `V3 | `V4 | `V5] t -> seat:([`River_seat_v1], [> Imports.River_seat_v1.versions], [`Client]) Proxy.t ->
                                                       unit
    
    (** Window requested interactive pointer move.
        
        This event informs the window manager that the window has requested to
        be interactively moved using the pointer. The seat argument indicates the
        seat for the move.
        
        The xdg-shell protocol for example allows windows to request that an
        interactive move be started, perhaps when a client-side rendered
        titlebar is dragged.
        
        The window manager may use the river_seat_v1.op_start_pointer request to
        interactively move the window or ignore this event entirely.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_pointer_resize_requested : [> `V3 | `V4 | `V5] t -> seat:([`River_seat_v1], [> Imports.River_seat_v1.versions], [`Client]) Proxy.t ->
                                                         edges:Imports.River_window_v1.Edges.t -> unit
    
    (** Window requested interactive pointer resize.
        
        This event informs the window manager that the window has requested to
        be interactively resized using the pointer. The seat argument indicates
        the seat for the resize.
        
        The edges argument indicates which edges the window has requested to be
        resized from. The edges argument will never be none and will never have
        both top and bottom or both left and right edges set.
        
        The xdg-shell protocol for example allows windows to request that an
        interactive resize be started, perhaps when the corner of client-side
        rendered decorations is dragged.
        
        The window manager may use the river_seat_v1.op_start_pointer request to
        interactively resize the window or ignore this event entirely.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_show_window_menu_requested : [> `V3 | `V4 | `V5] t -> x:int32 -> y:int32 -> unit
    
    (** Window requested that the window menu be shown.
        
        The xdg-shell protocol for example allows windows to request that a
        window menu be shown, for example when the user right clicks on client
        side window decorations.
        
        A window menu might include options to maximize or minimize the window.
        
        The window manager is free to ignore this request and decide what the
        window menu contains if it does choose to show one.
        
        The x and y arguments indicate where the window requested that the
        window menu be shown.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_maximize_requested : [> `V3 | `V4 | `V5] t -> unit
    
    (** The window requested to be maximized.
        
        The xdg-shell protocol for example allows windows to request to be
        maximized.
        
        The window manager is free to honor this request using
        river_window_v1.inform_maximized or ignore it.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_unmaximize_requested : [> `V3 | `V4 | `V5] t -> unit
    
    (** The window requested to be unmaximized.
        
        The xdg-shell protocol for example allows windows to request to be
        unmaximized.
        
        The window manager is free to honor this request using
        river_window_v1.inform_unmaximized or ignore it.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_fullscreen_requested : [> `V3 | `V4 | `V5] t -> output:([`River_output_v1], [> Imports.River_output_v1.versions], [`Client]) Proxy.t option ->
                                                     unit
    
    (** The window requested to be fullscreen.
        
        The xdg-shell protocol for example allows windows to request that they
        be made fullscreen and allows them to provide an optional output hint.
        
        If the output argument is null, the window has no preference and the
        window manager should choose an output.
        
        The window manager is free to honor this request using
        river_window_v1.fullscreen or ignore it.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_exit_fullscreen_requested : [> `V3 | `V4 | `V5] t -> unit
    
    (** The window requested to exit fullscreen.
        
        The xdg-shell protocol for example allows windows to request to exit
        fullscreen.
        
        The window manager is free to honor this request using
        river_window_v1.exit_fullscreen or ignore it.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_minimize_requested : [> `V3 | `V4 | `V5] t -> unit
    
    (** The window requested to be minimized.
        
        The xdg-shell protocol for example allows windows to request to be
        minimized.
        
        The window manager is free to ignore this request, hide the window, or
        do whatever else it chooses.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_unreliable_pid : [> `V3 | `V4 | `V5] t -> unreliable_pid:int32 -> unit
    
    (** Unreliable PID of the window's creator.
        
        This event gives an unreliable PID of the process that created the
        window. Obtaining this information is inherently racy due to PID reuse.
        Therefore, this PID must not be used for anything security sensitive.
        
        Note also that a single process may create multiple windows, so there is
        not necessarily a 1-to-1 mapping from PID to window. Multiple windows
        may have the same PID.
        
        This event is sent once when the river_window_v1 is created and never
        sent again. *)
    
    method private virtual on_presentation_hint : [> `V4 | `V5] t -> hint:Imports.River_output_v1.Presentation_mode.t ->
                                                  unit
    
    (** Presentation hint set by the window.
        
        This event communicates the window's preferred presentation mode.
        
        This event will be followed by a render_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_identifier : [> `V4 | `V5] t -> identifier:string -> unit
    
    (** Unique window identifier.
        
        The identifier is a string that contains up to 32 printable ASCII bytes.
        The identifier must not be an empty string.
        
        It is compositor policy how the identifier is generated, but the following
        properties must be upheld:
        
        1. The identifier must uniquely identify the window. Two windows must not
        share the same identifier.
        
        2. The identifier must not be reused. This avoids races around window
        creation/destruction when identifiers are used in out-of-band IPC.
        
        If the compositor implements the ext-foreign-toplevel-list-v1 protocol,
        the river_window_v1.identifier event must match the corresponding
        ext_foreign_toplevel_handle_v1.identifier event.
        
        This event is sent once when the river_window_v1 is created and never
        sent again. *)
    
    method private virtual on_capture_sessions : [> `V5] t -> count:int32 -> unit
    
    (** Window screen capture sessions.
        
        This event informs the window manager of the number of active screen
        capture sessions for the window.
        
        This event is sent once when the river_window_v1 is created and again
        whenever the number of capture sessions changes.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method min_version = 3l
  end
  
  (** Handler for a proxy with version >= 4. *)
  class virtual ['v] v4 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_closed : [> `V4 | `V5] t -> unit
    
    (** The window has been closed.
        
        The window has been closed by the server, perhaps due to an
        xdg_toplevel.close request or similar.
        
        The server will send no further events on this object and ignore any
        request other than river_window_v1.destroy made after this event is
        sent. The client should destroy this object with the
        river_window_v1.destroy request to free up resources.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_dimensions_hint : [> `V4 | `V5] t -> min_width:int32 -> min_height:int32 ->
                                                max_width:int32 -> max_height:int32 -> unit
    
    (** The window's preferred min/max dimensions.
        
        This event informs the window manager of the window's preferred min/max
        dimensions. These preferences are a hint, and the window manager is free
        to propose dimensions outside of these bounds.
        
        All min/max width/height values must be strictly greater than or equal
        to 0. A value of 0 indicates that the window has no preference for that
        value.
        
        If the max_width/max_height is greater than 0, the min_width/min_height
        must be strictly less than or equal to the max_width/max_height.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_dimensions : [> `V4 | `V5] t -> width:int32 -> height:int32 -> unit
    
    (** Window dimensions.
        
        This event indicates the dimensions of the window in the compositor's
        logical coordinate space. The width and height must be strictly greater
        than zero.
        
        Note that the dimensions of a river_window_v1 refer to the dimensions of
        the window content and are unaffected by the presence of borders or
        decoration surfaces.
        
        This event is sent as part of a render sequence before the render_start
        event.
        
        It may be sent due to a propose_dimensions or fullscreen request in a
        previous manage sequence or because a window independently decides to
        change its dimensions.
        
        The window will not be displayed until the first dimensions event is
        received and the render sequence is finished. *)
    
    method private virtual on_app_id : [> `V4 | `V5] t -> app_id:string option -> unit
    
    (** The window set an application ID.
        
        The window set an application ID.
        
        The app_id argument will be null if the window has never set an
        application ID or if the window cleared its application ID. (Xwayland
        windows may do this for example, though xdg-toplevels may not.)
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_title : [> `V4 | `V5] t -> title:string option -> unit
    
    (** The window set a title.
        
        The window set a title.
        
        The title argument will be null if the window has never set a title or
        if the window cleared its title. (Xwayland windows may do this for
        example, though xdg-toplevels may not.)
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_parent : [> `V4 | `V5] t -> parent:([`River_window_v1], [> Imports.River_window_v1.versions], [`Client]) Proxy.t option ->
                                       unit
    
    (** The window set a parent.
        
        The window set a parent window. If this event is never received or if
        the parent argument is null then the window has no parent.
        
        A surface with a parent set might be a dialog, file picker, or similar
        for the parent window.
        
        Child windows should generally be rendered directly above their parent.
        
        The compositor must guarantee that there are no loops in the window
        tree: a parent must not be the descendant of one of its children.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_decoration_hint : [> `V4 | `V5] t -> hint:Imports.River_window_v1.Decoration_hint.t ->
                                                unit
    
    (** Supported/preferred decoration style.
        
        Information from the window about the supported and preferred client
        side/server side decoration options.
        
        This event may be sent multiple times over the lifetime of the window if
        the window changes its preferences.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_pointer_move_requested : [> `V4 | `V5] t -> seat:([`River_seat_v1], [> Imports.River_seat_v1.versions], [`Client]) Proxy.t ->
                                                       unit
    
    (** Window requested interactive pointer move.
        
        This event informs the window manager that the window has requested to
        be interactively moved using the pointer. The seat argument indicates the
        seat for the move.
        
        The xdg-shell protocol for example allows windows to request that an
        interactive move be started, perhaps when a client-side rendered
        titlebar is dragged.
        
        The window manager may use the river_seat_v1.op_start_pointer request to
        interactively move the window or ignore this event entirely.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_pointer_resize_requested : [> `V4 | `V5] t -> seat:([`River_seat_v1], [> Imports.River_seat_v1.versions], [`Client]) Proxy.t ->
                                                         edges:Imports.River_window_v1.Edges.t -> unit
    
    (** Window requested interactive pointer resize.
        
        This event informs the window manager that the window has requested to
        be interactively resized using the pointer. The seat argument indicates
        the seat for the resize.
        
        The edges argument indicates which edges the window has requested to be
        resized from. The edges argument will never be none and will never have
        both top and bottom or both left and right edges set.
        
        The xdg-shell protocol for example allows windows to request that an
        interactive resize be started, perhaps when the corner of client-side
        rendered decorations is dragged.
        
        The window manager may use the river_seat_v1.op_start_pointer request to
        interactively resize the window or ignore this event entirely.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_show_window_menu_requested : [> `V4 | `V5] t -> x:int32 -> y:int32 -> unit
    
    (** Window requested that the window menu be shown.
        
        The xdg-shell protocol for example allows windows to request that a
        window menu be shown, for example when the user right clicks on client
        side window decorations.
        
        A window menu might include options to maximize or minimize the window.
        
        The window manager is free to ignore this request and decide what the
        window menu contains if it does choose to show one.
        
        The x and y arguments indicate where the window requested that the
        window menu be shown.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_maximize_requested : [> `V4 | `V5] t -> unit
    
    (** The window requested to be maximized.
        
        The xdg-shell protocol for example allows windows to request to be
        maximized.
        
        The window manager is free to honor this request using
        river_window_v1.inform_maximized or ignore it.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_unmaximize_requested : [> `V4 | `V5] t -> unit
    
    (** The window requested to be unmaximized.
        
        The xdg-shell protocol for example allows windows to request to be
        unmaximized.
        
        The window manager is free to honor this request using
        river_window_v1.inform_unmaximized or ignore it.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_fullscreen_requested : [> `V4 | `V5] t -> output:([`River_output_v1], [> Imports.River_output_v1.versions], [`Client]) Proxy.t option ->
                                                     unit
    
    (** The window requested to be fullscreen.
        
        The xdg-shell protocol for example allows windows to request that they
        be made fullscreen and allows them to provide an optional output hint.
        
        If the output argument is null, the window has no preference and the
        window manager should choose an output.
        
        The window manager is free to honor this request using
        river_window_v1.fullscreen or ignore it.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_exit_fullscreen_requested : [> `V4 | `V5] t -> unit
    
    (** The window requested to exit fullscreen.
        
        The xdg-shell protocol for example allows windows to request to exit
        fullscreen.
        
        The window manager is free to honor this request using
        river_window_v1.exit_fullscreen or ignore it.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_minimize_requested : [> `V4 | `V5] t -> unit
    
    (** The window requested to be minimized.
        
        The xdg-shell protocol for example allows windows to request to be
        minimized.
        
        The window manager is free to ignore this request, hide the window, or
        do whatever else it chooses.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_unreliable_pid : [> `V4 | `V5] t -> unreliable_pid:int32 -> unit
    
    (** Unreliable PID of the window's creator.
        
        This event gives an unreliable PID of the process that created the
        window. Obtaining this information is inherently racy due to PID reuse.
        Therefore, this PID must not be used for anything security sensitive.
        
        Note also that a single process may create multiple windows, so there is
        not necessarily a 1-to-1 mapping from PID to window. Multiple windows
        may have the same PID.
        
        This event is sent once when the river_window_v1 is created and never
        sent again. *)
    
    method private virtual on_presentation_hint : [> `V4 | `V5] t -> hint:Imports.River_output_v1.Presentation_mode.t ->
                                                  unit
    
    (** Presentation hint set by the window.
        
        This event communicates the window's preferred presentation mode.
        
        This event will be followed by a render_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_identifier : [> `V4 | `V5] t -> identifier:string -> unit
    
    (** Unique window identifier.
        
        The identifier is a string that contains up to 32 printable ASCII bytes.
        The identifier must not be an empty string.
        
        It is compositor policy how the identifier is generated, but the following
        properties must be upheld:
        
        1. The identifier must uniquely identify the window. Two windows must not
        share the same identifier.
        
        2. The identifier must not be reused. This avoids races around window
        creation/destruction when identifiers are used in out-of-band IPC.
        
        If the compositor implements the ext-foreign-toplevel-list-v1 protocol,
        the river_window_v1.identifier event must match the corresponding
        ext_foreign_toplevel_handle_v1.identifier event.
        
        This event is sent once when the river_window_v1 is created and never
        sent again. *)
    
    method private virtual on_capture_sessions : [> `V5] t -> count:int32 -> unit
    
    (** Window screen capture sessions.
        
        This event informs the window manager of the number of active screen
        capture sessions for the window.
        
        This event is sent once when the river_window_v1 is created and again
        whenever the number of capture sessions changes.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method min_version = 4l
  end
  
  (** Handler for a proxy with version >= 5. *)
  class virtual ['v] v5 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_closed : [> `V5] t -> unit
    
    (** The window has been closed.
        
        The window has been closed by the server, perhaps due to an
        xdg_toplevel.close request or similar.
        
        The server will send no further events on this object and ignore any
        request other than river_window_v1.destroy made after this event is
        sent. The client should destroy this object with the
        river_window_v1.destroy request to free up resources.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_dimensions_hint : [> `V5] t -> min_width:int32 -> min_height:int32 -> max_width:int32 ->
                                                max_height:int32 -> unit
    
    (** The window's preferred min/max dimensions.
        
        This event informs the window manager of the window's preferred min/max
        dimensions. These preferences are a hint, and the window manager is free
        to propose dimensions outside of these bounds.
        
        All min/max width/height values must be strictly greater than or equal
        to 0. A value of 0 indicates that the window has no preference for that
        value.
        
        If the max_width/max_height is greater than 0, the min_width/min_height
        must be strictly less than or equal to the max_width/max_height.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_dimensions : [> `V5] t -> width:int32 -> height:int32 -> unit
    
    (** Window dimensions.
        
        This event indicates the dimensions of the window in the compositor's
        logical coordinate space. The width and height must be strictly greater
        than zero.
        
        Note that the dimensions of a river_window_v1 refer to the dimensions of
        the window content and are unaffected by the presence of borders or
        decoration surfaces.
        
        This event is sent as part of a render sequence before the render_start
        event.
        
        It may be sent due to a propose_dimensions or fullscreen request in a
        previous manage sequence or because a window independently decides to
        change its dimensions.
        
        The window will not be displayed until the first dimensions event is
        received and the render sequence is finished. *)
    
    method private virtual on_app_id : [> `V5] t -> app_id:string option -> unit
    
    (** The window set an application ID.
        
        The window set an application ID.
        
        The app_id argument will be null if the window has never set an
        application ID or if the window cleared its application ID. (Xwayland
        windows may do this for example, though xdg-toplevels may not.)
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_title : [> `V5] t -> title:string option -> unit
    
    (** The window set a title.
        
        The window set a title.
        
        The title argument will be null if the window has never set a title or
        if the window cleared its title. (Xwayland windows may do this for
        example, though xdg-toplevels may not.)
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_parent : [> `V5] t -> parent:([`River_window_v1], [> Imports.River_window_v1.versions], [`Client]) Proxy.t option ->
                                       unit
    
    (** The window set a parent.
        
        The window set a parent window. If this event is never received or if
        the parent argument is null then the window has no parent.
        
        A surface with a parent set might be a dialog, file picker, or similar
        for the parent window.
        
        Child windows should generally be rendered directly above their parent.
        
        The compositor must guarantee that there are no loops in the window
        tree: a parent must not be the descendant of one of its children.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_decoration_hint : [> `V5] t -> hint:Imports.River_window_v1.Decoration_hint.t -> unit
    
    (** Supported/preferred decoration style.
        
        Information from the window about the supported and preferred client
        side/server side decoration options.
        
        This event may be sent multiple times over the lifetime of the window if
        the window changes its preferences.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_pointer_move_requested : [> `V5] t -> seat:([`River_seat_v1], [> Imports.River_seat_v1.versions], [`Client]) Proxy.t ->
                                                       unit
    
    (** Window requested interactive pointer move.
        
        This event informs the window manager that the window has requested to
        be interactively moved using the pointer. The seat argument indicates the
        seat for the move.
        
        The xdg-shell protocol for example allows windows to request that an
        interactive move be started, perhaps when a client-side rendered
        titlebar is dragged.
        
        The window manager may use the river_seat_v1.op_start_pointer request to
        interactively move the window or ignore this event entirely.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_pointer_resize_requested : [> `V5] t -> seat:([`River_seat_v1], [> Imports.River_seat_v1.versions], [`Client]) Proxy.t ->
                                                         edges:Imports.River_window_v1.Edges.t -> unit
    
    (** Window requested interactive pointer resize.
        
        This event informs the window manager that the window has requested to
        be interactively resized using the pointer. The seat argument indicates
        the seat for the resize.
        
        The edges argument indicates which edges the window has requested to be
        resized from. The edges argument will never be none and will never have
        both top and bottom or both left and right edges set.
        
        The xdg-shell protocol for example allows windows to request that an
        interactive resize be started, perhaps when the corner of client-side
        rendered decorations is dragged.
        
        The window manager may use the river_seat_v1.op_start_pointer request to
        interactively resize the window or ignore this event entirely.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_show_window_menu_requested : [> `V5] t -> x:int32 -> y:int32 -> unit
    
    (** Window requested that the window menu be shown.
        
        The xdg-shell protocol for example allows windows to request that a
        window menu be shown, for example when the user right clicks on client
        side window decorations.
        
        A window menu might include options to maximize or minimize the window.
        
        The window manager is free to ignore this request and decide what the
        window menu contains if it does choose to show one.
        
        The x and y arguments indicate where the window requested that the
        window menu be shown.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_maximize_requested : [> `V5] t -> unit
    
    (** The window requested to be maximized.
        
        The xdg-shell protocol for example allows windows to request to be
        maximized.
        
        The window manager is free to honor this request using
        river_window_v1.inform_maximized or ignore it.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_unmaximize_requested : [> `V5] t -> unit
    
    (** The window requested to be unmaximized.
        
        The xdg-shell protocol for example allows windows to request to be
        unmaximized.
        
        The window manager is free to honor this request using
        river_window_v1.inform_unmaximized or ignore it.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_fullscreen_requested : [> `V5] t -> output:([`River_output_v1], [> Imports.River_output_v1.versions], [`Client]) Proxy.t option ->
                                                     unit
    
    (** The window requested to be fullscreen.
        
        The xdg-shell protocol for example allows windows to request that they
        be made fullscreen and allows them to provide an optional output hint.
        
        If the output argument is null, the window has no preference and the
        window manager should choose an output.
        
        The window manager is free to honor this request using
        river_window_v1.fullscreen or ignore it.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_exit_fullscreen_requested : [> `V5] t -> unit
    
    (** The window requested to exit fullscreen.
        
        The xdg-shell protocol for example allows windows to request to exit
        fullscreen.
        
        The window manager is free to honor this request using
        river_window_v1.exit_fullscreen or ignore it.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_minimize_requested : [> `V5] t -> unit
    
    (** The window requested to be minimized.
        
        The xdg-shell protocol for example allows windows to request to be
        minimized.
        
        The window manager is free to ignore this request, hide the window, or
        do whatever else it chooses.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_unreliable_pid : [> `V5] t -> unreliable_pid:int32 -> unit
    
    (** Unreliable PID of the window's creator.
        
        This event gives an unreliable PID of the process that created the
        window. Obtaining this information is inherently racy due to PID reuse.
        Therefore, this PID must not be used for anything security sensitive.
        
        Note also that a single process may create multiple windows, so there is
        not necessarily a 1-to-1 mapping from PID to window. Multiple windows
        may have the same PID.
        
        This event is sent once when the river_window_v1 is created and never
        sent again. *)
    
    method private virtual on_presentation_hint : [> `V5] t -> hint:Imports.River_output_v1.Presentation_mode.t -> unit
    
    (** Presentation hint set by the window.
        
        This event communicates the window's preferred presentation mode.
        
        This event will be followed by a render_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_identifier : [> `V5] t -> identifier:string -> unit
    
    (** Unique window identifier.
        
        The identifier is a string that contains up to 32 printable ASCII bytes.
        The identifier must not be an empty string.
        
        It is compositor policy how the identifier is generated, but the following
        properties must be upheld:
        
        1. The identifier must uniquely identify the window. Two windows must not
        share the same identifier.
        
        2. The identifier must not be reused. This avoids races around window
        creation/destruction when identifiers are used in out-of-band IPC.
        
        If the compositor implements the ext-foreign-toplevel-list-v1 protocol,
        the river_window_v1.identifier event must match the corresponding
        ext_foreign_toplevel_handle_v1.identifier event.
        
        This event is sent once when the river_window_v1 is created and never
        sent again. *)
    
    method private virtual on_capture_sessions : [> `V5] t -> count:int32 -> unit
    
    (** Window screen capture sessions.
        
        This event informs the window manager of the number of active screen
        capture sessions for the window.
        
        This event is sent once when the river_window_v1 is created and again
        whenever the number of capture sessions changes.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method min_version = 5l
  end
end

(** A window decoration.
    
    The rendering order of windows with decorations is follows:
    
    1. Decorations created with get_decoration_below at the bottom
    2. Window content
    3. Borders configured with river_window_v1.set_borders
    4. Decorations created with get_decoration_above at the top
    
    The relative ordering of decoration surfaces above/below a window is
    undefined by this protocol and left up to the compositor. *)
module River_decoration_v1 = struct
  type 'v t = ([`River_decoration_v1], 'v, [`Client]) Proxy.t
  module Error = River_window_management_v1_proto.River_decoration_v1.Error
  
  (** {2 Version 1, 2, 3, 4, 5} *)
  
  (** Sync next commit with other rendering state.
      
      Synchronize application of the next wl_surface.commit request on the
      decoration surface with rest of the state atomically applied with the
      next river_window_manager_v1.render_finish request.
      
      The client must make a wl_surface.commit request on the decoration
      surface after this request and before the render_finish request, failure
      to do so is a protocol error.
      
      This request modifies rendering state and may only be made as part of a
      render sequence, see the river_window_manager_v1 description. *)
  let sync_next_commit (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) 
     =
    let _msg = Proxy.alloc _t ~op:2 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (** Set offset from the window's top left corner.
      
      This request sets the offset of the decoration surface from the top left
      corner of the window.
      
      If this request is never sent, the x and y offsets are undefined by this
      protocol and left up to the compositor.
      
      This request modifies rendering state and may only be made as part of a
      render sequence, see the river_window_manager_v1 description. *)
  let set_offset (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) ~x ~y =
    let _msg = Proxy.alloc _t ~op:1 ~ints:2 ~strings:[] ~arrays:[] in
    Msg.add_int _msg x;
    Msg.add_int _msg y;
    Proxy.send _t _msg
  
  (** Destroy the decoration object.
      
      This request indicates that the client will no longer use the decoration
      object and that it may be safely destroyed. *)
  let destroy (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:0 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg;
    Proxy.shutdown_send _t
  
  (**/**)
  class ['v] _handlers_unsafe = object (_self : (_, 'v, _) #Proxy.Handler.t)
    method user_data = S.No_data
    method metadata = (module River_window_management_v1_proto.River_decoration_v1)
    method max_version = 5l
    
    
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
    inherit [[< `V1 | `V2 | `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method min_version = 1l
  end
  
  (** Handler for a proxy with version >= 2. *)
  class ['v] v2 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V2 | `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method min_version = 2l
  end
  
  (** Handler for a proxy with version >= 3. *)
  class ['v] v3 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method min_version = 3l
  end
  
  (** Handler for a proxy with version >= 4. *)
  class ['v] v4 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method min_version = 4l
  end
  
  (** Handler for a proxy with version >= 5. *)
  class ['v] v5 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V5] as 'v] _handlers_unsafe
    (**/**)
    method min_version = 5l
  end
end

(** A surface for window manager UI.
    
    The window manager might use a shell surface to display a status bar,
    background image, desktop notifications, launcher, desktop menu, or
    whatever else it wants. *)
module River_shell_surface_v1 = struct
  type 'v t = ([`River_shell_surface_v1], 'v, [`Client]) Proxy.t
  module Error = River_window_management_v1_proto.River_shell_surface_v1.Error
  
  (** {2 Version 1, 2, 3, 4, 5} *)
  
  (** Sync next surface commit to window manager commit.
      
      Synchronize application of the next wl_surface.commit request on the
      shell surface with rest of the rendering state atomically applied with
      the next river_window_manager_v1.render_finish request.
      
      The client must make a wl_surface.commit request on the shell surface
      after this request and before the render_finish request, failure to do
      so is a protocol error.
      
      This request modifies rendering state and may only be made as part of a
      render sequence, see the river_window_manager_v1 description. *)
  let sync_next_commit (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) 
     =
    let _msg = Proxy.alloc _t ~op:2 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (** Get the shell surface's render list node.
      
      Get the node in the render list corresponding to the shell surface.
      
      It is a protocol error to make this request more than once for a single
      shell surface. *)
  let get_node (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) (id:([`River_node_v1], 'v, [`Client]) #Proxy.Handler.t) =
    let __id = Proxy.spawn _t id in
    let _msg = Proxy.alloc _t ~op:1 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id __id);
    Proxy.send _t _msg;
    __id
  
  (** Destroy the shell surface object.
      
      This request indicates that the client will no longer use the shell
      surface object and that it may be safely destroyed. *)
  let destroy (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:0 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg;
    Proxy.shutdown_send _t
  
  (**/**)
  class ['v] _handlers_unsafe = object (_self : (_, 'v, _) #Proxy.Handler.t)
    method user_data = S.No_data
    method metadata = (module River_window_management_v1_proto.River_shell_surface_v1)
    method max_version = 5l
    
    
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
    inherit [[< `V1 | `V2 | `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method min_version = 1l
  end
  
  (** Handler for a proxy with version >= 2. *)
  class ['v] v2 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V2 | `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method min_version = 2l
  end
  
  (** Handler for a proxy with version >= 3. *)
  class ['v] v3 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method min_version = 3l
  end
  
  (** Handler for a proxy with version >= 4. *)
  class ['v] v4 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method min_version = 4l
  end
  
  (** Handler for a proxy with version >= 5. *)
  class ['v] v5 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V5] as 'v] _handlers_unsafe
    (**/**)
    method min_version = 5l
  end
end

(** A node in the render list.
    
    The render list is a list of nodes that determines the rendering order of
    the compositor. Nodes may correspond to windows or shell surfaces. The
    relative ordering of nodes may be changed with the place_above and
    place_below requests, changing the rendering order.
    
    The initial position of a node in the render list is undefined, the window
    manager client must use the place_above or place_below request to
    guarantee a specific rendering order. *)
module River_node_v1 = struct
  type 'v t = ([`River_node_v1], 'v, [`Client]) Proxy.t
  
  (** {2 Version 1, 2, 3, 4, 5} *)
  
  (** Place node below another node.
      
      This request places the node directly below another node in the
      compositor's render list.
      
      Attempting to place a node below itself has no effect.
      
      Given nodes A, B, C currently rendered in that order with C on top
      and A on the bottom, the following example demonstrates the behavior
      of this request and the meaning of "directly below":
      
      1. C.place_below(A) -> C, A, B
      2. C.place_below(B) -> A, C, B
      3. B.place_below(C) -> A, B, C
      
      This request modifies rendering state and may only be made as part of a
      render sequence, see the river_window_manager_v1 description. *)
  let place_below (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) ~(other:([`River_node_v1], _, [`Client]) Proxy.t) =
    let _msg = Proxy.alloc _t ~op:5 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id other);
    Proxy.send _t _msg
  
  (** Place node above another node.
      
      This request places the node directly above another node in the
      compositor's render list.
      
      Attempting to place a node above itself has no effect.
      
      Given nodes A, B, C currently rendered in that order with C on top
      and A on the bottom, the following example demonstrates the behavior
      of this request and the meaning of "directly above":
      
      1. A.place_above(C) -> B, C, A
      2. A.place_above(B) -> B, A, C
      3. B.place_above(A) -> A, B, C
      
      This request modifies rendering state and may only be made as part of a
      render sequence, see the river_window_manager_v1 description. *)
  let place_above (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) ~(other:([`River_node_v1], _, [`Client]) Proxy.t) =
    let _msg = Proxy.alloc _t ~op:4 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id other);
    Proxy.send _t _msg
  
  (** Place node below all other nodes.
      
      This request places the node below all other nodes in the compositor's
      render list.
      
      This request modifies rendering state and may only be made as part of a
      render sequence, see the river_window_manager_v1 description. *)
  let place_bottom (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:3 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (** Place node above all other nodes.
      
      This request places the node above all other nodes in the compositor's
      render list.
      
      This request modifies rendering state and may only be made as part of a
      render sequence, see the river_window_manager_v1 description. *)
  let place_top (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:2 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (** Set absolute position of the node.
      
      Set the absolute position of the node in the compositor's logical
      coordinate space. The x and y coordinates may be positive or negative.
      
      Note that the position of a river_window_v1 refers to the position of
      the window content and is unaffected by the presence of borders or
      decoration surfaces.
      
      If this request is never sent, the position of the node is undefined by
      this protocol and left up to the compositor.
      
      This request modifies rendering state and may only be made as part of a
      render sequence, see the river_window_manager_v1 description. *)
  let set_position (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) ~x ~y =
    let _msg = Proxy.alloc _t ~op:1 ~ints:2 ~strings:[] ~arrays:[] in
    Msg.add_int _msg x;
    Msg.add_int _msg y;
    Proxy.send _t _msg
  
  (** Destroy the decoration object.
      
      This request indicates that the client will no longer use the node
      object and that it may be safely destroyed. *)
  let destroy (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:0 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg;
    Proxy.shutdown_send _t
  
  (**/**)
  class ['v] _handlers_unsafe = object (_self : (_, 'v, _) #Proxy.Handler.t)
    method user_data = S.No_data
    method metadata = (module River_window_management_v1_proto.River_node_v1)
    method max_version = 5l
    
    
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
    inherit [[< `V1 | `V2 | `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method min_version = 1l
  end
  
  (** Handler for a proxy with version >= 2. *)
  class ['v] v2 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V2 | `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method min_version = 2l
  end
  
  (** Handler for a proxy with version >= 3. *)
  class ['v] v3 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method min_version = 3l
  end
  
  (** Handler for a proxy with version >= 4. *)
  class ['v] v4 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method min_version = 4l
  end
  
  (** Handler for a proxy with version >= 5. *)
  class ['v] v5 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V5] as 'v] _handlers_unsafe
    (**/**)
    method min_version = 5l
  end
end

(** A logical output.
    
    An area in the compositor's logical coordinate space that should be
    treated as a single output for window management purposes. This area may
    correspond to a single physical output or multiple physical outputs in the
    case of mirroring or tiled monitors depending on the hardware and
    compositor configuration. *)
module River_output_v1 = struct
  type 'v t = ([`River_output_v1], 'v, [`Client]) Proxy.t
  module Error = River_window_management_v1_proto.River_output_v1.Error
  
  module Presentation_mode = River_window_management_v1_proto.River_output_v1.Presentation_mode
  
  (** {2 Version 1, 2, 3} *)
  
  (** Destroy the output object.
      
      This request indicates that the client will no longer use the output
      object and that it may be safely destroyed.
      
      This request should be made after the river_output_v1.removed event is
      received to complete destruction of the output. *)
  let destroy (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:0 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg;
    Proxy.shutdown_send _t
  
  
  (** {2 Version 4} *)
  
  (** Set the preferred presentation mode.
      
      Set the preferred presentation mode of the output. The compositor should
      always respect the preference of the window manager if possible. If this
      request is never made, the preferred presentation mode is vsync.
      
      This request modifies rendering state and may only be made as part of a
      render sequence, see the river_window_manager_v1 description. *)
  let set_presentation_mode (_t:([< `V4 | `V5] as 'v) t) ~mode =
    let _msg = Proxy.alloc _t ~op:1 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Imports.River_output_v1.Presentation_mode.to_int32 mode);
    Proxy.send _t _msg
  
  
  (** {2 Version 5} *)
  
  (**/**)
  class virtual ['v] _handlers_unsafe = object (_self : (_, 'v, _) #Proxy.Handler.t)
    method user_data = S.No_data
    method metadata = (module River_window_management_v1_proto.River_output_v1)
    method max_version = 5l
    
    method private virtual on_removed : [> ] t -> unit
    
    method private virtual on_wl_output : [> ] t -> name:int32 -> unit
    
    method private virtual on_position : [> ] t -> x:int32 -> y:int32 -> unit
    
    method private virtual on_dimensions : [> ] t -> width:int32 -> height:int32 -> unit
    
    method private virtual on_capture_sessions : [> ] t -> count:int32 -> unit
    
    
    method dispatch (_proxy : 'v t) _msg =
      let _proxy = Proxy.cast_version _proxy in
      match Msg.op _msg with
      | 0 ->
        _self#on_removed _proxy 
      | 1 ->
        let name = Msg.get_int _msg in
        _self#on_wl_output _proxy ~name
      | 2 ->
        let x = Msg.get_int _msg in
        let y = Msg.get_int _msg in
        _self#on_position _proxy ~x ~y
      | 3 ->
        let width = Msg.get_int _msg in
        let height = Msg.get_int _msg in
        _self#on_dimensions _proxy ~width ~height
      | 4 ->
        let count = Msg.get_int _msg in
        _self#on_capture_sessions _proxy ~count
      | _ -> assert false
  end
  (**/**)
  
  (** {2 Handlers}
      Note: Servers will always want to use [v1].
   *)
  
  
  (** Handler for a proxy with version >= 1. *)
  class virtual ['v] v1 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V1 | `V2 | `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_removed : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** The output is removed.
        
        This event indicates that the logical output is no longer conceptually
        part of window management space.
        
        The server will send no further events on this object and ignore any
        request (other than river_output_v1.destroy) made after this event is
        sent. The client should destroy this object with the
        river_output_v1.destroy request to free up resources.
        
        This event may be sent because a corresponding physical output has been
        physically unplugged or because some output configuration has changed.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_wl_output : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> name:int32 -> unit
    
    (** Corresponding wl_output.
        
        The wl_output object corresponding to the river_output_v1. The argument
        is the global name of the wl_output advertised with wl_registry.global.
        
        It is guaranteed that the corresponding wl_output is advertised before
        this event is sent.
        
        This event is sent exactly once. The wl_output associated with a
        river_output_v1 cannot change. It is guaranteed that there is a 1-to-1
        mapping between wl_output and river_output_v1 objects.
        
        The global_remove event for the corresponding wl_output may be sent
        before the river_output_v1.removed event. This is due to the fact that
        river_output_v1 state changes are synced to the river window management
        manage sequence while changes to globals are not.
        
        Rationale: The window manager may need information provided by the
        wl_output interface such as the name/description. It also may need the
        wl_output object to start screencopy for example. *)
    
    method private virtual on_position : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> x:int32 -> y:int32 -> unit
    
    (** Output position.
        
        This event indicates the position of the output in the compositor's
        logical coordinate space. The x and y coordinates may be positive or
        negative.
        
        This event is sent once when the river_output_v1 is created and again
        whenever the position changes.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server.
        
        The server must guarantee that the position and dimensions events do not
        cause the areas of multiple logical outputs to overlap when the
        corresponding manage_start event is received. *)
    
    method private virtual on_dimensions : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> width:int32 -> height:int32 -> unit
    
    (** Output dimensions.
        
        This event indicates the dimensions of the output in the compositor's
        logical coordinate space. The width and height will always be strictly
        greater than zero.
        
        This event is sent once when the river_output_v1 is created and again
        whenever the dimensions change.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server.
        
        The server must guarantee that the position and dimensions events do not
        cause the areas of multiple logical outputs to overlap when the
        corresponding manage_start event is received. *)
    
    method private virtual on_capture_sessions : [> `V5] t -> count:int32 -> unit
    
    (** Output screen capture sessions.
        
        This event informs the window manager of the number of active screen
        capture sessions for the output.
        
        This event is sent once when the river_output_v1 is created and again
        whenever the number of capture sessions changes.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method min_version = 1l
  end
  
  (** Handler for a proxy with version >= 2. *)
  class virtual ['v] v2 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V2 | `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_removed : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** The output is removed.
        
        This event indicates that the logical output is no longer conceptually
        part of window management space.
        
        The server will send no further events on this object and ignore any
        request (other than river_output_v1.destroy) made after this event is
        sent. The client should destroy this object with the
        river_output_v1.destroy request to free up resources.
        
        This event may be sent because a corresponding physical output has been
        physically unplugged or because some output configuration has changed.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_wl_output : [> `V2 | `V3 | `V4 | `V5] t -> name:int32 -> unit
    
    (** Corresponding wl_output.
        
        The wl_output object corresponding to the river_output_v1. The argument
        is the global name of the wl_output advertised with wl_registry.global.
        
        It is guaranteed that the corresponding wl_output is advertised before
        this event is sent.
        
        This event is sent exactly once. The wl_output associated with a
        river_output_v1 cannot change. It is guaranteed that there is a 1-to-1
        mapping between wl_output and river_output_v1 objects.
        
        The global_remove event for the corresponding wl_output may be sent
        before the river_output_v1.removed event. This is due to the fact that
        river_output_v1 state changes are synced to the river window management
        manage sequence while changes to globals are not.
        
        Rationale: The window manager may need information provided by the
        wl_output interface such as the name/description. It also may need the
        wl_output object to start screencopy for example. *)
    
    method private virtual on_position : [> `V2 | `V3 | `V4 | `V5] t -> x:int32 -> y:int32 -> unit
    
    (** Output position.
        
        This event indicates the position of the output in the compositor's
        logical coordinate space. The x and y coordinates may be positive or
        negative.
        
        This event is sent once when the river_output_v1 is created and again
        whenever the position changes.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server.
        
        The server must guarantee that the position and dimensions events do not
        cause the areas of multiple logical outputs to overlap when the
        corresponding manage_start event is received. *)
    
    method private virtual on_dimensions : [> `V2 | `V3 | `V4 | `V5] t -> width:int32 -> height:int32 -> unit
    
    (** Output dimensions.
        
        This event indicates the dimensions of the output in the compositor's
        logical coordinate space. The width and height will always be strictly
        greater than zero.
        
        This event is sent once when the river_output_v1 is created and again
        whenever the dimensions change.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server.
        
        The server must guarantee that the position and dimensions events do not
        cause the areas of multiple logical outputs to overlap when the
        corresponding manage_start event is received. *)
    
    method private virtual on_capture_sessions : [> `V5] t -> count:int32 -> unit
    
    (** Output screen capture sessions.
        
        This event informs the window manager of the number of active screen
        capture sessions for the output.
        
        This event is sent once when the river_output_v1 is created and again
        whenever the number of capture sessions changes.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method min_version = 2l
  end
  
  (** Handler for a proxy with version >= 3. *)
  class virtual ['v] v3 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_removed : [> `V3 | `V4 | `V5] t -> unit
    
    (** The output is removed.
        
        This event indicates that the logical output is no longer conceptually
        part of window management space.
        
        The server will send no further events on this object and ignore any
        request (other than river_output_v1.destroy) made after this event is
        sent. The client should destroy this object with the
        river_output_v1.destroy request to free up resources.
        
        This event may be sent because a corresponding physical output has been
        physically unplugged or because some output configuration has changed.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_wl_output : [> `V3 | `V4 | `V5] t -> name:int32 -> unit
    
    (** Corresponding wl_output.
        
        The wl_output object corresponding to the river_output_v1. The argument
        is the global name of the wl_output advertised with wl_registry.global.
        
        It is guaranteed that the corresponding wl_output is advertised before
        this event is sent.
        
        This event is sent exactly once. The wl_output associated with a
        river_output_v1 cannot change. It is guaranteed that there is a 1-to-1
        mapping between wl_output and river_output_v1 objects.
        
        The global_remove event for the corresponding wl_output may be sent
        before the river_output_v1.removed event. This is due to the fact that
        river_output_v1 state changes are synced to the river window management
        manage sequence while changes to globals are not.
        
        Rationale: The window manager may need information provided by the
        wl_output interface such as the name/description. It also may need the
        wl_output object to start screencopy for example. *)
    
    method private virtual on_position : [> `V3 | `V4 | `V5] t -> x:int32 -> y:int32 -> unit
    
    (** Output position.
        
        This event indicates the position of the output in the compositor's
        logical coordinate space. The x and y coordinates may be positive or
        negative.
        
        This event is sent once when the river_output_v1 is created and again
        whenever the position changes.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server.
        
        The server must guarantee that the position and dimensions events do not
        cause the areas of multiple logical outputs to overlap when the
        corresponding manage_start event is received. *)
    
    method private virtual on_dimensions : [> `V3 | `V4 | `V5] t -> width:int32 -> height:int32 -> unit
    
    (** Output dimensions.
        
        This event indicates the dimensions of the output in the compositor's
        logical coordinate space. The width and height will always be strictly
        greater than zero.
        
        This event is sent once when the river_output_v1 is created and again
        whenever the dimensions change.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server.
        
        The server must guarantee that the position and dimensions events do not
        cause the areas of multiple logical outputs to overlap when the
        corresponding manage_start event is received. *)
    
    method private virtual on_capture_sessions : [> `V5] t -> count:int32 -> unit
    
    (** Output screen capture sessions.
        
        This event informs the window manager of the number of active screen
        capture sessions for the output.
        
        This event is sent once when the river_output_v1 is created and again
        whenever the number of capture sessions changes.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method min_version = 3l
  end
  
  (** Handler for a proxy with version >= 4. *)
  class virtual ['v] v4 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_removed : [> `V4 | `V5] t -> unit
    
    (** The output is removed.
        
        This event indicates that the logical output is no longer conceptually
        part of window management space.
        
        The server will send no further events on this object and ignore any
        request (other than river_output_v1.destroy) made after this event is
        sent. The client should destroy this object with the
        river_output_v1.destroy request to free up resources.
        
        This event may be sent because a corresponding physical output has been
        physically unplugged or because some output configuration has changed.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_wl_output : [> `V4 | `V5] t -> name:int32 -> unit
    
    (** Corresponding wl_output.
        
        The wl_output object corresponding to the river_output_v1. The argument
        is the global name of the wl_output advertised with wl_registry.global.
        
        It is guaranteed that the corresponding wl_output is advertised before
        this event is sent.
        
        This event is sent exactly once. The wl_output associated with a
        river_output_v1 cannot change. It is guaranteed that there is a 1-to-1
        mapping between wl_output and river_output_v1 objects.
        
        The global_remove event for the corresponding wl_output may be sent
        before the river_output_v1.removed event. This is due to the fact that
        river_output_v1 state changes are synced to the river window management
        manage sequence while changes to globals are not.
        
        Rationale: The window manager may need information provided by the
        wl_output interface such as the name/description. It also may need the
        wl_output object to start screencopy for example. *)
    
    method private virtual on_position : [> `V4 | `V5] t -> x:int32 -> y:int32 -> unit
    
    (** Output position.
        
        This event indicates the position of the output in the compositor's
        logical coordinate space. The x and y coordinates may be positive or
        negative.
        
        This event is sent once when the river_output_v1 is created and again
        whenever the position changes.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server.
        
        The server must guarantee that the position and dimensions events do not
        cause the areas of multiple logical outputs to overlap when the
        corresponding manage_start event is received. *)
    
    method private virtual on_dimensions : [> `V4 | `V5] t -> width:int32 -> height:int32 -> unit
    
    (** Output dimensions.
        
        This event indicates the dimensions of the output in the compositor's
        logical coordinate space. The width and height will always be strictly
        greater than zero.
        
        This event is sent once when the river_output_v1 is created and again
        whenever the dimensions change.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server.
        
        The server must guarantee that the position and dimensions events do not
        cause the areas of multiple logical outputs to overlap when the
        corresponding manage_start event is received. *)
    
    method private virtual on_capture_sessions : [> `V5] t -> count:int32 -> unit
    
    (** Output screen capture sessions.
        
        This event informs the window manager of the number of active screen
        capture sessions for the output.
        
        This event is sent once when the river_output_v1 is created and again
        whenever the number of capture sessions changes.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method min_version = 4l
  end
  
  (** Handler for a proxy with version >= 5. *)
  class virtual ['v] v5 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_removed : [> `V5] t -> unit
    
    (** The output is removed.
        
        This event indicates that the logical output is no longer conceptually
        part of window management space.
        
        The server will send no further events on this object and ignore any
        request (other than river_output_v1.destroy) made after this event is
        sent. The client should destroy this object with the
        river_output_v1.destroy request to free up resources.
        
        This event may be sent because a corresponding physical output has been
        physically unplugged or because some output configuration has changed.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_wl_output : [> `V5] t -> name:int32 -> unit
    
    (** Corresponding wl_output.
        
        The wl_output object corresponding to the river_output_v1. The argument
        is the global name of the wl_output advertised with wl_registry.global.
        
        It is guaranteed that the corresponding wl_output is advertised before
        this event is sent.
        
        This event is sent exactly once. The wl_output associated with a
        river_output_v1 cannot change. It is guaranteed that there is a 1-to-1
        mapping between wl_output and river_output_v1 objects.
        
        The global_remove event for the corresponding wl_output may be sent
        before the river_output_v1.removed event. This is due to the fact that
        river_output_v1 state changes are synced to the river window management
        manage sequence while changes to globals are not.
        
        Rationale: The window manager may need information provided by the
        wl_output interface such as the name/description. It also may need the
        wl_output object to start screencopy for example. *)
    
    method private virtual on_position : [> `V5] t -> x:int32 -> y:int32 -> unit
    
    (** Output position.
        
        This event indicates the position of the output in the compositor's
        logical coordinate space. The x and y coordinates may be positive or
        negative.
        
        This event is sent once when the river_output_v1 is created and again
        whenever the position changes.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server.
        
        The server must guarantee that the position and dimensions events do not
        cause the areas of multiple logical outputs to overlap when the
        corresponding manage_start event is received. *)
    
    method private virtual on_dimensions : [> `V5] t -> width:int32 -> height:int32 -> unit
    
    (** Output dimensions.
        
        This event indicates the dimensions of the output in the compositor's
        logical coordinate space. The width and height will always be strictly
        greater than zero.
        
        This event is sent once when the river_output_v1 is created and again
        whenever the dimensions change.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server.
        
        The server must guarantee that the position and dimensions events do not
        cause the areas of multiple logical outputs to overlap when the
        corresponding manage_start event is received. *)
    
    method private virtual on_capture_sessions : [> `V5] t -> count:int32 -> unit
    
    (** Output screen capture sessions.
        
        This event informs the window manager of the number of active screen
        capture sessions for the output.
        
        This event is sent once when the river_output_v1 is created and again
        whenever the number of capture sessions changes.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method min_version = 5l
  end
end

(** A window management seat.
    
    This object represents a single user's collection of input devices. It
    allows the window manager to route keyboard input to windows, get
    high-level information about pointer input, define pointer bindings, etc.
    
    For keyboard bindings, see the river-xkb-bindings-v1 protocol.
    
    Since version 4: The cursor surface/shape set by the window manager on the
    wl_pointer of this seat is used when no client has pointer focus, for
    example during a pointer operation. Since the window manager is allowed to
    set cursor surface/shape even when it does not have pointer focus, the
    compositor must ignore the serial argument of wl_pointer.set_cursor and
    wp_cursor_shape_device_v1.set_shape requests made by the window manager.
    
    The most recent cursor surface/shape set by the window manager is
    remembered by the compositor and restored whenever no client has pointer
    focus. If the window manager never sets a cursor surface/shape, the
    "default" shape is used. *)
module River_seat_v1 = struct
  type 'v t = ([`River_seat_v1], 'v, [`Client]) Proxy.t
  module Modifiers = River_window_management_v1_proto.River_seat_v1.Modifiers
  
  (** {2 Version 1} *)
  
  (** Define a new pointer binding.
      
      Define a pointer binding in terms of a pointer button, keyboard
      modifiers, and other configurable properties.
      
      The button argument is a Linux input event code defined in the
      linux/input-event-codes.h header file (e.g. BTN_RIGHT).
      
      The new pointer binding is not enabled until initial configuration is
      completed and the enable request is made during a manage sequence. *)
  let get_pointer_binding (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) 
    (id:([`River_pointer_binding_v1], 'v, [`Client]) #Proxy.Handler.t) ~button ~modifiers =
    let __id = Proxy.spawn _t id in
    let _msg = Proxy.alloc _t ~op:6 ~ints:3 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id __id);
    Msg.add_int _msg button;
    Msg.add_int _msg (Imports.River_seat_v1.Modifiers.to_int32 modifiers);
    Proxy.send _t _msg;
    __id
  
  (** End an interactive operation.
      
      End an interactive operation.
      
      This request is ignored if there is no operation in progress.
      
      This request modifies window management state and may only be made as
      part of a manage sequence, see the river_window_manager_v1 description. *)
  let op_end (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:5 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (** Start an interactive pointer operation.
      
      Start an interactive pointer operation. During the operation, op_delta
      events will be sent based on pointer input.
      
      When all pointer buttons are released, the op_release event is sent.
      
      The pointer operation continues until the op_end request is made during
      a manage sequence and that manage sequence is finished.
      
      The window manager may use this operation to implement interactive
      move/resize of windows by setting the position of windows and proposing
      dimensions based off of the op_delta events.
      
      This request is ignored if an operation is already in progress.
      
      The compositor must ensure that no client has pointer focus from this
      seat during the pointer operation. This means that the window manager
      has control over the pointer's cursor surface/shape during the pointer
      operation. See the river_seat_v1 description.
      
      This request modifies window management state and may only be made as
      part of a manage sequence, see the river_window_manager_v1 description. *)
  let op_start_pointer (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) 
     =
    let _msg = Proxy.alloc _t ~op:4 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (** Clear keyboard focus.
      
      Request that the compositor not send keyboard input to any client.
      
      This request modifies window management state and may only be made as
      part of a manage sequence, see the river_window_manager_v1 description. *)
  let clear_focus (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:3 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (** Give keyboard focus to a shell_surface.
      
      Request that the compositor send keyboard input to the given shell
      surface.
      
      This request modifies window management state and may only be made as
      part of a manage sequence, see the river_window_manager_v1 description. *)
  let focus_shell_surface (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) 
    ~(shell_surface:([`River_shell_surface_v1], _, [`Client]) Proxy.t) =
    let _msg = Proxy.alloc _t ~op:2 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id shell_surface);
    Proxy.send _t _msg
  
  (** Give keyboard focus to a window.
      
      Request that the compositor send keyboard input to the given window.
      
      This request modifies window management state and may only be made as
      part of a manage sequence, see the river_window_manager_v1 description. *)
  let focus_window (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) ~(window:([`River_window_v1], _, [`Client]) Proxy.t) =
    let _msg = Proxy.alloc _t ~op:1 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id window);
    Proxy.send _t _msg
  
  (** Destroy the seat object.
      
      This request indicates that the client will no longer use the seat
      object and that it may be safely destroyed.
      
      This request should be made after the river_seat_v1.removed event is
      received to complete destruction of the seat. *)
  let destroy (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:0 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg;
    Proxy.shutdown_send _t
  
  
  (** {2 Version 2} *)
  
  (** Set the xcursor theme for the seat.
      
      Set the XCursor theme for the seat. This theme is used for cursors
      rendered by the compositor, but not necessarily for cursors rendered by
      clients.
      
      Note: The window manager may also wish to set the XCURSOR_THEME and
      XCURSOR_SIZE environment variable for programs it starts. *)
  let set_xcursor_theme (_t:([< `V2 | `V3 | `V4 | `V5] as 'v) t) ~name ~size =
    let _msg = Proxy.alloc _t ~op:7 ~ints:2 ~strings:[(Some name)] ~arrays:[] in
    Msg.add_string _msg name;
    Msg.add_int _msg size;
    Proxy.send _t _msg
  
  
  (** {2 Version 3, 4, 5} *)
  
  (** Warp the pointer to a given position.
      
      Warp the pointer to the given position in the compositor's logical
      coordinate space.
      
      If the given position is outside the bounds of all outputs, the pointer
      will be warped to the closest point inside an output instead.
      
      If an op_start_pointer request is made during the same manage sequence
      as a pointer_warp request, the warp is applied first by the server
      regardless of the relative ordering of the two requests.
      
      This request modifies window management state and may only be made as
      part of a manage sequence, see the river_window_manager_v1 description. *)
  let pointer_warp (_t:([< `V3 | `V4 | `V5] as 'v) t) ~x ~y =
    let _msg = Proxy.alloc _t ~op:8 ~ints:2 ~strings:[] ~arrays:[] in
    Msg.add_int _msg x;
    Msg.add_int _msg y;
    Proxy.send _t _msg
  
  (**/**)
  class virtual ['v] _handlers_unsafe = object (_self : (_, 'v, _) #Proxy.Handler.t)
    method user_data = S.No_data
    method metadata = (module River_window_management_v1_proto.River_seat_v1)
    method max_version = 5l
    
    method private virtual on_removed : [> ] t -> unit
    
    method private virtual on_wl_seat : [> ] t -> name:int32 -> unit
    
    method private virtual on_pointer_enter : [> ] t -> window:([`River_window_v1], [> Imports.River_window_v1.versions], [`Client]) Proxy.t ->
                                              unit
    
    method private virtual on_pointer_leave : [> ] t -> unit
    
    method private virtual on_window_interaction : [> ] t -> window:([`River_window_v1], [> Imports.River_window_v1.versions], [`Client]) Proxy.t ->
                                                   unit
    
    method private virtual on_shell_surface_interaction : [> ] t -> shell_surface:([`River_shell_surface_v1], [> Imports.River_shell_surface_v1.versions], [`Client]) Proxy.t ->
                                                          unit
    
    method private virtual on_op_delta : [> ] t -> dx:int32 -> dy:int32 -> unit
    
    method private virtual on_op_release : [> ] t -> unit
    
    method private virtual on_pointer_position : [> ] t -> x:int32 -> y:int32 -> unit
    
    
    method dispatch (_proxy : 'v t) _msg =
      let _proxy = Proxy.cast_version _proxy in
      match Msg.op _msg with
      | 0 ->
        _self#on_removed _proxy 
      | 1 ->
        let name = Msg.get_int _msg in
        _self#on_wl_seat _proxy ~name
      | 2 ->
        let window : ([`River_window_v1], _, _) Proxy.t =
          let Proxy.Proxy p = Msg.get_int _msg |> Proxy.lookup_other _proxy in
          match Proxy.ty p with
          | Imports.River_window_v1.T -> p
          | _ -> Proxy.wrong_type ~parent:_proxy ~expected:"river_window_v1" p
          in
        _self#on_pointer_enter _proxy ~window
      | 3 ->
        _self#on_pointer_leave _proxy 
      | 4 ->
        let window : ([`River_window_v1], _, _) Proxy.t =
          let Proxy.Proxy p = Msg.get_int _msg |> Proxy.lookup_other _proxy in
          match Proxy.ty p with
          | Imports.River_window_v1.T -> p
          | _ -> Proxy.wrong_type ~parent:_proxy ~expected:"river_window_v1" p
          in
        _self#on_window_interaction _proxy ~window
      | 5 ->
        let shell_surface : ([`River_shell_surface_v1], _, _) Proxy.t =
          let Proxy.Proxy p = Msg.get_int _msg |> Proxy.lookup_other _proxy in
          match Proxy.ty p with
          | Imports.River_shell_surface_v1.T -> p
          | _ -> Proxy.wrong_type ~parent:_proxy ~expected:"river_shell_surface_v1" p
          in
        _self#on_shell_surface_interaction _proxy ~shell_surface
      | 6 ->
        let dx = Msg.get_int _msg in
        let dy = Msg.get_int _msg in
        _self#on_op_delta _proxy ~dx ~dy
      | 7 ->
        _self#on_op_release _proxy 
      | 8 ->
        let x = Msg.get_int _msg in
        let y = Msg.get_int _msg in
        _self#on_pointer_position _proxy ~x ~y
      | _ -> assert false
  end
  (**/**)
  
  (** {2 Handlers}
      Note: Servers will always want to use [v1].
   *)
  
  
  (** Handler for a proxy with version >= 1. *)
  class virtual ['v] v1 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V1 | `V2 | `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_removed : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** The seat is removed.
        
        This event indicates that seat is no longer in use and should be
        destroyed.
        
        The server will send no further events on this object and ignore any
        request (other than river_seat_v1.destroy) made after this event is
        sent.  The client should destroy this object with the
        river_seat_v1.destroy request to free up resources.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_wl_seat : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> name:int32 -> unit
    
    (** Corresponding wl_seat.
        
        The wl_seat object corresponding to the river_seat_v1. The argument is
        the global name of the wl_seat advertised with wl_registry.global.
        
        It is guaranteed that the corresponding wl_seat is advertised before
        this event is sent.
        
        This event is sent exactly once. The wl_seat associated with a
        river_seat_v1 cannot change. It is guaranteed that there is a 1-to-1
        mapping between wl_seat and river_seat_v1 objects.
        
        The global_remove event for the corresponding wl_seat may be sent before
        the river_seat_v1.removed event. This is due to the fact that
        river_seat_v1 state changes are synced to the river window management
        manage sequence while changes to globals are not.
        
        Rationale: The window manager may want to trigger window management
        state changes based on normal input events received by its shell
        surfaces for example. *)
    
    method private virtual on_pointer_enter : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> window:([`River_window_v1], [> Imports.River_window_v1.versions], [`Client]) Proxy.t ->
                                              unit
    
    (** Pointer entered a window.
        
        The seat's pointer entered the given window's area.
        
        The area of a window is defined to include the area defined by the
        window dimensions, borders configured using river_window_v1.set_borders,
        and the input regions of decoration surfaces. In particular, it does not
        include input regions of surfaces belonging to the window that extend
        outside the window dimensions.
        
        The pointer of a seat may only enter a single window at a time. When the
        pointer moves between windows, the pointer_leave event for the old
        window must be sent before the pointer_enter event for the new window.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_pointer_leave : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Pointer left the entered window.
        
        The seat's pointer left the window for which pointer_enter was most
        recently sent. See pointer_enter for details.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_window_interaction : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> window:([`River_window_v1], [> Imports.River_window_v1.versions], [`Client]) Proxy.t ->
                                                   unit
    
    (** A window has been interacted with.
        
        A window has been interacted with beyond the pointer merely passing over
        it. This event might be sent due to a pointer button press or due to a
        touch/tablet tool interaction with the window.
        
        There are no guarantees regarding how this event is sent in relation to
        the pointer_enter and pointer_leave events as the interaction may use
        touch or tablet tool input.
        
        Rationale: this event gives window managers necessary information to
        determine when to send keyboard focus, raise a window that already has
        keyboard focus, etc. Rather than expose all pointer, touch, and tablet
        events to window managers, a policy over mechanism approach is taken.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_shell_surface_interaction : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> shell_surface:([`River_shell_surface_v1], [> Imports.River_shell_surface_v1.versions], [`Client]) Proxy.t ->
                                                          unit
    
    (** A shell surface has been interacted with.
        
        A shell surface has been interacted with beyond the pointer merely
        passing over it. This event might be sent due to a pointer button press
        or due to a touch/tablet tool interaction with the shell_surface.
        
        There are no guarantees regarding how this event is sent in relation to
        the pointer_enter and pointer_leave events as the interaction may use
        touch or tablet tool input.
        
        Rationale: While the shell surface does receive all wl_pointer,
        wl_touch, etc. input events for the surface directly, these events do
        not necessarily trigger a manage sequence and therefore do not allow the
        window manager to update focus or perform other actions in response to
        the input in a race-free way.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_op_delta : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> dx:int32 -> dy:int32 -> unit
    
    (** Total cumulative motion since op start.
        
        This event indicates the total change in position since the start of the
        operation of the pointer/touch point/etc.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_op_release : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Operation input has been released.
        
        The input driving the current interactive operation has been released.
        For a pointer op for example, all pointer buttons have been released.
        
        Depending on the op type, op_delta events may continue to be sent until
        the op is ended with the op_end request.
        
        This event is sent at most once during an interactive operation.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_pointer_position : [> `V2 | `V3 | `V4 | `V5] t -> x:int32 -> y:int32 -> unit
    
    (** The current position of the pointer.
        
        The current position of the pointer in the compositor's logical
        coordinate space.
        
        This state is special in that a change in pointer position alone must
        not cause the compositor to start a manage sequence.
        
        Assuming the seat has a pointer, this event must be sent in every manage
        sequence unless there is no change in x/y position since the last time this
        event was sent. *)
    
    method min_version = 1l
  end
  
  (** Handler for a proxy with version >= 2. *)
  class virtual ['v] v2 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V2 | `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_removed : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** The seat is removed.
        
        This event indicates that seat is no longer in use and should be
        destroyed.
        
        The server will send no further events on this object and ignore any
        request (other than river_seat_v1.destroy) made after this event is
        sent.  The client should destroy this object with the
        river_seat_v1.destroy request to free up resources.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_wl_seat : [> `V2 | `V3 | `V4 | `V5] t -> name:int32 -> unit
    
    (** Corresponding wl_seat.
        
        The wl_seat object corresponding to the river_seat_v1. The argument is
        the global name of the wl_seat advertised with wl_registry.global.
        
        It is guaranteed that the corresponding wl_seat is advertised before
        this event is sent.
        
        This event is sent exactly once. The wl_seat associated with a
        river_seat_v1 cannot change. It is guaranteed that there is a 1-to-1
        mapping between wl_seat and river_seat_v1 objects.
        
        The global_remove event for the corresponding wl_seat may be sent before
        the river_seat_v1.removed event. This is due to the fact that
        river_seat_v1 state changes are synced to the river window management
        manage sequence while changes to globals are not.
        
        Rationale: The window manager may want to trigger window management
        state changes based on normal input events received by its shell
        surfaces for example. *)
    
    method private virtual on_pointer_enter : [> `V2 | `V3 | `V4 | `V5] t -> window:([`River_window_v1], [> Imports.River_window_v1.versions], [`Client]) Proxy.t ->
                                              unit
    
    (** Pointer entered a window.
        
        The seat's pointer entered the given window's area.
        
        The area of a window is defined to include the area defined by the
        window dimensions, borders configured using river_window_v1.set_borders,
        and the input regions of decoration surfaces. In particular, it does not
        include input regions of surfaces belonging to the window that extend
        outside the window dimensions.
        
        The pointer of a seat may only enter a single window at a time. When the
        pointer moves between windows, the pointer_leave event for the old
        window must be sent before the pointer_enter event for the new window.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_pointer_leave : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Pointer left the entered window.
        
        The seat's pointer left the window for which pointer_enter was most
        recently sent. See pointer_enter for details.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_window_interaction : [> `V2 | `V3 | `V4 | `V5] t -> window:([`River_window_v1], [> Imports.River_window_v1.versions], [`Client]) Proxy.t ->
                                                   unit
    
    (** A window has been interacted with.
        
        A window has been interacted with beyond the pointer merely passing over
        it. This event might be sent due to a pointer button press or due to a
        touch/tablet tool interaction with the window.
        
        There are no guarantees regarding how this event is sent in relation to
        the pointer_enter and pointer_leave events as the interaction may use
        touch or tablet tool input.
        
        Rationale: this event gives window managers necessary information to
        determine when to send keyboard focus, raise a window that already has
        keyboard focus, etc. Rather than expose all pointer, touch, and tablet
        events to window managers, a policy over mechanism approach is taken.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_shell_surface_interaction : [> `V2 | `V3 | `V4 | `V5] t -> shell_surface:([`River_shell_surface_v1], [> Imports.River_shell_surface_v1.versions], [`Client]) Proxy.t ->
                                                          unit
    
    (** A shell surface has been interacted with.
        
        A shell surface has been interacted with beyond the pointer merely
        passing over it. This event might be sent due to a pointer button press
        or due to a touch/tablet tool interaction with the shell_surface.
        
        There are no guarantees regarding how this event is sent in relation to
        the pointer_enter and pointer_leave events as the interaction may use
        touch or tablet tool input.
        
        Rationale: While the shell surface does receive all wl_pointer,
        wl_touch, etc. input events for the surface directly, these events do
        not necessarily trigger a manage sequence and therefore do not allow the
        window manager to update focus or perform other actions in response to
        the input in a race-free way.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_op_delta : [> `V2 | `V3 | `V4 | `V5] t -> dx:int32 -> dy:int32 -> unit
    
    (** Total cumulative motion since op start.
        
        This event indicates the total change in position since the start of the
        operation of the pointer/touch point/etc.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_op_release : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Operation input has been released.
        
        The input driving the current interactive operation has been released.
        For a pointer op for example, all pointer buttons have been released.
        
        Depending on the op type, op_delta events may continue to be sent until
        the op is ended with the op_end request.
        
        This event is sent at most once during an interactive operation.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_pointer_position : [> `V2 | `V3 | `V4 | `V5] t -> x:int32 -> y:int32 -> unit
    
    (** The current position of the pointer.
        
        The current position of the pointer in the compositor's logical
        coordinate space.
        
        This state is special in that a change in pointer position alone must
        not cause the compositor to start a manage sequence.
        
        Assuming the seat has a pointer, this event must be sent in every manage
        sequence unless there is no change in x/y position since the last time this
        event was sent. *)
    
    method min_version = 2l
  end
  
  (** Handler for a proxy with version >= 3. *)
  class virtual ['v] v3 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_removed : [> `V3 | `V4 | `V5] t -> unit
    
    (** The seat is removed.
        
        This event indicates that seat is no longer in use and should be
        destroyed.
        
        The server will send no further events on this object and ignore any
        request (other than river_seat_v1.destroy) made after this event is
        sent.  The client should destroy this object with the
        river_seat_v1.destroy request to free up resources.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_wl_seat : [> `V3 | `V4 | `V5] t -> name:int32 -> unit
    
    (** Corresponding wl_seat.
        
        The wl_seat object corresponding to the river_seat_v1. The argument is
        the global name of the wl_seat advertised with wl_registry.global.
        
        It is guaranteed that the corresponding wl_seat is advertised before
        this event is sent.
        
        This event is sent exactly once. The wl_seat associated with a
        river_seat_v1 cannot change. It is guaranteed that there is a 1-to-1
        mapping between wl_seat and river_seat_v1 objects.
        
        The global_remove event for the corresponding wl_seat may be sent before
        the river_seat_v1.removed event. This is due to the fact that
        river_seat_v1 state changes are synced to the river window management
        manage sequence while changes to globals are not.
        
        Rationale: The window manager may want to trigger window management
        state changes based on normal input events received by its shell
        surfaces for example. *)
    
    method private virtual on_pointer_enter : [> `V3 | `V4 | `V5] t -> window:([`River_window_v1], [> Imports.River_window_v1.versions], [`Client]) Proxy.t ->
                                              unit
    
    (** Pointer entered a window.
        
        The seat's pointer entered the given window's area.
        
        The area of a window is defined to include the area defined by the
        window dimensions, borders configured using river_window_v1.set_borders,
        and the input regions of decoration surfaces. In particular, it does not
        include input regions of surfaces belonging to the window that extend
        outside the window dimensions.
        
        The pointer of a seat may only enter a single window at a time. When the
        pointer moves between windows, the pointer_leave event for the old
        window must be sent before the pointer_enter event for the new window.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_pointer_leave : [> `V3 | `V4 | `V5] t -> unit
    
    (** Pointer left the entered window.
        
        The seat's pointer left the window for which pointer_enter was most
        recently sent. See pointer_enter for details.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_window_interaction : [> `V3 | `V4 | `V5] t -> window:([`River_window_v1], [> Imports.River_window_v1.versions], [`Client]) Proxy.t ->
                                                   unit
    
    (** A window has been interacted with.
        
        A window has been interacted with beyond the pointer merely passing over
        it. This event might be sent due to a pointer button press or due to a
        touch/tablet tool interaction with the window.
        
        There are no guarantees regarding how this event is sent in relation to
        the pointer_enter and pointer_leave events as the interaction may use
        touch or tablet tool input.
        
        Rationale: this event gives window managers necessary information to
        determine when to send keyboard focus, raise a window that already has
        keyboard focus, etc. Rather than expose all pointer, touch, and tablet
        events to window managers, a policy over mechanism approach is taken.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_shell_surface_interaction : [> `V3 | `V4 | `V5] t -> shell_surface:([`River_shell_surface_v1], [> Imports.River_shell_surface_v1.versions], [`Client]) Proxy.t ->
                                                          unit
    
    (** A shell surface has been interacted with.
        
        A shell surface has been interacted with beyond the pointer merely
        passing over it. This event might be sent due to a pointer button press
        or due to a touch/tablet tool interaction with the shell_surface.
        
        There are no guarantees regarding how this event is sent in relation to
        the pointer_enter and pointer_leave events as the interaction may use
        touch or tablet tool input.
        
        Rationale: While the shell surface does receive all wl_pointer,
        wl_touch, etc. input events for the surface directly, these events do
        not necessarily trigger a manage sequence and therefore do not allow the
        window manager to update focus or perform other actions in response to
        the input in a race-free way.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_op_delta : [> `V3 | `V4 | `V5] t -> dx:int32 -> dy:int32 -> unit
    
    (** Total cumulative motion since op start.
        
        This event indicates the total change in position since the start of the
        operation of the pointer/touch point/etc.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_op_release : [> `V3 | `V4 | `V5] t -> unit
    
    (** Operation input has been released.
        
        The input driving the current interactive operation has been released.
        For a pointer op for example, all pointer buttons have been released.
        
        Depending on the op type, op_delta events may continue to be sent until
        the op is ended with the op_end request.
        
        This event is sent at most once during an interactive operation.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_pointer_position : [> `V3 | `V4 | `V5] t -> x:int32 -> y:int32 -> unit
    
    (** The current position of the pointer.
        
        The current position of the pointer in the compositor's logical
        coordinate space.
        
        This state is special in that a change in pointer position alone must
        not cause the compositor to start a manage sequence.
        
        Assuming the seat has a pointer, this event must be sent in every manage
        sequence unless there is no change in x/y position since the last time this
        event was sent. *)
    
    method min_version = 3l
  end
  
  (** Handler for a proxy with version >= 4. *)
  class virtual ['v] v4 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_removed : [> `V4 | `V5] t -> unit
    
    (** The seat is removed.
        
        This event indicates that seat is no longer in use and should be
        destroyed.
        
        The server will send no further events on this object and ignore any
        request (other than river_seat_v1.destroy) made after this event is
        sent.  The client should destroy this object with the
        river_seat_v1.destroy request to free up resources.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_wl_seat : [> `V4 | `V5] t -> name:int32 -> unit
    
    (** Corresponding wl_seat.
        
        The wl_seat object corresponding to the river_seat_v1. The argument is
        the global name of the wl_seat advertised with wl_registry.global.
        
        It is guaranteed that the corresponding wl_seat is advertised before
        this event is sent.
        
        This event is sent exactly once. The wl_seat associated with a
        river_seat_v1 cannot change. It is guaranteed that there is a 1-to-1
        mapping between wl_seat and river_seat_v1 objects.
        
        The global_remove event for the corresponding wl_seat may be sent before
        the river_seat_v1.removed event. This is due to the fact that
        river_seat_v1 state changes are synced to the river window management
        manage sequence while changes to globals are not.
        
        Rationale: The window manager may want to trigger window management
        state changes based on normal input events received by its shell
        surfaces for example. *)
    
    method private virtual on_pointer_enter : [> `V4 | `V5] t -> window:([`River_window_v1], [> Imports.River_window_v1.versions], [`Client]) Proxy.t ->
                                              unit
    
    (** Pointer entered a window.
        
        The seat's pointer entered the given window's area.
        
        The area of a window is defined to include the area defined by the
        window dimensions, borders configured using river_window_v1.set_borders,
        and the input regions of decoration surfaces. In particular, it does not
        include input regions of surfaces belonging to the window that extend
        outside the window dimensions.
        
        The pointer of a seat may only enter a single window at a time. When the
        pointer moves between windows, the pointer_leave event for the old
        window must be sent before the pointer_enter event for the new window.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_pointer_leave : [> `V4 | `V5] t -> unit
    
    (** Pointer left the entered window.
        
        The seat's pointer left the window for which pointer_enter was most
        recently sent. See pointer_enter for details.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_window_interaction : [> `V4 | `V5] t -> window:([`River_window_v1], [> Imports.River_window_v1.versions], [`Client]) Proxy.t ->
                                                   unit
    
    (** A window has been interacted with.
        
        A window has been interacted with beyond the pointer merely passing over
        it. This event might be sent due to a pointer button press or due to a
        touch/tablet tool interaction with the window.
        
        There are no guarantees regarding how this event is sent in relation to
        the pointer_enter and pointer_leave events as the interaction may use
        touch or tablet tool input.
        
        Rationale: this event gives window managers necessary information to
        determine when to send keyboard focus, raise a window that already has
        keyboard focus, etc. Rather than expose all pointer, touch, and tablet
        events to window managers, a policy over mechanism approach is taken.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_shell_surface_interaction : [> `V4 | `V5] t -> shell_surface:([`River_shell_surface_v1], [> Imports.River_shell_surface_v1.versions], [`Client]) Proxy.t ->
                                                          unit
    
    (** A shell surface has been interacted with.
        
        A shell surface has been interacted with beyond the pointer merely
        passing over it. This event might be sent due to a pointer button press
        or due to a touch/tablet tool interaction with the shell_surface.
        
        There are no guarantees regarding how this event is sent in relation to
        the pointer_enter and pointer_leave events as the interaction may use
        touch or tablet tool input.
        
        Rationale: While the shell surface does receive all wl_pointer,
        wl_touch, etc. input events for the surface directly, these events do
        not necessarily trigger a manage sequence and therefore do not allow the
        window manager to update focus or perform other actions in response to
        the input in a race-free way.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_op_delta : [> `V4 | `V5] t -> dx:int32 -> dy:int32 -> unit
    
    (** Total cumulative motion since op start.
        
        This event indicates the total change in position since the start of the
        operation of the pointer/touch point/etc.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_op_release : [> `V4 | `V5] t -> unit
    
    (** Operation input has been released.
        
        The input driving the current interactive operation has been released.
        For a pointer op for example, all pointer buttons have been released.
        
        Depending on the op type, op_delta events may continue to be sent until
        the op is ended with the op_end request.
        
        This event is sent at most once during an interactive operation.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_pointer_position : [> `V4 | `V5] t -> x:int32 -> y:int32 -> unit
    
    (** The current position of the pointer.
        
        The current position of the pointer in the compositor's logical
        coordinate space.
        
        This state is special in that a change in pointer position alone must
        not cause the compositor to start a manage sequence.
        
        Assuming the seat has a pointer, this event must be sent in every manage
        sequence unless there is no change in x/y position since the last time this
        event was sent. *)
    
    method min_version = 4l
  end
  
  (** Handler for a proxy with version >= 5. *)
  class virtual ['v] v5 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_removed : [> `V5] t -> unit
    
    (** The seat is removed.
        
        This event indicates that seat is no longer in use and should be
        destroyed.
        
        The server will send no further events on this object and ignore any
        request (other than river_seat_v1.destroy) made after this event is
        sent.  The client should destroy this object with the
        river_seat_v1.destroy request to free up resources.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_wl_seat : [> `V5] t -> name:int32 -> unit
    
    (** Corresponding wl_seat.
        
        The wl_seat object corresponding to the river_seat_v1. The argument is
        the global name of the wl_seat advertised with wl_registry.global.
        
        It is guaranteed that the corresponding wl_seat is advertised before
        this event is sent.
        
        This event is sent exactly once. The wl_seat associated with a
        river_seat_v1 cannot change. It is guaranteed that there is a 1-to-1
        mapping between wl_seat and river_seat_v1 objects.
        
        The global_remove event for the corresponding wl_seat may be sent before
        the river_seat_v1.removed event. This is due to the fact that
        river_seat_v1 state changes are synced to the river window management
        manage sequence while changes to globals are not.
        
        Rationale: The window manager may want to trigger window management
        state changes based on normal input events received by its shell
        surfaces for example. *)
    
    method private virtual on_pointer_enter : [> `V5] t -> window:([`River_window_v1], [> Imports.River_window_v1.versions], [`Client]) Proxy.t ->
                                              unit
    
    (** Pointer entered a window.
        
        The seat's pointer entered the given window's area.
        
        The area of a window is defined to include the area defined by the
        window dimensions, borders configured using river_window_v1.set_borders,
        and the input regions of decoration surfaces. In particular, it does not
        include input regions of surfaces belonging to the window that extend
        outside the window dimensions.
        
        The pointer of a seat may only enter a single window at a time. When the
        pointer moves between windows, the pointer_leave event for the old
        window must be sent before the pointer_enter event for the new window.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_pointer_leave : [> `V5] t -> unit
    
    (** Pointer left the entered window.
        
        The seat's pointer left the window for which pointer_enter was most
        recently sent. See pointer_enter for details.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_window_interaction : [> `V5] t -> window:([`River_window_v1], [> Imports.River_window_v1.versions], [`Client]) Proxy.t ->
                                                   unit
    
    (** A window has been interacted with.
        
        A window has been interacted with beyond the pointer merely passing over
        it. This event might be sent due to a pointer button press or due to a
        touch/tablet tool interaction with the window.
        
        There are no guarantees regarding how this event is sent in relation to
        the pointer_enter and pointer_leave events as the interaction may use
        touch or tablet tool input.
        
        Rationale: this event gives window managers necessary information to
        determine when to send keyboard focus, raise a window that already has
        keyboard focus, etc. Rather than expose all pointer, touch, and tablet
        events to window managers, a policy over mechanism approach is taken.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_shell_surface_interaction : [> `V5] t -> shell_surface:([`River_shell_surface_v1], [> Imports.River_shell_surface_v1.versions], [`Client]) Proxy.t ->
                                                          unit
    
    (** A shell surface has been interacted with.
        
        A shell surface has been interacted with beyond the pointer merely
        passing over it. This event might be sent due to a pointer button press
        or due to a touch/tablet tool interaction with the shell_surface.
        
        There are no guarantees regarding how this event is sent in relation to
        the pointer_enter and pointer_leave events as the interaction may use
        touch or tablet tool input.
        
        Rationale: While the shell surface does receive all wl_pointer,
        wl_touch, etc. input events for the surface directly, these events do
        not necessarily trigger a manage sequence and therefore do not allow the
        window manager to update focus or perform other actions in response to
        the input in a race-free way.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_op_delta : [> `V5] t -> dx:int32 -> dy:int32 -> unit
    
    (** Total cumulative motion since op start.
        
        This event indicates the total change in position since the start of the
        operation of the pointer/touch point/etc.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_op_release : [> `V5] t -> unit
    
    (** Operation input has been released.
        
        The input driving the current interactive operation has been released.
        For a pointer op for example, all pointer buttons have been released.
        
        Depending on the op type, op_delta events may continue to be sent until
        the op is ended with the op_end request.
        
        This event is sent at most once during an interactive operation.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server. *)
    
    method private virtual on_pointer_position : [> `V5] t -> x:int32 -> y:int32 -> unit
    
    (** The current position of the pointer.
        
        The current position of the pointer in the compositor's logical
        coordinate space.
        
        This state is special in that a change in pointer position alone must
        not cause the compositor to start a manage sequence.
        
        Assuming the seat has a pointer, this event must be sent in every manage
        sequence unless there is no change in x/y position since the last time this
        event was sent. *)
    
    method min_version = 5l
  end
end

(** Configure a pointer binding, receive trigger events.
    
    This object allows the window manager to configure a pointer binding and
    receive events when the binding is triggered.
    
    The new pointer binding is not enabled until the enable request is made
    during a manage sequence.
    
    Normally, all pointer button events are sent to the surface with pointer
    focus by the compositor. Pointer button events that trigger a pointer
    binding are not sent to the surface with pointer focus.
    
    If multiple pointer bindings would be triggered by a single physical
    pointer event on the compositor side, it is compositor policy which
    pointer binding(s) will receive press/release events or if all of the
    matched pointer bindings receive press/release events. *)
module River_pointer_binding_v1 = struct
  type 'v t = ([`River_pointer_binding_v1], 'v, [`Client]) Proxy.t
  
  (** {2 Version 1, 2, 3, 4, 5} *)
  
  (** Disable the pointer binding.
      
      This request may be used to temporarily disable the pointer binding. It
      may be later re-enabled with the enable request.
      
      This request modifies window management state and may only be made as
      part of a manage sequence, see the river_window_manager_v1 description. *)
  let disable (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:2 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (** Enable the pointer binding.
      
      This request should be made after all initial configuration has been
      completed and the window manager wishes the pointer binding to be able
      to be triggered.
      
      This request modifies window management state and may only be made as
      part of a manage sequence, see the river_window_manager_v1 description. *)
  let enable (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:1 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (** Destroy the pointer binding object.
      
      This request indicates that the client will no longer use the pointer
      binding object and that it may be safely destroyed. *)
  let destroy (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:0 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg;
    Proxy.shutdown_send _t
  
  (**/**)
  class virtual ['v] _handlers_unsafe = object (_self : (_, 'v, _) #Proxy.Handler.t)
    method user_data = S.No_data
    method metadata = (module River_window_management_v1_proto.River_pointer_binding_v1)
    method max_version = 5l
    
    method private virtual on_pressed : [> ] t -> unit
    
    method private virtual on_released : [> ] t -> unit
    
    
    method dispatch (_proxy : 'v t) _msg =
      let _proxy = Proxy.cast_version _proxy in
      match Msg.op _msg with
      | 0 ->
        _self#on_pressed _proxy 
      | 1 ->
        _self#on_released _proxy 
      | _ -> assert false
  end
  (**/**)
  
  (** {2 Handlers}
      Note: Servers will always want to use [v1].
   *)
  
  
  (** Handler for a proxy with version >= 1. *)
  class virtual ['v] v1 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V1 | `V2 | `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_pressed : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** The bound pointer button has been pressed.
        
        This event indicates that the pointer button triggering the binding has
        been pressed.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server.
        
        The compositor should wait for the manage sequence to complete before
        processing further input events. This allows the window manager client
        to, for example, modify key bindings and keyboard focus without racing
        against future input events. The window manager should of course respond
        as soon as possible as the capacity of the compositor to buffer incoming
        input events is finite. *)
    
    method private virtual on_released : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** The bound pointer button has been released.
        
        This event indicates that the pointer button triggering the binding has
        been released.
        
        Releasing the modifiers for the binding without releasing the pointer
        button does not trigger the release event. This event is sent when the
        pointer button is released, even if the modifiers have changed since the
        pressed event.
        
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
  class virtual ['v] v2 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V2 | `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_pressed : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** The bound pointer button has been pressed.
        
        This event indicates that the pointer button triggering the binding has
        been pressed.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server.
        
        The compositor should wait for the manage sequence to complete before
        processing further input events. This allows the window manager client
        to, for example, modify key bindings and keyboard focus without racing
        against future input events. The window manager should of course respond
        as soon as possible as the capacity of the compositor to buffer incoming
        input events is finite. *)
    
    method private virtual on_released : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** The bound pointer button has been released.
        
        This event indicates that the pointer button triggering the binding has
        been released.
        
        Releasing the modifiers for the binding without releasing the pointer
        button does not trigger the release event. This event is sent when the
        pointer button is released, even if the modifiers have changed since the
        pressed event.
        
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
  class virtual ['v] v3 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_pressed : [> `V3 | `V4 | `V5] t -> unit
    
    (** The bound pointer button has been pressed.
        
        This event indicates that the pointer button triggering the binding has
        been pressed.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server.
        
        The compositor should wait for the manage sequence to complete before
        processing further input events. This allows the window manager client
        to, for example, modify key bindings and keyboard focus without racing
        against future input events. The window manager should of course respond
        as soon as possible as the capacity of the compositor to buffer incoming
        input events is finite. *)
    
    method private virtual on_released : [> `V3 | `V4 | `V5] t -> unit
    
    (** The bound pointer button has been released.
        
        This event indicates that the pointer button triggering the binding has
        been released.
        
        Releasing the modifiers for the binding without releasing the pointer
        button does not trigger the release event. This event is sent when the
        pointer button is released, even if the modifiers have changed since the
        pressed event.
        
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
  
  (** Handler for a proxy with version >= 4. *)
  class virtual ['v] v4 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_pressed : [> `V4 | `V5] t -> unit
    
    (** The bound pointer button has been pressed.
        
        This event indicates that the pointer button triggering the binding has
        been pressed.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server.
        
        The compositor should wait for the manage sequence to complete before
        processing further input events. This allows the window manager client
        to, for example, modify key bindings and keyboard focus without racing
        against future input events. The window manager should of course respond
        as soon as possible as the capacity of the compositor to buffer incoming
        input events is finite. *)
    
    method private virtual on_released : [> `V4 | `V5] t -> unit
    
    (** The bound pointer button has been released.
        
        This event indicates that the pointer button triggering the binding has
        been released.
        
        Releasing the modifiers for the binding without releasing the pointer
        button does not trigger the release event. This event is sent when the
        pointer button is released, even if the modifiers have changed since the
        pressed event.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server.
        
        The compositor should wait for the manage sequence to complete before
        processing further input events. This allows the window manager client
        to, for example, modify key bindings and keyboard focus without racing
        against future input events. The window manager should of course respond
        as soon as possible as the capacity of the compositor to buffer incoming
        input events is finite. *)
    
    method min_version = 4l
  end
  
  (** Handler for a proxy with version >= 5. *)
  class virtual ['v] v5 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_pressed : [> `V5] t -> unit
    
    (** The bound pointer button has been pressed.
        
        This event indicates that the pointer button triggering the binding has
        been pressed.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server.
        
        The compositor should wait for the manage sequence to complete before
        processing further input events. This allows the window manager client
        to, for example, modify key bindings and keyboard focus without racing
        against future input events. The window manager should of course respond
        as soon as possible as the capacity of the compositor to buffer incoming
        input events is finite. *)
    
    method private virtual on_released : [> `V5] t -> unit
    
    (** The bound pointer button has been released.
        
        This event indicates that the pointer button triggering the binding has
        been released.
        
        Releasing the modifiers for the binding without releasing the pointer
        button does not trigger the release event. This event is sent when the
        pointer button is released, even if the modifiers have changed since the
        pressed event.
        
        This event will be followed by a manage_start event after all other new
        state has been sent by the server.
        
        The compositor should wait for the manage sequence to complete before
        processing further input events. This allows the window manager client
        to, for example, modify key bindings and keyboard focus without racing
        against future input events. The window manager should of course respond
        as soon as possible as the capacity of the compositor to buffer incoming
        input events is finite. *)
    
    method min_version = 5l
  end
end