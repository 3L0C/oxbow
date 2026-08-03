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
  type 'v t = ([`River_window_manager_v1], 'v, [`Server]) Proxy.t
  module Error = River_window_management_v1_proto.River_window_manager_v1.Error
  
  (** {2 Version 1, 2, 3} *)
  
  (** New seat.
      
      A new seat has been created.
      
      This event will be followed by a manage_start event after all other new
      state has been sent by the server. *)
  let seat (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) (id:([`River_seat_v1], 'v, [`Server]) #Proxy.Handler.t) =
    let __id = Proxy.spawn _t id in
    let _msg = Proxy.alloc _t ~op:8 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id __id);
    Proxy.send _t _msg;
    __id
  
  (** New output.
      
      A new logical output has been created, perhaps due to a new physical
      monitor being plugged in or perhaps due to a change in configuration.
      
      This event will be followed by river_output_v1.position and dimensions
      events as well as a manage_start event after all other new state has
      been sent by the server. *)
  let output (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) (id:([`River_output_v1], 'v, [`Server]) #Proxy.Handler.t) =
    let __id = Proxy.spawn _t id in
    let _msg = Proxy.alloc _t ~op:7 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id __id);
    Proxy.send _t _msg;
    __id
  
  (** New window.
      
      A new window has been created.
      
      This event will be followed by a manage_start event after all other new
      state has been sent by the server. *)
  let window (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) (id:([`River_window_v1], 'v, [`Server]) #Proxy.Handler.t) =
    let __id = Proxy.spawn _t id in
    let _msg = Proxy.alloc _t ~op:6 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id __id);
    Proxy.send _t _msg;
    __id
  
  (** The session has been unlocked.
      
      This event indicates that the session has been unlocked.
      
      This event will be followed by a manage_start event after all other new
      state has been sent by the server. *)
  let session_unlocked (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) 
     =
    let _msg = Proxy.alloc _t ~op:5 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (** The session has been locked.
      
      This event indicates that the session has been locked.
      
      The window manager may wish to restrict which key bindings are available
      while locked or otherwise use this information.
      
      If the session is currently locked when the river_window_manager_v1
      object is created, the session_locked event will be sent in the first
      manage sequence.
      
      This event will be followed by a manage_start event after all other new
      state has been sent by the server. *)
  let session_locked (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:4 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (** Start a render sequence.
      
      This event indicates that the server has sent all
      river_window_v1.dimensions events necessary.
      
      In response to this event, the client should make requests modifying
      rendering state as it chooses. Then, the client must make the
      render_finish request.
      
      See the description of the river_window_manager_v1 interface for a
      complete overview of the manage/render sequence loop. *)
  let render_start (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:3 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (** Start a manage sequence.
      
      This event indicates that the server has sent events indicating all
      state changes since the last manage sequence.
      
      In response to this event, the client should make requests modifying
      window management state as it chooses. Then, the client must make the
      manage_finish request.
      
      See the description of the river_window_manager_v1 interface for a
      complete overview of the manage/render sequence loop. *)
  let manage_start (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:2 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (** The server has finished with the window manager.
      
      This event indicates that the server will send no further events on this
      object. The client should destroy the object. See
      river_window_manager_v1.destroy for more information. *)
  let finished (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:1 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (** Window management unavailable.
      
      This event indicates that window management is not available to the
      client, perhaps due to another window management client already running.
      The circumstances causing this event to be sent are compositor policy.
      
      If sent, this event is guaranteed to be the first and only event sent by
      the server.
      
      The server will send no further events on this object. The client should
      destroy this object and all objects created through this interface. *)
  let unavailable (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:0 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  
  (** {2 Version 4, 5} *)
  
  (**/**)
  class virtual ['v] _handlers_unsafe = object (_self : (_, 'v, _) #Proxy.Handler.t)
    method user_data = S.No_data
    method metadata = (module River_window_management_v1_proto.River_window_manager_v1)
    method max_version = 5l
    
    method private virtual on_stop : [> ] t -> unit
    
    method private virtual on_destroy : [> ] t -> unit
    
    method private virtual on_manage_finish : [> ] t -> unit
    
    method private virtual on_manage_dirty : [> ] t -> unit
    
    method private virtual on_render_finish : [> ] t -> unit
    
    method private virtual on_get_shell_surface : [> ] t -> ([`River_shell_surface_v1], 'v, [`Server]) Proxy.t ->
                                                  surface:([`Wl_surface], [> Imports.Wl_surface.versions], [`Server]) Proxy.t ->
                                                  unit
    
    method private virtual on_exit_session : [> ] t -> unit
    
    
    method dispatch (_proxy : 'v t) _msg =
      let _proxy = Proxy.cast_version _proxy in
      match Msg.op _msg with
      | 0 ->
        _self#on_stop _proxy 
      | 1 ->
        Proxy.shutdown_recv _proxy;
        _self#on_destroy _proxy 
      | 2 ->
        _self#on_manage_finish _proxy 
      | 3 ->
        _self#on_manage_dirty _proxy 
      | 4 ->
        _self#on_render_finish _proxy 
      | 5 ->
        let id : ([`River_shell_surface_v1], _, _) Proxy.t =
          Msg.get_int _msg |> Proxy.Handler.accept_new _proxy (module Imports.River_shell_surface_v1) in
        let surface : ([`Wl_surface], _, _) Proxy.t =
          let Proxy.Proxy p = Msg.get_int _msg |> Proxy.lookup_other _proxy in
          match Proxy.ty p with
          | Imports.Wl_surface.T -> p
          | _ -> Proxy.wrong_type ~parent:_proxy ~expected:"wl_surface" p
          in
        _self#on_get_shell_surface _proxy id ~surface
      | 6 ->
        _self#on_exit_session _proxy 
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
    method private virtual on_stop : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Stop sending events.
        
        This request indicates that the client no longer wishes to receive
        events on this object.
        
        The Wayland protocol is asynchronous, which means the server may send
        further events until the stop request is processed. The client must wait
        for a river_window_manager_v1.finished event before destroying this
        object. *)
    
    method private virtual on_destroy : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Destroy the river_window_manager_v1 object.
        
        This request should be called after the finished event has been received
        to complete destruction of the object.
        
        If a client wishes to destroy this object it should send a
        river_window_manager_v1.stop request and wait for a
        river_window_manager_v1.finished event. Once the finished event is
        received it is safe to destroy this object and any other objects created
        through this interface. *)
    
    method private virtual on_manage_finish : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
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
    
    method private virtual on_manage_dirty : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Ensure a manage sequence is started.
        
        This request ensures a manage sequence is started and that a
        manage_start event is sent by the server. If this request is made during
        an ongoing manage sequence, a new manage sequence will be started as
        soon as the current one is completed.
        
        The client may want to use this request due to an internal state change
        that the compositor is not aware of (e.g. a dbus event) which should
        affect window management or rendering state. *)
    
    method private virtual on_render_finish : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
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
    
    method private virtual on_get_shell_surface : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> ([`River_shell_surface_v1], 'v, [`Server]) Proxy.t ->
                                                  surface:([`Wl_surface], [> Imports.Wl_surface.versions], [`Server]) Proxy.t ->
                                                  unit
    
    (** Assign the river_shell_surface_v1 surface role.
        
        Create a new shell surface for window manager UI and assign the
        river_shell_surface_v1 role to the surface.
        
        Providing a wl_surface which already has a role or already has a buffer
        attached or committed is a protocol error. *)
    
    method private virtual on_exit_session : [> `V4 | `V5] t -> unit
    
    (** Exit the Wayland session.
        
        End the current Wayland session and exit the compositor.
        All Wayland clients running in the current session, including
        the window manager, will be disconnected.
        
        Window managers should only make this request if the user explicitly
        asks to exit the Wayland session, not for example on normal window
        manager termination. *)
    
    method min_version = 1l
    method bind_version : [`V1] = `V1
  end
  
  (** Handler for a proxy with version >= 2. *)
  class virtual ['v] v2 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V2 | `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_stop : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Stop sending events.
        
        This request indicates that the client no longer wishes to receive
        events on this object.
        
        The Wayland protocol is asynchronous, which means the server may send
        further events until the stop request is processed. The client must wait
        for a river_window_manager_v1.finished event before destroying this
        object. *)
    
    method private virtual on_destroy : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Destroy the river_window_manager_v1 object.
        
        This request should be called after the finished event has been received
        to complete destruction of the object.
        
        If a client wishes to destroy this object it should send a
        river_window_manager_v1.stop request and wait for a
        river_window_manager_v1.finished event. Once the finished event is
        received it is safe to destroy this object and any other objects created
        through this interface. *)
    
    method private virtual on_manage_finish : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
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
    
    method private virtual on_manage_dirty : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Ensure a manage sequence is started.
        
        This request ensures a manage sequence is started and that a
        manage_start event is sent by the server. If this request is made during
        an ongoing manage sequence, a new manage sequence will be started as
        soon as the current one is completed.
        
        The client may want to use this request due to an internal state change
        that the compositor is not aware of (e.g. a dbus event) which should
        affect window management or rendering state. *)
    
    method private virtual on_render_finish : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
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
    
    method private virtual on_get_shell_surface : [> `V2 | `V3 | `V4 | `V5] t -> ([`River_shell_surface_v1], 'v, [`Server]) Proxy.t ->
                                                  surface:([`Wl_surface], [> Imports.Wl_surface.versions], [`Server]) Proxy.t ->
                                                  unit
    
    (** Assign the river_shell_surface_v1 surface role.
        
        Create a new shell surface for window manager UI and assign the
        river_shell_surface_v1 role to the surface.
        
        Providing a wl_surface which already has a role or already has a buffer
        attached or committed is a protocol error. *)
    
    method private virtual on_exit_session : [> `V4 | `V5] t -> unit
    
    (** Exit the Wayland session.
        
        End the current Wayland session and exit the compositor.
        All Wayland clients running in the current session, including
        the window manager, will be disconnected.
        
        Window managers should only make this request if the user explicitly
        asks to exit the Wayland session, not for example on normal window
        manager termination. *)
    
    method min_version = 2l
    method bind_version : [`V2] = `V2
  end
  
  (** Handler for a proxy with version >= 3. *)
  class virtual ['v] v3 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_stop : [> `V3 | `V4 | `V5] t -> unit
    
    (** Stop sending events.
        
        This request indicates that the client no longer wishes to receive
        events on this object.
        
        The Wayland protocol is asynchronous, which means the server may send
        further events until the stop request is processed. The client must wait
        for a river_window_manager_v1.finished event before destroying this
        object. *)
    
    method private virtual on_destroy : [> `V3 | `V4 | `V5] t -> unit
    
    (** Destroy the river_window_manager_v1 object.
        
        This request should be called after the finished event has been received
        to complete destruction of the object.
        
        If a client wishes to destroy this object it should send a
        river_window_manager_v1.stop request and wait for a
        river_window_manager_v1.finished event. Once the finished event is
        received it is safe to destroy this object and any other objects created
        through this interface. *)
    
    method private virtual on_manage_finish : [> `V3 | `V4 | `V5] t -> unit
    
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
    
    method private virtual on_manage_dirty : [> `V3 | `V4 | `V5] t -> unit
    
    (** Ensure a manage sequence is started.
        
        This request ensures a manage sequence is started and that a
        manage_start event is sent by the server. If this request is made during
        an ongoing manage sequence, a new manage sequence will be started as
        soon as the current one is completed.
        
        The client may want to use this request due to an internal state change
        that the compositor is not aware of (e.g. a dbus event) which should
        affect window management or rendering state. *)
    
    method private virtual on_render_finish : [> `V3 | `V4 | `V5] t -> unit
    
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
    
    method private virtual on_get_shell_surface : [> `V3 | `V4 | `V5] t -> ([`River_shell_surface_v1], 'v, [`Server]) Proxy.t ->
                                                  surface:([`Wl_surface], [> Imports.Wl_surface.versions], [`Server]) Proxy.t ->
                                                  unit
    
    (** Assign the river_shell_surface_v1 surface role.
        
        Create a new shell surface for window manager UI and assign the
        river_shell_surface_v1 role to the surface.
        
        Providing a wl_surface which already has a role or already has a buffer
        attached or committed is a protocol error. *)
    
    method private virtual on_exit_session : [> `V4 | `V5] t -> unit
    
    (** Exit the Wayland session.
        
        End the current Wayland session and exit the compositor.
        All Wayland clients running in the current session, including
        the window manager, will be disconnected.
        
        Window managers should only make this request if the user explicitly
        asks to exit the Wayland session, not for example on normal window
        manager termination. *)
    
    method min_version = 3l
    method bind_version : [`V3] = `V3
  end
  
  (** Handler for a proxy with version >= 4. *)
  class virtual ['v] v4 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_stop : [> `V4 | `V5] t -> unit
    
    (** Stop sending events.
        
        This request indicates that the client no longer wishes to receive
        events on this object.
        
        The Wayland protocol is asynchronous, which means the server may send
        further events until the stop request is processed. The client must wait
        for a river_window_manager_v1.finished event before destroying this
        object. *)
    
    method private virtual on_destroy : [> `V4 | `V5] t -> unit
    
    (** Destroy the river_window_manager_v1 object.
        
        This request should be called after the finished event has been received
        to complete destruction of the object.
        
        If a client wishes to destroy this object it should send a
        river_window_manager_v1.stop request and wait for a
        river_window_manager_v1.finished event. Once the finished event is
        received it is safe to destroy this object and any other objects created
        through this interface. *)
    
    method private virtual on_manage_finish : [> `V4 | `V5] t -> unit
    
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
    
    method private virtual on_manage_dirty : [> `V4 | `V5] t -> unit
    
    (** Ensure a manage sequence is started.
        
        This request ensures a manage sequence is started and that a
        manage_start event is sent by the server. If this request is made during
        an ongoing manage sequence, a new manage sequence will be started as
        soon as the current one is completed.
        
        The client may want to use this request due to an internal state change
        that the compositor is not aware of (e.g. a dbus event) which should
        affect window management or rendering state. *)
    
    method private virtual on_render_finish : [> `V4 | `V5] t -> unit
    
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
    
    method private virtual on_get_shell_surface : [> `V4 | `V5] t -> ([`River_shell_surface_v1], 'v, [`Server]) Proxy.t ->
                                                  surface:([`Wl_surface], [> Imports.Wl_surface.versions], [`Server]) Proxy.t ->
                                                  unit
    
    (** Assign the river_shell_surface_v1 surface role.
        
        Create a new shell surface for window manager UI and assign the
        river_shell_surface_v1 role to the surface.
        
        Providing a wl_surface which already has a role or already has a buffer
        attached or committed is a protocol error. *)
    
    method private virtual on_exit_session : [> `V4 | `V5] t -> unit
    
    (** Exit the Wayland session.
        
        End the current Wayland session and exit the compositor.
        All Wayland clients running in the current session, including
        the window manager, will be disconnected.
        
        Window managers should only make this request if the user explicitly
        asks to exit the Wayland session, not for example on normal window
        manager termination. *)
    
    method min_version = 4l
    method bind_version : [`V4] = `V4
  end
  
  (** Handler for a proxy with version >= 5. *)
  class virtual ['v] v5 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_stop : [> `V5] t -> unit
    
    (** Stop sending events.
        
        This request indicates that the client no longer wishes to receive
        events on this object.
        
        The Wayland protocol is asynchronous, which means the server may send
        further events until the stop request is processed. The client must wait
        for a river_window_manager_v1.finished event before destroying this
        object. *)
    
    method private virtual on_destroy : [> `V5] t -> unit
    
    (** Destroy the river_window_manager_v1 object.
        
        This request should be called after the finished event has been received
        to complete destruction of the object.
        
        If a client wishes to destroy this object it should send a
        river_window_manager_v1.stop request and wait for a
        river_window_manager_v1.finished event. Once the finished event is
        received it is safe to destroy this object and any other objects created
        through this interface. *)
    
    method private virtual on_manage_finish : [> `V5] t -> unit
    
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
    
    method private virtual on_manage_dirty : [> `V5] t -> unit
    
    (** Ensure a manage sequence is started.
        
        This request ensures a manage sequence is started and that a
        manage_start event is sent by the server. If this request is made during
        an ongoing manage sequence, a new manage sequence will be started as
        soon as the current one is completed.
        
        The client may want to use this request due to an internal state change
        that the compositor is not aware of (e.g. a dbus event) which should
        affect window management or rendering state. *)
    
    method private virtual on_render_finish : [> `V5] t -> unit
    
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
    
    method private virtual on_get_shell_surface : [> `V5] t -> ([`River_shell_surface_v1], 'v, [`Server]) Proxy.t ->
                                                  surface:([`Wl_surface], [> Imports.Wl_surface.versions], [`Server]) Proxy.t ->
                                                  unit
    
    (** Assign the river_shell_surface_v1 surface role.
        
        Create a new shell surface for window manager UI and assign the
        river_shell_surface_v1 role to the surface.
        
        Providing a wl_surface which already has a role or already has a buffer
        attached or committed is a protocol error. *)
    
    method private virtual on_exit_session : [> `V5] t -> unit
    
    (** Exit the Wayland session.
        
        End the current Wayland session and exit the compositor.
        All Wayland clients running in the current session, including
        the window manager, will be disconnected.
        
        Window managers should only make this request if the user explicitly
        asks to exit the Wayland session, not for example on normal window
        manager termination. *)
    
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
  type 'v t = ([`River_window_v1], 'v, [`Server]) Proxy.t
  module Error = River_window_management_v1_proto.River_window_v1.Error
  
  module Decoration_hint = River_window_management_v1_proto.River_window_v1.Decoration_hint
  
  module Edges = River_window_management_v1_proto.River_window_v1.Edges
  
  module Capabilities = River_window_management_v1_proto.River_window_v1.Capabilities
  
  (** {2 Version 1} *)
  
  (** The window requested to be minimized.
      
      The xdg-shell protocol for example allows windows to request to be
      minimized.
      
      The window manager is free to ignore this request, hide the window, or
      do whatever else it chooses.
      
      This event will be followed by a manage_start event after all other new
      state has been sent by the server. *)
  let minimize_requested (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) 
     =
    let _msg = Proxy.alloc _t ~op:14 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (** The window requested to exit fullscreen.
      
      The xdg-shell protocol for example allows windows to request to exit
      fullscreen.
      
      The window manager is free to honor this request using
      river_window_v1.exit_fullscreen or ignore it.
      
      This event will be followed by a manage_start event after all other new
      state has been sent by the server. *)
  let exit_fullscreen_requested (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) 
     =
    let _msg = Proxy.alloc _t ~op:13 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (** The window requested to be fullscreen.
      
      The xdg-shell protocol for example allows windows to request that they
      be made fullscreen and allows them to provide an optional output hint.
      
      If the output argument is null, the window has no preference and the
      window manager should choose an output.
      
      The window manager is free to honor this request using
      river_window_v1.fullscreen or ignore it.
      
      This event will be followed by a manage_start event after all other new
      state has been sent by the server. *)
  let fullscreen_requested (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) 
    ~(output:([`River_output_v1], _, [`Server]) Proxy.t option) =
    let _msg = Proxy.alloc _t ~op:12 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id_opt output);
    Proxy.send _t _msg
  
  (** The window requested to be unmaximized.
      
      The xdg-shell protocol for example allows windows to request to be
      unmaximized.
      
      The window manager is free to honor this request using
      river_window_v1.inform_unmaximized or ignore it.
      
      This event will be followed by a manage_start event after all other new
      state has been sent by the server. *)
  let unmaximize_requested (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) 
     =
    let _msg = Proxy.alloc _t ~op:11 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (** The window requested to be maximized.
      
      The xdg-shell protocol for example allows windows to request to be
      maximized.
      
      The window manager is free to honor this request using
      river_window_v1.inform_maximized or ignore it.
      
      This event will be followed by a manage_start event after all other new
      state has been sent by the server. *)
  let maximize_requested (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) 
     =
    let _msg = Proxy.alloc _t ~op:10 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
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
  let show_window_menu_requested (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) 
    ~x ~y =
    let _msg = Proxy.alloc _t ~op:9 ~ints:2 ~strings:[] ~arrays:[] in
    Msg.add_int _msg x;
    Msg.add_int _msg y;
    Proxy.send _t _msg
  
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
  let pointer_resize_requested (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) 
    ~(seat:([`River_seat_v1], _, [`Server]) Proxy.t) ~edges =
    let _msg = Proxy.alloc _t ~op:8 ~ints:2 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id seat);
    Msg.add_int _msg (Imports.River_window_v1.Edges.to_int32 edges);
    Proxy.send _t _msg
  
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
  let pointer_move_requested (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) 
    ~(seat:([`River_seat_v1], _, [`Server]) Proxy.t) =
    let _msg = Proxy.alloc _t ~op:7 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id seat);
    Proxy.send _t _msg
  
  (** Supported/preferred decoration style.
      
      Information from the window about the supported and preferred client
      side/server side decoration options.
      
      This event may be sent multiple times over the lifetime of the window if
      the window changes its preferences.
      
      This event will be followed by a manage_start event after all other new
      state has been sent by the server. *)
  let decoration_hint (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) 
    ~hint =
    let _msg = Proxy.alloc _t ~op:6 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Imports.River_window_v1.Decoration_hint.to_int32 hint);
    Proxy.send _t _msg
  
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
  let parent (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) ~(parent:([`River_window_v1], _, [`Server]) Proxy.t option) =
    let _msg = Proxy.alloc _t ~op:5 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id_opt parent);
    Proxy.send _t _msg
  
  (** The window set a title.
      
      The window set a title.
      
      The title argument will be null if the window has never set a title or
      if the window cleared its title. (Xwayland windows may do this for
      example, though xdg-toplevels may not.)
      
      This event will be followed by a manage_start event after all other new
      state has been sent by the server. *)
  let title (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) ~title =
    let _msg = Proxy.alloc _t ~op:4 ~ints:1 ~strings:[title] ~arrays:[] in
    Msg.add_string_opt _msg title;
    Proxy.send _t _msg
  
  (** The window set an application ID.
      
      The window set an application ID.
      
      The app_id argument will be null if the window has never set an
      application ID or if the window cleared its application ID. (Xwayland
      windows may do this for example, though xdg-toplevels may not.)
      
      This event will be followed by a manage_start event after all other new
      state has been sent by the server. *)
  let app_id (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) ~app_id =
    let _msg = Proxy.alloc _t ~op:3 ~ints:1 ~strings:[app_id] ~arrays:[] in
    Msg.add_string_opt _msg app_id;
    Proxy.send _t _msg
  
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
  let dimensions (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) ~width ~height =
    let _msg = Proxy.alloc _t ~op:2 ~ints:2 ~strings:[] ~arrays:[] in
    Msg.add_int _msg width;
    Msg.add_int _msg height;
    Proxy.send _t _msg
  
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
  let dimensions_hint (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) 
    ~min_width ~min_height ~max_width ~max_height =
    let _msg = Proxy.alloc _t ~op:1 ~ints:4 ~strings:[] ~arrays:[] in
    Msg.add_int _msg min_width;
    Msg.add_int _msg min_height;
    Msg.add_int _msg max_width;
    Msg.add_int _msg max_height;
    Proxy.send _t _msg
  
  (** The window has been closed.
      
      The window has been closed by the server, perhaps due to an
      xdg_toplevel.close request or similar.
      
      The server will send no further events on this object and ignore any
      request other than river_window_v1.destroy made after this event is
      sent. The client should destroy this object with the
      river_window_v1.destroy request to free up resources.
      
      This event will be followed by a manage_start event after all other new
      state has been sent by the server. *)
  let closed (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:0 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  
  (** {2 Version 2} *)
  
  (** Unreliable PID of the window's creator.
      
      This event gives an unreliable PID of the process that created the
      window. Obtaining this information is inherently racy due to PID reuse.
      Therefore, this PID must not be used for anything security sensitive.
      
      Note also that a single process may create multiple windows, so there is
      not necessarily a 1-to-1 mapping from PID to window. Multiple windows
      may have the same PID.
      
      This event is sent once when the river_window_v1 is created and never
      sent again. *)
  let unreliable_pid (_t:([< `V2 | `V3 | `V4 | `V5] as 'v) t) ~unreliable_pid =
    let _msg = Proxy.alloc _t ~op:15 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg unreliable_pid;
    Proxy.send _t _msg
  
  
  (** {2 Version 3} *)
  
  
  (** {2 Version 4} *)
  
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
  let identifier (_t:([< `V4 | `V5] as 'v) t) ~identifier =
    let _msg = Proxy.alloc _t ~op:17 ~ints:1 ~strings:[(Some identifier)] ~arrays:[] in
    Msg.add_string _msg identifier;
    Proxy.send _t _msg
  
  (** Presentation hint set by the window.
      
      This event communicates the window's preferred presentation mode.
      
      This event will be followed by a render_start event after all other new
      state has been sent by the server. *)
  let presentation_hint (_t:([< `V4 | `V5] as 'v) t) ~hint =
    let _msg = Proxy.alloc _t ~op:16 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Imports.River_output_v1.Presentation_mode.to_int32 hint);
    Proxy.send _t _msg
  
  
  (** {2 Version 5} *)
  
  (** Window screen capture sessions.
      
      This event informs the window manager of the number of active screen
      capture sessions for the window.
      
      This event is sent once when the river_window_v1 is created and again
      whenever the number of capture sessions changes.
      
      This event will be followed by a manage_start event after all other new
      state has been sent by the server. *)
  let capture_sessions (_t:([< `V5] as 'v) t) ~count =
    let _msg = Proxy.alloc _t ~op:18 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg count;
    Proxy.send _t _msg
  
  (**/**)
  class virtual ['v] _handlers_unsafe = object (_self : (_, 'v, _) #Proxy.Handler.t)
    method user_data = S.No_data
    method metadata = (module River_window_management_v1_proto.River_window_v1)
    method max_version = 5l
    
    method private virtual on_destroy : [> ] t -> unit
    
    method private virtual on_close : [> ] t -> unit
    
    method private virtual on_get_node : [> ] t -> ([`River_node_v1], 'v, [`Server]) Proxy.t -> unit
    
    method private virtual on_propose_dimensions : [> ] t -> width:int32 -> height:int32 -> unit
    
    method private virtual on_hide : [> ] t -> unit
    
    method private virtual on_show : [> ] t -> unit
    
    method private virtual on_use_csd : [> ] t -> unit
    
    method private virtual on_use_ssd : [> ] t -> unit
    
    method private virtual on_set_borders : [> ] t -> edges:Imports.River_window_v1.Edges.t -> width:int32 ->
                                            r:int32 -> g:int32 -> b:int32 -> a:int32 -> unit
    
    method private virtual on_set_tiled : [> ] t -> edges:Imports.River_window_v1.Edges.t -> unit
    
    method private virtual on_get_decoration_above : [> ] t -> ([`River_decoration_v1], 'v, [`Server]) Proxy.t ->
                                                     surface:([`Wl_surface], [> Imports.Wl_surface.versions], [`Server]) Proxy.t ->
                                                     unit
    
    method private virtual on_get_decoration_below : [> ] t -> ([`River_decoration_v1], 'v, [`Server]) Proxy.t ->
                                                     surface:([`Wl_surface], [> Imports.Wl_surface.versions], [`Server]) Proxy.t ->
                                                     unit
    
    method private virtual on_inform_resize_start : [> ] t -> unit
    
    method private virtual on_inform_resize_end : [> ] t -> unit
    
    method private virtual on_set_capabilities : [> ] t -> caps:Imports.River_window_v1.Capabilities.t -> unit
    
    method private virtual on_inform_maximized : [> ] t -> unit
    
    method private virtual on_inform_unmaximized : [> ] t -> unit
    
    method private virtual on_inform_fullscreen : [> ] t -> unit
    
    method private virtual on_inform_not_fullscreen : [> ] t -> unit
    
    method private virtual on_fullscreen : [> ] t -> output:([`River_output_v1], [> Imports.River_output_v1.versions], [`Server]) Proxy.t ->
                                           unit
    
    method private virtual on_exit_fullscreen : [> ] t -> unit
    
    method private virtual on_set_clip_box : [> ] t -> x:int32 -> y:int32 -> width:int32 -> height:int32 -> unit
    
    method private virtual on_set_content_clip_box : [> ] t -> x:int32 -> y:int32 -> width:int32 -> height:int32 ->
                                                     unit
    
    method private virtual on_set_dimension_bounds : [> ] t -> max_width:int32 -> max_height:int32 -> unit
    
    
    method dispatch (_proxy : 'v t) _msg =
      let _proxy = Proxy.cast_version _proxy in
      match Msg.op _msg with
      | 0 ->
        Proxy.shutdown_recv _proxy;
        _self#on_destroy _proxy 
      | 1 ->
        _self#on_close _proxy 
      | 2 ->
        let id : ([`River_node_v1], _, _) Proxy.t =
          Msg.get_int _msg |> Proxy.Handler.accept_new _proxy (module Imports.River_node_v1) in
        _self#on_get_node _proxy id
      | 3 ->
        let width = Msg.get_int _msg in
        let height = Msg.get_int _msg in
        _self#on_propose_dimensions _proxy ~width ~height
      | 4 ->
        _self#on_hide _proxy 
      | 5 ->
        _self#on_show _proxy 
      | 6 ->
        _self#on_use_csd _proxy 
      | 7 ->
        _self#on_use_ssd _proxy 
      | 8 ->
        let edges = Msg.get_int _msg |> Imports.River_window_v1.Edges.of_int32 in
        let width = Msg.get_int _msg in
        let r = Msg.get_int _msg in
        let g = Msg.get_int _msg in
        let b = Msg.get_int _msg in
        let a = Msg.get_int _msg in
        _self#on_set_borders _proxy ~edges ~width ~r ~g ~b ~a
      | 9 ->
        let edges = Msg.get_int _msg |> Imports.River_window_v1.Edges.of_int32 in
        _self#on_set_tiled _proxy ~edges
      | 10 ->
        let id : ([`River_decoration_v1], _, _) Proxy.t =
          Msg.get_int _msg |> Proxy.Handler.accept_new _proxy (module Imports.River_decoration_v1) in
        let surface : ([`Wl_surface], _, _) Proxy.t =
          let Proxy.Proxy p = Msg.get_int _msg |> Proxy.lookup_other _proxy in
          match Proxy.ty p with
          | Imports.Wl_surface.T -> p
          | _ -> Proxy.wrong_type ~parent:_proxy ~expected:"wl_surface" p
          in
        _self#on_get_decoration_above _proxy id ~surface
      | 11 ->
        let id : ([`River_decoration_v1], _, _) Proxy.t =
          Msg.get_int _msg |> Proxy.Handler.accept_new _proxy (module Imports.River_decoration_v1) in
        let surface : ([`Wl_surface], _, _) Proxy.t =
          let Proxy.Proxy p = Msg.get_int _msg |> Proxy.lookup_other _proxy in
          match Proxy.ty p with
          | Imports.Wl_surface.T -> p
          | _ -> Proxy.wrong_type ~parent:_proxy ~expected:"wl_surface" p
          in
        _self#on_get_decoration_below _proxy id ~surface
      | 12 ->
        _self#on_inform_resize_start _proxy 
      | 13 ->
        _self#on_inform_resize_end _proxy 
      | 14 ->
        let caps = Msg.get_int _msg |> Imports.River_window_v1.Capabilities.of_int32 in
        _self#on_set_capabilities _proxy ~caps
      | 15 ->
        _self#on_inform_maximized _proxy 
      | 16 ->
        _self#on_inform_unmaximized _proxy 
      | 17 ->
        _self#on_inform_fullscreen _proxy 
      | 18 ->
        _self#on_inform_not_fullscreen _proxy 
      | 19 ->
        let output : ([`River_output_v1], _, _) Proxy.t =
          let Proxy.Proxy p = Msg.get_int _msg |> Proxy.lookup_other _proxy in
          match Proxy.ty p with
          | Imports.River_output_v1.T -> p
          | _ -> Proxy.wrong_type ~parent:_proxy ~expected:"river_output_v1" p
          in
        _self#on_fullscreen _proxy ~output
      | 20 ->
        _self#on_exit_fullscreen _proxy 
      | 21 ->
        let x = Msg.get_int _msg in
        let y = Msg.get_int _msg in
        let width = Msg.get_int _msg in
        let height = Msg.get_int _msg in
        _self#on_set_clip_box _proxy ~x ~y ~width ~height
      | 22 ->
        let x = Msg.get_int _msg in
        let y = Msg.get_int _msg in
        let width = Msg.get_int _msg in
        let height = Msg.get_int _msg in
        _self#on_set_content_clip_box _proxy ~x ~y ~width ~height
      | 23 ->
        let max_width = Msg.get_int _msg in
        let max_height = Msg.get_int _msg in
        _self#on_set_dimension_bounds _proxy ~max_width ~max_height
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
    method private virtual on_destroy : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Destroy the window object.
        
        This request indicates that the client will no longer use the window
        object and that it may be safely destroyed.
        
        This request should be made after the river_window_v1.closed event or
        river_window_manager_v1.finished is received to complete destruction of
        the window. *)
    
    method private virtual on_close : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Request that the window be closed.
        
        Request that the window be closed. The window may ignore this request or
        only close after some delay, perhaps opening a dialog asking the user to
        save their work or similar.
        
        The server will send a river_window_v1.closed event if/when the window
        has been closed.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_get_node : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> ([`River_node_v1], 'v, [`Server]) Proxy.t ->
                                         unit
    
    (** Get the window's render list node.
        
        Get the node in the render list corresponding to the window.
        
        It is a protocol error to make this request more than once for a single
        window. *)
    
    method private virtual on_propose_dimensions : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> width:int32 -> height:int32 ->
                                                   unit
    
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
    
    method private virtual on_hide : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Request that the window be hidden.
        
        Request that the window be hidden. Has no effect if the window is
        already hidden. Hides any window borders and decorations as well.
        
        Newly created windows are considered shown unless explicitly hidden with
        the hide request.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_show : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Request that the window be shown.
        
        Request that the window be shown. Has no effect if the window is not
        hidden. Does not guarantee that the window is visible as it may be
        completely obscured by other windows placed above it for example.
        
        Newly created windows are considered shown unless explicitly hidden with
        the hide request.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_use_csd : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Tell the client to use CSD.
        
        Tell the client to use client side decoration and draw its own title
        bar, borders, etc.
        
        This is the default if neither this request nor the use_ssd request is
        ever made.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_use_ssd : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Tell the client to use SSD.
        
        Tell the client to use server side decoration and not draw any client
        side decorations.
        
        This request will have no effect if the client only supports client side
        decoration, see the decoration_hint event.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_set_borders : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> edges:Imports.River_window_v1.Edges.t ->
                                            width:int32 -> r:int32 -> g:int32 -> b:int32 -> a:int32 -> unit
    
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
    
    method private virtual on_set_tiled : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> edges:Imports.River_window_v1.Edges.t ->
                                          unit
    
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
    
    method private virtual on_get_decoration_above : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> ([`River_decoration_v1], 'v, [`Server]) Proxy.t ->
                                                     surface:([`Wl_surface], [> Imports.Wl_surface.versions], [`Server]) Proxy.t ->
                                                     unit
    
    (** Create a decoration above the window in z-order.
        
        Create a decoration surface and assign the river_decoration_v1 role to
        the surface. The created decoration is placed above the window in
        rendering order, see the description of river_decoration_v1.
        
        Providing a wl_surface which already has a role or already has a buffer
        attached or committed is a protocol error. *)
    
    method private virtual on_get_decoration_below : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> ([`River_decoration_v1], 'v, [`Server]) Proxy.t ->
                                                     surface:([`Wl_surface], [> Imports.Wl_surface.versions], [`Server]) Proxy.t ->
                                                     unit
    
    (** Create a decoration below the window in z-order.
        
        Create a decoration surface and assign the river_decoration_v1 role to
        the surface. The created decoration is placed below the window in
        rendering order, see the description of river_decoration_v1.
        
        Providing a wl_surface which already has a role or already has a buffer
        attached or committed is a protocol error. *)
    
    method private virtual on_inform_resize_start : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Inform the window it is being resized.
        
        Inform the window that it is being resized. The window manager should
        use this request to inform windows that are the target of an interactive
        resize for example.
        
        The window manager remains responsible for handling the position and
        dimensions of the window while it is resizing.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_inform_resize_end : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Inform the window it no longer being resized.
        
        Inform the window that it is no longer being resized. The window manager
        should use this request to inform windows that are the target of an
        interactive resize that the interactive resize has ended for example.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_set_capabilities : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> caps:Imports.River_window_v1.Capabilities.t ->
                                                 unit
    
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
    
    method private virtual on_inform_maximized : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Inform the window that it is maximized.
        
        Inform the window that it is maximized. The window might use this
        information to adapt the style of its client-side window decorations for
        example.
        
        The window manager remains responsible for handling the position and
        dimensions of the window while it is maximized.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_inform_unmaximized : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Inform the window that it is unmaximized.
        
        Inform the window that it is unmaximized. The window might use this
        information to adapt the style of its client-side window decorations for
        example.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_inform_fullscreen : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Inform the window that it is fullscreen.
        
        Inform the window that it is fullscreen. The window might use this
        information to adapt the style of its client-side window decorations for
        example.
        
        This request does not affect the size/position of the window or cause it
        to become the only window rendered, see the river_window_v1.fullscreen
        and exit_fullscreen requests for that.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_inform_not_fullscreen : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Inform the window that it is not fullscreen.
        
        Inform the window that it is not fullscreen. The window might use this
        information to adapt the style of its client-side window decorations for
        example.
        
        This request does not affect the size/position of the window or cause it
        to become the only window rendered, see the river_window_v1.fullscreen
        and exit_fullscreen requests for that.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_fullscreen : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> output:([`River_output_v1], [> Imports.River_output_v1.versions], [`Server]) Proxy.t ->
                                           unit
    
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
    
    method private virtual on_exit_fullscreen : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
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
    
    method private virtual on_set_clip_box : [> `V2 | `V3 | `V4 | `V5] t -> x:int32 -> y:int32 -> width:int32 ->
                                             height:int32 -> unit
    
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
    
    method private virtual on_set_content_clip_box : [> `V3 | `V4 | `V5] t -> x:int32 -> y:int32 -> width:int32 ->
                                                     height:int32 -> unit
    
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
    
    method private virtual on_set_dimension_bounds : [> `V4 | `V5] t -> max_width:int32 -> max_height:int32 -> unit
    
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
    
    method min_version = 1l
  end
  
  (** Handler for a proxy with version >= 2. *)
  class virtual ['v] v2 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V2 | `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_destroy : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Destroy the window object.
        
        This request indicates that the client will no longer use the window
        object and that it may be safely destroyed.
        
        This request should be made after the river_window_v1.closed event or
        river_window_manager_v1.finished is received to complete destruction of
        the window. *)
    
    method private virtual on_close : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Request that the window be closed.
        
        Request that the window be closed. The window may ignore this request or
        only close after some delay, perhaps opening a dialog asking the user to
        save their work or similar.
        
        The server will send a river_window_v1.closed event if/when the window
        has been closed.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_get_node : [> `V2 | `V3 | `V4 | `V5] t -> ([`River_node_v1], 'v, [`Server]) Proxy.t ->
                                         unit
    
    (** Get the window's render list node.
        
        Get the node in the render list corresponding to the window.
        
        It is a protocol error to make this request more than once for a single
        window. *)
    
    method private virtual on_propose_dimensions : [> `V2 | `V3 | `V4 | `V5] t -> width:int32 -> height:int32 -> unit
    
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
    
    method private virtual on_hide : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Request that the window be hidden.
        
        Request that the window be hidden. Has no effect if the window is
        already hidden. Hides any window borders and decorations as well.
        
        Newly created windows are considered shown unless explicitly hidden with
        the hide request.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_show : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Request that the window be shown.
        
        Request that the window be shown. Has no effect if the window is not
        hidden. Does not guarantee that the window is visible as it may be
        completely obscured by other windows placed above it for example.
        
        Newly created windows are considered shown unless explicitly hidden with
        the hide request.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_use_csd : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Tell the client to use CSD.
        
        Tell the client to use client side decoration and draw its own title
        bar, borders, etc.
        
        This is the default if neither this request nor the use_ssd request is
        ever made.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_use_ssd : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Tell the client to use SSD.
        
        Tell the client to use server side decoration and not draw any client
        side decorations.
        
        This request will have no effect if the client only supports client side
        decoration, see the decoration_hint event.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_set_borders : [> `V2 | `V3 | `V4 | `V5] t -> edges:Imports.River_window_v1.Edges.t ->
                                            width:int32 -> r:int32 -> g:int32 -> b:int32 -> a:int32 -> unit
    
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
    
    method private virtual on_set_tiled : [> `V2 | `V3 | `V4 | `V5] t -> edges:Imports.River_window_v1.Edges.t -> unit
    
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
    
    method private virtual on_get_decoration_above : [> `V2 | `V3 | `V4 | `V5] t -> ([`River_decoration_v1], 'v, [`Server]) Proxy.t ->
                                                     surface:([`Wl_surface], [> Imports.Wl_surface.versions], [`Server]) Proxy.t ->
                                                     unit
    
    (** Create a decoration above the window in z-order.
        
        Create a decoration surface and assign the river_decoration_v1 role to
        the surface. The created decoration is placed above the window in
        rendering order, see the description of river_decoration_v1.
        
        Providing a wl_surface which already has a role or already has a buffer
        attached or committed is a protocol error. *)
    
    method private virtual on_get_decoration_below : [> `V2 | `V3 | `V4 | `V5] t -> ([`River_decoration_v1], 'v, [`Server]) Proxy.t ->
                                                     surface:([`Wl_surface], [> Imports.Wl_surface.versions], [`Server]) Proxy.t ->
                                                     unit
    
    (** Create a decoration below the window in z-order.
        
        Create a decoration surface and assign the river_decoration_v1 role to
        the surface. The created decoration is placed below the window in
        rendering order, see the description of river_decoration_v1.
        
        Providing a wl_surface which already has a role or already has a buffer
        attached or committed is a protocol error. *)
    
    method private virtual on_inform_resize_start : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Inform the window it is being resized.
        
        Inform the window that it is being resized. The window manager should
        use this request to inform windows that are the target of an interactive
        resize for example.
        
        The window manager remains responsible for handling the position and
        dimensions of the window while it is resizing.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_inform_resize_end : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Inform the window it no longer being resized.
        
        Inform the window that it is no longer being resized. The window manager
        should use this request to inform windows that are the target of an
        interactive resize that the interactive resize has ended for example.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_set_capabilities : [> `V2 | `V3 | `V4 | `V5] t -> caps:Imports.River_window_v1.Capabilities.t ->
                                                 unit
    
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
    
    method private virtual on_inform_maximized : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Inform the window that it is maximized.
        
        Inform the window that it is maximized. The window might use this
        information to adapt the style of its client-side window decorations for
        example.
        
        The window manager remains responsible for handling the position and
        dimensions of the window while it is maximized.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_inform_unmaximized : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Inform the window that it is unmaximized.
        
        Inform the window that it is unmaximized. The window might use this
        information to adapt the style of its client-side window decorations for
        example.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_inform_fullscreen : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Inform the window that it is fullscreen.
        
        Inform the window that it is fullscreen. The window might use this
        information to adapt the style of its client-side window decorations for
        example.
        
        This request does not affect the size/position of the window or cause it
        to become the only window rendered, see the river_window_v1.fullscreen
        and exit_fullscreen requests for that.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_inform_not_fullscreen : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Inform the window that it is not fullscreen.
        
        Inform the window that it is not fullscreen. The window might use this
        information to adapt the style of its client-side window decorations for
        example.
        
        This request does not affect the size/position of the window or cause it
        to become the only window rendered, see the river_window_v1.fullscreen
        and exit_fullscreen requests for that.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_fullscreen : [> `V2 | `V3 | `V4 | `V5] t -> output:([`River_output_v1], [> Imports.River_output_v1.versions], [`Server]) Proxy.t ->
                                           unit
    
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
    
    method private virtual on_exit_fullscreen : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
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
    
    method private virtual on_set_clip_box : [> `V2 | `V3 | `V4 | `V5] t -> x:int32 -> y:int32 -> width:int32 ->
                                             height:int32 -> unit
    
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
    
    method private virtual on_set_content_clip_box : [> `V3 | `V4 | `V5] t -> x:int32 -> y:int32 -> width:int32 ->
                                                     height:int32 -> unit
    
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
    
    method private virtual on_set_dimension_bounds : [> `V4 | `V5] t -> max_width:int32 -> max_height:int32 -> unit
    
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
    
    method min_version = 2l
  end
  
  (** Handler for a proxy with version >= 3. *)
  class virtual ['v] v3 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_destroy : [> `V3 | `V4 | `V5] t -> unit
    
    (** Destroy the window object.
        
        This request indicates that the client will no longer use the window
        object and that it may be safely destroyed.
        
        This request should be made after the river_window_v1.closed event or
        river_window_manager_v1.finished is received to complete destruction of
        the window. *)
    
    method private virtual on_close : [> `V3 | `V4 | `V5] t -> unit
    
    (** Request that the window be closed.
        
        Request that the window be closed. The window may ignore this request or
        only close after some delay, perhaps opening a dialog asking the user to
        save their work or similar.
        
        The server will send a river_window_v1.closed event if/when the window
        has been closed.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_get_node : [> `V3 | `V4 | `V5] t -> ([`River_node_v1], 'v, [`Server]) Proxy.t -> unit
    
    (** Get the window's render list node.
        
        Get the node in the render list corresponding to the window.
        
        It is a protocol error to make this request more than once for a single
        window. *)
    
    method private virtual on_propose_dimensions : [> `V3 | `V4 | `V5] t -> width:int32 -> height:int32 -> unit
    
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
    
    method private virtual on_hide : [> `V3 | `V4 | `V5] t -> unit
    
    (** Request that the window be hidden.
        
        Request that the window be hidden. Has no effect if the window is
        already hidden. Hides any window borders and decorations as well.
        
        Newly created windows are considered shown unless explicitly hidden with
        the hide request.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_show : [> `V3 | `V4 | `V5] t -> unit
    
    (** Request that the window be shown.
        
        Request that the window be shown. Has no effect if the window is not
        hidden. Does not guarantee that the window is visible as it may be
        completely obscured by other windows placed above it for example.
        
        Newly created windows are considered shown unless explicitly hidden with
        the hide request.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_use_csd : [> `V3 | `V4 | `V5] t -> unit
    
    (** Tell the client to use CSD.
        
        Tell the client to use client side decoration and draw its own title
        bar, borders, etc.
        
        This is the default if neither this request nor the use_ssd request is
        ever made.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_use_ssd : [> `V3 | `V4 | `V5] t -> unit
    
    (** Tell the client to use SSD.
        
        Tell the client to use server side decoration and not draw any client
        side decorations.
        
        This request will have no effect if the client only supports client side
        decoration, see the decoration_hint event.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_set_borders : [> `V3 | `V4 | `V5] t -> edges:Imports.River_window_v1.Edges.t ->
                                            width:int32 -> r:int32 -> g:int32 -> b:int32 -> a:int32 -> unit
    
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
    
    method private virtual on_set_tiled : [> `V3 | `V4 | `V5] t -> edges:Imports.River_window_v1.Edges.t -> unit
    
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
    
    method private virtual on_get_decoration_above : [> `V3 | `V4 | `V5] t -> ([`River_decoration_v1], 'v, [`Server]) Proxy.t ->
                                                     surface:([`Wl_surface], [> Imports.Wl_surface.versions], [`Server]) Proxy.t ->
                                                     unit
    
    (** Create a decoration above the window in z-order.
        
        Create a decoration surface and assign the river_decoration_v1 role to
        the surface. The created decoration is placed above the window in
        rendering order, see the description of river_decoration_v1.
        
        Providing a wl_surface which already has a role or already has a buffer
        attached or committed is a protocol error. *)
    
    method private virtual on_get_decoration_below : [> `V3 | `V4 | `V5] t -> ([`River_decoration_v1], 'v, [`Server]) Proxy.t ->
                                                     surface:([`Wl_surface], [> Imports.Wl_surface.versions], [`Server]) Proxy.t ->
                                                     unit
    
    (** Create a decoration below the window in z-order.
        
        Create a decoration surface and assign the river_decoration_v1 role to
        the surface. The created decoration is placed below the window in
        rendering order, see the description of river_decoration_v1.
        
        Providing a wl_surface which already has a role or already has a buffer
        attached or committed is a protocol error. *)
    
    method private virtual on_inform_resize_start : [> `V3 | `V4 | `V5] t -> unit
    
    (** Inform the window it is being resized.
        
        Inform the window that it is being resized. The window manager should
        use this request to inform windows that are the target of an interactive
        resize for example.
        
        The window manager remains responsible for handling the position and
        dimensions of the window while it is resizing.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_inform_resize_end : [> `V3 | `V4 | `V5] t -> unit
    
    (** Inform the window it no longer being resized.
        
        Inform the window that it is no longer being resized. The window manager
        should use this request to inform windows that are the target of an
        interactive resize that the interactive resize has ended for example.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_set_capabilities : [> `V3 | `V4 | `V5] t -> caps:Imports.River_window_v1.Capabilities.t ->
                                                 unit
    
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
    
    method private virtual on_inform_maximized : [> `V3 | `V4 | `V5] t -> unit
    
    (** Inform the window that it is maximized.
        
        Inform the window that it is maximized. The window might use this
        information to adapt the style of its client-side window decorations for
        example.
        
        The window manager remains responsible for handling the position and
        dimensions of the window while it is maximized.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_inform_unmaximized : [> `V3 | `V4 | `V5] t -> unit
    
    (** Inform the window that it is unmaximized.
        
        Inform the window that it is unmaximized. The window might use this
        information to adapt the style of its client-side window decorations for
        example.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_inform_fullscreen : [> `V3 | `V4 | `V5] t -> unit
    
    (** Inform the window that it is fullscreen.
        
        Inform the window that it is fullscreen. The window might use this
        information to adapt the style of its client-side window decorations for
        example.
        
        This request does not affect the size/position of the window or cause it
        to become the only window rendered, see the river_window_v1.fullscreen
        and exit_fullscreen requests for that.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_inform_not_fullscreen : [> `V3 | `V4 | `V5] t -> unit
    
    (** Inform the window that it is not fullscreen.
        
        Inform the window that it is not fullscreen. The window might use this
        information to adapt the style of its client-side window decorations for
        example.
        
        This request does not affect the size/position of the window or cause it
        to become the only window rendered, see the river_window_v1.fullscreen
        and exit_fullscreen requests for that.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_fullscreen : [> `V3 | `V4 | `V5] t -> output:([`River_output_v1], [> Imports.River_output_v1.versions], [`Server]) Proxy.t ->
                                           unit
    
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
    
    method private virtual on_exit_fullscreen : [> `V3 | `V4 | `V5] t -> unit
    
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
    
    method private virtual on_set_clip_box : [> `V3 | `V4 | `V5] t -> x:int32 -> y:int32 -> width:int32 ->
                                             height:int32 -> unit
    
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
    
    method private virtual on_set_content_clip_box : [> `V3 | `V4 | `V5] t -> x:int32 -> y:int32 -> width:int32 ->
                                                     height:int32 -> unit
    
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
    
    method private virtual on_set_dimension_bounds : [> `V4 | `V5] t -> max_width:int32 -> max_height:int32 -> unit
    
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
    
    method min_version = 3l
  end
  
  (** Handler for a proxy with version >= 4. *)
  class virtual ['v] v4 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_destroy : [> `V4 | `V5] t -> unit
    
    (** Destroy the window object.
        
        This request indicates that the client will no longer use the window
        object and that it may be safely destroyed.
        
        This request should be made after the river_window_v1.closed event or
        river_window_manager_v1.finished is received to complete destruction of
        the window. *)
    
    method private virtual on_close : [> `V4 | `V5] t -> unit
    
    (** Request that the window be closed.
        
        Request that the window be closed. The window may ignore this request or
        only close after some delay, perhaps opening a dialog asking the user to
        save their work or similar.
        
        The server will send a river_window_v1.closed event if/when the window
        has been closed.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_get_node : [> `V4 | `V5] t -> ([`River_node_v1], 'v, [`Server]) Proxy.t -> unit
    
    (** Get the window's render list node.
        
        Get the node in the render list corresponding to the window.
        
        It is a protocol error to make this request more than once for a single
        window. *)
    
    method private virtual on_propose_dimensions : [> `V4 | `V5] t -> width:int32 -> height:int32 -> unit
    
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
    
    method private virtual on_hide : [> `V4 | `V5] t -> unit
    
    (** Request that the window be hidden.
        
        Request that the window be hidden. Has no effect if the window is
        already hidden. Hides any window borders and decorations as well.
        
        Newly created windows are considered shown unless explicitly hidden with
        the hide request.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_show : [> `V4 | `V5] t -> unit
    
    (** Request that the window be shown.
        
        Request that the window be shown. Has no effect if the window is not
        hidden. Does not guarantee that the window is visible as it may be
        completely obscured by other windows placed above it for example.
        
        Newly created windows are considered shown unless explicitly hidden with
        the hide request.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_use_csd : [> `V4 | `V5] t -> unit
    
    (** Tell the client to use CSD.
        
        Tell the client to use client side decoration and draw its own title
        bar, borders, etc.
        
        This is the default if neither this request nor the use_ssd request is
        ever made.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_use_ssd : [> `V4 | `V5] t -> unit
    
    (** Tell the client to use SSD.
        
        Tell the client to use server side decoration and not draw any client
        side decorations.
        
        This request will have no effect if the client only supports client side
        decoration, see the decoration_hint event.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_set_borders : [> `V4 | `V5] t -> edges:Imports.River_window_v1.Edges.t -> width:int32 ->
                                            r:int32 -> g:int32 -> b:int32 -> a:int32 -> unit
    
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
    
    method private virtual on_set_tiled : [> `V4 | `V5] t -> edges:Imports.River_window_v1.Edges.t -> unit
    
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
    
    method private virtual on_get_decoration_above : [> `V4 | `V5] t -> ([`River_decoration_v1], 'v, [`Server]) Proxy.t ->
                                                     surface:([`Wl_surface], [> Imports.Wl_surface.versions], [`Server]) Proxy.t ->
                                                     unit
    
    (** Create a decoration above the window in z-order.
        
        Create a decoration surface and assign the river_decoration_v1 role to
        the surface. The created decoration is placed above the window in
        rendering order, see the description of river_decoration_v1.
        
        Providing a wl_surface which already has a role or already has a buffer
        attached or committed is a protocol error. *)
    
    method private virtual on_get_decoration_below : [> `V4 | `V5] t -> ([`River_decoration_v1], 'v, [`Server]) Proxy.t ->
                                                     surface:([`Wl_surface], [> Imports.Wl_surface.versions], [`Server]) Proxy.t ->
                                                     unit
    
    (** Create a decoration below the window in z-order.
        
        Create a decoration surface and assign the river_decoration_v1 role to
        the surface. The created decoration is placed below the window in
        rendering order, see the description of river_decoration_v1.
        
        Providing a wl_surface which already has a role or already has a buffer
        attached or committed is a protocol error. *)
    
    method private virtual on_inform_resize_start : [> `V4 | `V5] t -> unit
    
    (** Inform the window it is being resized.
        
        Inform the window that it is being resized. The window manager should
        use this request to inform windows that are the target of an interactive
        resize for example.
        
        The window manager remains responsible for handling the position and
        dimensions of the window while it is resizing.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_inform_resize_end : [> `V4 | `V5] t -> unit
    
    (** Inform the window it no longer being resized.
        
        Inform the window that it is no longer being resized. The window manager
        should use this request to inform windows that are the target of an
        interactive resize that the interactive resize has ended for example.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_set_capabilities : [> `V4 | `V5] t -> caps:Imports.River_window_v1.Capabilities.t -> unit
    
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
    
    method private virtual on_inform_maximized : [> `V4 | `V5] t -> unit
    
    (** Inform the window that it is maximized.
        
        Inform the window that it is maximized. The window might use this
        information to adapt the style of its client-side window decorations for
        example.
        
        The window manager remains responsible for handling the position and
        dimensions of the window while it is maximized.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_inform_unmaximized : [> `V4 | `V5] t -> unit
    
    (** Inform the window that it is unmaximized.
        
        Inform the window that it is unmaximized. The window might use this
        information to adapt the style of its client-side window decorations for
        example.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_inform_fullscreen : [> `V4 | `V5] t -> unit
    
    (** Inform the window that it is fullscreen.
        
        Inform the window that it is fullscreen. The window might use this
        information to adapt the style of its client-side window decorations for
        example.
        
        This request does not affect the size/position of the window or cause it
        to become the only window rendered, see the river_window_v1.fullscreen
        and exit_fullscreen requests for that.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_inform_not_fullscreen : [> `V4 | `V5] t -> unit
    
    (** Inform the window that it is not fullscreen.
        
        Inform the window that it is not fullscreen. The window might use this
        information to adapt the style of its client-side window decorations for
        example.
        
        This request does not affect the size/position of the window or cause it
        to become the only window rendered, see the river_window_v1.fullscreen
        and exit_fullscreen requests for that.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_fullscreen : [> `V4 | `V5] t -> output:([`River_output_v1], [> Imports.River_output_v1.versions], [`Server]) Proxy.t ->
                                           unit
    
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
    
    method private virtual on_exit_fullscreen : [> `V4 | `V5] t -> unit
    
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
    
    method private virtual on_set_clip_box : [> `V4 | `V5] t -> x:int32 -> y:int32 -> width:int32 -> height:int32 ->
                                             unit
    
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
    
    method private virtual on_set_content_clip_box : [> `V4 | `V5] t -> x:int32 -> y:int32 -> width:int32 ->
                                                     height:int32 -> unit
    
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
    
    method private virtual on_set_dimension_bounds : [> `V4 | `V5] t -> max_width:int32 -> max_height:int32 -> unit
    
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
    
    method min_version = 4l
  end
  
  (** Handler for a proxy with version >= 5. *)
  class virtual ['v] v5 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_destroy : [> `V5] t -> unit
    
    (** Destroy the window object.
        
        This request indicates that the client will no longer use the window
        object and that it may be safely destroyed.
        
        This request should be made after the river_window_v1.closed event or
        river_window_manager_v1.finished is received to complete destruction of
        the window. *)
    
    method private virtual on_close : [> `V5] t -> unit
    
    (** Request that the window be closed.
        
        Request that the window be closed. The window may ignore this request or
        only close after some delay, perhaps opening a dialog asking the user to
        save their work or similar.
        
        The server will send a river_window_v1.closed event if/when the window
        has been closed.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_get_node : [> `V5] t -> ([`River_node_v1], 'v, [`Server]) Proxy.t -> unit
    
    (** Get the window's render list node.
        
        Get the node in the render list corresponding to the window.
        
        It is a protocol error to make this request more than once for a single
        window. *)
    
    method private virtual on_propose_dimensions : [> `V5] t -> width:int32 -> height:int32 -> unit
    
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
    
    method private virtual on_hide : [> `V5] t -> unit
    
    (** Request that the window be hidden.
        
        Request that the window be hidden. Has no effect if the window is
        already hidden. Hides any window borders and decorations as well.
        
        Newly created windows are considered shown unless explicitly hidden with
        the hide request.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_show : [> `V5] t -> unit
    
    (** Request that the window be shown.
        
        Request that the window be shown. Has no effect if the window is not
        hidden. Does not guarantee that the window is visible as it may be
        completely obscured by other windows placed above it for example.
        
        Newly created windows are considered shown unless explicitly hidden with
        the hide request.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_use_csd : [> `V5] t -> unit
    
    (** Tell the client to use CSD.
        
        Tell the client to use client side decoration and draw its own title
        bar, borders, etc.
        
        This is the default if neither this request nor the use_ssd request is
        ever made.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_use_ssd : [> `V5] t -> unit
    
    (** Tell the client to use SSD.
        
        Tell the client to use server side decoration and not draw any client
        side decorations.
        
        This request will have no effect if the client only supports client side
        decoration, see the decoration_hint event.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_set_borders : [> `V5] t -> edges:Imports.River_window_v1.Edges.t -> width:int32 ->
                                            r:int32 -> g:int32 -> b:int32 -> a:int32 -> unit
    
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
    
    method private virtual on_set_tiled : [> `V5] t -> edges:Imports.River_window_v1.Edges.t -> unit
    
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
    
    method private virtual on_get_decoration_above : [> `V5] t -> ([`River_decoration_v1], 'v, [`Server]) Proxy.t ->
                                                     surface:([`Wl_surface], [> Imports.Wl_surface.versions], [`Server]) Proxy.t ->
                                                     unit
    
    (** Create a decoration above the window in z-order.
        
        Create a decoration surface and assign the river_decoration_v1 role to
        the surface. The created decoration is placed above the window in
        rendering order, see the description of river_decoration_v1.
        
        Providing a wl_surface which already has a role or already has a buffer
        attached or committed is a protocol error. *)
    
    method private virtual on_get_decoration_below : [> `V5] t -> ([`River_decoration_v1], 'v, [`Server]) Proxy.t ->
                                                     surface:([`Wl_surface], [> Imports.Wl_surface.versions], [`Server]) Proxy.t ->
                                                     unit
    
    (** Create a decoration below the window in z-order.
        
        Create a decoration surface and assign the river_decoration_v1 role to
        the surface. The created decoration is placed below the window in
        rendering order, see the description of river_decoration_v1.
        
        Providing a wl_surface which already has a role or already has a buffer
        attached or committed is a protocol error. *)
    
    method private virtual on_inform_resize_start : [> `V5] t -> unit
    
    (** Inform the window it is being resized.
        
        Inform the window that it is being resized. The window manager should
        use this request to inform windows that are the target of an interactive
        resize for example.
        
        The window manager remains responsible for handling the position and
        dimensions of the window while it is resizing.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_inform_resize_end : [> `V5] t -> unit
    
    (** Inform the window it no longer being resized.
        
        Inform the window that it is no longer being resized. The window manager
        should use this request to inform windows that are the target of an
        interactive resize that the interactive resize has ended for example.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_set_capabilities : [> `V5] t -> caps:Imports.River_window_v1.Capabilities.t -> unit
    
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
    
    method private virtual on_inform_maximized : [> `V5] t -> unit
    
    (** Inform the window that it is maximized.
        
        Inform the window that it is maximized. The window might use this
        information to adapt the style of its client-side window decorations for
        example.
        
        The window manager remains responsible for handling the position and
        dimensions of the window while it is maximized.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_inform_unmaximized : [> `V5] t -> unit
    
    (** Inform the window that it is unmaximized.
        
        Inform the window that it is unmaximized. The window might use this
        information to adapt the style of its client-side window decorations for
        example.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_inform_fullscreen : [> `V5] t -> unit
    
    (** Inform the window that it is fullscreen.
        
        Inform the window that it is fullscreen. The window might use this
        information to adapt the style of its client-side window decorations for
        example.
        
        This request does not affect the size/position of the window or cause it
        to become the only window rendered, see the river_window_v1.fullscreen
        and exit_fullscreen requests for that.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_inform_not_fullscreen : [> `V5] t -> unit
    
    (** Inform the window that it is not fullscreen.
        
        Inform the window that it is not fullscreen. The window might use this
        information to adapt the style of its client-side window decorations for
        example.
        
        This request does not affect the size/position of the window or cause it
        to become the only window rendered, see the river_window_v1.fullscreen
        and exit_fullscreen requests for that.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_fullscreen : [> `V5] t -> output:([`River_output_v1], [> Imports.River_output_v1.versions], [`Server]) Proxy.t ->
                                           unit
    
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
    
    method private virtual on_exit_fullscreen : [> `V5] t -> unit
    
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
    
    method private virtual on_set_clip_box : [> `V5] t -> x:int32 -> y:int32 -> width:int32 -> height:int32 -> unit
    
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
    
    method private virtual on_set_content_clip_box : [> `V5] t -> x:int32 -> y:int32 -> width:int32 -> height:int32 ->
                                                     unit
    
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
    
    method private virtual on_set_dimension_bounds : [> `V5] t -> max_width:int32 -> max_height:int32 -> unit
    
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
  type 'v t = ([`River_decoration_v1], 'v, [`Server]) Proxy.t
  module Error = River_window_management_v1_proto.River_decoration_v1.Error
  
  (** {2 Version 1, 2, 3, 4, 5} *)
  
  (**/**)
  class virtual ['v] _handlers_unsafe = object (_self : (_, 'v, _) #Proxy.Handler.t)
    method user_data = S.No_data
    method metadata = (module River_window_management_v1_proto.River_decoration_v1)
    method max_version = 5l
    
    method private virtual on_destroy : [> ] t -> unit
    
    method private virtual on_set_offset : [> ] t -> x:int32 -> y:int32 -> unit
    
    method private virtual on_sync_next_commit : [> ] t -> unit
    
    
    method dispatch (_proxy : 'v t) _msg =
      let _proxy = Proxy.cast_version _proxy in
      match Msg.op _msg with
      | 0 ->
        Proxy.shutdown_recv _proxy;
        _self#on_destroy _proxy 
      | 1 ->
        let x = Msg.get_int _msg in
        let y = Msg.get_int _msg in
        _self#on_set_offset _proxy ~x ~y
      | 2 ->
        _self#on_sync_next_commit _proxy 
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
    method private virtual on_destroy : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Destroy the decoration object.
        
        This request indicates that the client will no longer use the decoration
        object and that it may be safely destroyed. *)
    
    method private virtual on_set_offset : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> x:int32 -> y:int32 -> unit
    
    (** Set offset from the window's top left corner.
        
        This request sets the offset of the decoration surface from the top left
        corner of the window.
        
        If this request is never sent, the x and y offsets are undefined by this
        protocol and left up to the compositor.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_sync_next_commit : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Sync next commit with other rendering state.
        
        Synchronize application of the next wl_surface.commit request on the
        decoration surface with rest of the state atomically applied with the
        next river_window_manager_v1.render_finish request.
        
        The client must make a wl_surface.commit request on the decoration
        surface after this request and before the render_finish request, failure
        to do so is a protocol error.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
    method min_version = 1l
  end
  
  (** Handler for a proxy with version >= 2. *)
  class virtual ['v] v2 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V2 | `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_destroy : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Destroy the decoration object.
        
        This request indicates that the client will no longer use the decoration
        object and that it may be safely destroyed. *)
    
    method private virtual on_set_offset : [> `V2 | `V3 | `V4 | `V5] t -> x:int32 -> y:int32 -> unit
    
    (** Set offset from the window's top left corner.
        
        This request sets the offset of the decoration surface from the top left
        corner of the window.
        
        If this request is never sent, the x and y offsets are undefined by this
        protocol and left up to the compositor.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_sync_next_commit : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Sync next commit with other rendering state.
        
        Synchronize application of the next wl_surface.commit request on the
        decoration surface with rest of the state atomically applied with the
        next river_window_manager_v1.render_finish request.
        
        The client must make a wl_surface.commit request on the decoration
        surface after this request and before the render_finish request, failure
        to do so is a protocol error.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
    method min_version = 2l
  end
  
  (** Handler for a proxy with version >= 3. *)
  class virtual ['v] v3 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_destroy : [> `V3 | `V4 | `V5] t -> unit
    
    (** Destroy the decoration object.
        
        This request indicates that the client will no longer use the decoration
        object and that it may be safely destroyed. *)
    
    method private virtual on_set_offset : [> `V3 | `V4 | `V5] t -> x:int32 -> y:int32 -> unit
    
    (** Set offset from the window's top left corner.
        
        This request sets the offset of the decoration surface from the top left
        corner of the window.
        
        If this request is never sent, the x and y offsets are undefined by this
        protocol and left up to the compositor.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_sync_next_commit : [> `V3 | `V4 | `V5] t -> unit
    
    (** Sync next commit with other rendering state.
        
        Synchronize application of the next wl_surface.commit request on the
        decoration surface with rest of the state atomically applied with the
        next river_window_manager_v1.render_finish request.
        
        The client must make a wl_surface.commit request on the decoration
        surface after this request and before the render_finish request, failure
        to do so is a protocol error.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
    method min_version = 3l
  end
  
  (** Handler for a proxy with version >= 4. *)
  class virtual ['v] v4 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_destroy : [> `V4 | `V5] t -> unit
    
    (** Destroy the decoration object.
        
        This request indicates that the client will no longer use the decoration
        object and that it may be safely destroyed. *)
    
    method private virtual on_set_offset : [> `V4 | `V5] t -> x:int32 -> y:int32 -> unit
    
    (** Set offset from the window's top left corner.
        
        This request sets the offset of the decoration surface from the top left
        corner of the window.
        
        If this request is never sent, the x and y offsets are undefined by this
        protocol and left up to the compositor.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_sync_next_commit : [> `V4 | `V5] t -> unit
    
    (** Sync next commit with other rendering state.
        
        Synchronize application of the next wl_surface.commit request on the
        decoration surface with rest of the state atomically applied with the
        next river_window_manager_v1.render_finish request.
        
        The client must make a wl_surface.commit request on the decoration
        surface after this request and before the render_finish request, failure
        to do so is a protocol error.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
    method min_version = 4l
  end
  
  (** Handler for a proxy with version >= 5. *)
  class virtual ['v] v5 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_destroy : [> `V5] t -> unit
    
    (** Destroy the decoration object.
        
        This request indicates that the client will no longer use the decoration
        object and that it may be safely destroyed. *)
    
    method private virtual on_set_offset : [> `V5] t -> x:int32 -> y:int32 -> unit
    
    (** Set offset from the window's top left corner.
        
        This request sets the offset of the decoration surface from the top left
        corner of the window.
        
        If this request is never sent, the x and y offsets are undefined by this
        protocol and left up to the compositor.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_sync_next_commit : [> `V5] t -> unit
    
    (** Sync next commit with other rendering state.
        
        Synchronize application of the next wl_surface.commit request on the
        decoration surface with rest of the state atomically applied with the
        next river_window_manager_v1.render_finish request.
        
        The client must make a wl_surface.commit request on the decoration
        surface after this request and before the render_finish request, failure
        to do so is a protocol error.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
    method min_version = 5l
  end
end

(** A surface for window manager UI.
    
    The window manager might use a shell surface to display a status bar,
    background image, desktop notifications, launcher, desktop menu, or
    whatever else it wants. *)
module River_shell_surface_v1 = struct
  type 'v t = ([`River_shell_surface_v1], 'v, [`Server]) Proxy.t
  module Error = River_window_management_v1_proto.River_shell_surface_v1.Error
  
  (** {2 Version 1, 2, 3, 4, 5} *)
  
  (**/**)
  class virtual ['v] _handlers_unsafe = object (_self : (_, 'v, _) #Proxy.Handler.t)
    method user_data = S.No_data
    method metadata = (module River_window_management_v1_proto.River_shell_surface_v1)
    method max_version = 5l
    
    method private virtual on_destroy : [> ] t -> unit
    
    method private virtual on_get_node : [> ] t -> ([`River_node_v1], 'v, [`Server]) Proxy.t -> unit
    
    method private virtual on_sync_next_commit : [> ] t -> unit
    
    
    method dispatch (_proxy : 'v t) _msg =
      let _proxy = Proxy.cast_version _proxy in
      match Msg.op _msg with
      | 0 ->
        Proxy.shutdown_recv _proxy;
        _self#on_destroy _proxy 
      | 1 ->
        let id : ([`River_node_v1], _, _) Proxy.t =
          Msg.get_int _msg |> Proxy.Handler.accept_new _proxy (module Imports.River_node_v1) in
        _self#on_get_node _proxy id
      | 2 ->
        _self#on_sync_next_commit _proxy 
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
    method private virtual on_destroy : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Destroy the shell surface object.
        
        This request indicates that the client will no longer use the shell
        surface object and that it may be safely destroyed. *)
    
    method private virtual on_get_node : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> ([`River_node_v1], 'v, [`Server]) Proxy.t ->
                                         unit
    
    (** Get the shell surface's render list node.
        
        Get the node in the render list corresponding to the shell surface.
        
        It is a protocol error to make this request more than once for a single
        shell surface. *)
    
    method private virtual on_sync_next_commit : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Sync next surface commit to window manager commit.
        
        Synchronize application of the next wl_surface.commit request on the
        shell surface with rest of the rendering state atomically applied with
        the next river_window_manager_v1.render_finish request.
        
        The client must make a wl_surface.commit request on the shell surface
        after this request and before the render_finish request, failure to do
        so is a protocol error.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
    method min_version = 1l
  end
  
  (** Handler for a proxy with version >= 2. *)
  class virtual ['v] v2 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V2 | `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_destroy : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Destroy the shell surface object.
        
        This request indicates that the client will no longer use the shell
        surface object and that it may be safely destroyed. *)
    
    method private virtual on_get_node : [> `V2 | `V3 | `V4 | `V5] t -> ([`River_node_v1], 'v, [`Server]) Proxy.t ->
                                         unit
    
    (** Get the shell surface's render list node.
        
        Get the node in the render list corresponding to the shell surface.
        
        It is a protocol error to make this request more than once for a single
        shell surface. *)
    
    method private virtual on_sync_next_commit : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Sync next surface commit to window manager commit.
        
        Synchronize application of the next wl_surface.commit request on the
        shell surface with rest of the rendering state atomically applied with
        the next river_window_manager_v1.render_finish request.
        
        The client must make a wl_surface.commit request on the shell surface
        after this request and before the render_finish request, failure to do
        so is a protocol error.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
    method min_version = 2l
  end
  
  (** Handler for a proxy with version >= 3. *)
  class virtual ['v] v3 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_destroy : [> `V3 | `V4 | `V5] t -> unit
    
    (** Destroy the shell surface object.
        
        This request indicates that the client will no longer use the shell
        surface object and that it may be safely destroyed. *)
    
    method private virtual on_get_node : [> `V3 | `V4 | `V5] t -> ([`River_node_v1], 'v, [`Server]) Proxy.t -> unit
    
    (** Get the shell surface's render list node.
        
        Get the node in the render list corresponding to the shell surface.
        
        It is a protocol error to make this request more than once for a single
        shell surface. *)
    
    method private virtual on_sync_next_commit : [> `V3 | `V4 | `V5] t -> unit
    
    (** Sync next surface commit to window manager commit.
        
        Synchronize application of the next wl_surface.commit request on the
        shell surface with rest of the rendering state atomically applied with
        the next river_window_manager_v1.render_finish request.
        
        The client must make a wl_surface.commit request on the shell surface
        after this request and before the render_finish request, failure to do
        so is a protocol error.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
    method min_version = 3l
  end
  
  (** Handler for a proxy with version >= 4. *)
  class virtual ['v] v4 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_destroy : [> `V4 | `V5] t -> unit
    
    (** Destroy the shell surface object.
        
        This request indicates that the client will no longer use the shell
        surface object and that it may be safely destroyed. *)
    
    method private virtual on_get_node : [> `V4 | `V5] t -> ([`River_node_v1], 'v, [`Server]) Proxy.t -> unit
    
    (** Get the shell surface's render list node.
        
        Get the node in the render list corresponding to the shell surface.
        
        It is a protocol error to make this request more than once for a single
        shell surface. *)
    
    method private virtual on_sync_next_commit : [> `V4 | `V5] t -> unit
    
    (** Sync next surface commit to window manager commit.
        
        Synchronize application of the next wl_surface.commit request on the
        shell surface with rest of the rendering state atomically applied with
        the next river_window_manager_v1.render_finish request.
        
        The client must make a wl_surface.commit request on the shell surface
        after this request and before the render_finish request, failure to do
        so is a protocol error.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
    method min_version = 4l
  end
  
  (** Handler for a proxy with version >= 5. *)
  class virtual ['v] v5 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_destroy : [> `V5] t -> unit
    
    (** Destroy the shell surface object.
        
        This request indicates that the client will no longer use the shell
        surface object and that it may be safely destroyed. *)
    
    method private virtual on_get_node : [> `V5] t -> ([`River_node_v1], 'v, [`Server]) Proxy.t -> unit
    
    (** Get the shell surface's render list node.
        
        Get the node in the render list corresponding to the shell surface.
        
        It is a protocol error to make this request more than once for a single
        shell surface. *)
    
    method private virtual on_sync_next_commit : [> `V5] t -> unit
    
    (** Sync next surface commit to window manager commit.
        
        Synchronize application of the next wl_surface.commit request on the
        shell surface with rest of the rendering state atomically applied with
        the next river_window_manager_v1.render_finish request.
        
        The client must make a wl_surface.commit request on the shell surface
        after this request and before the render_finish request, failure to do
        so is a protocol error.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
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
  type 'v t = ([`River_node_v1], 'v, [`Server]) Proxy.t
  
  (** {2 Version 1, 2, 3, 4, 5} *)
  
  (**/**)
  class virtual ['v] _handlers_unsafe = object (_self : (_, 'v, _) #Proxy.Handler.t)
    method user_data = S.No_data
    method metadata = (module River_window_management_v1_proto.River_node_v1)
    method max_version = 5l
    
    method private virtual on_destroy : [> ] t -> unit
    
    method private virtual on_set_position : [> ] t -> x:int32 -> y:int32 -> unit
    
    method private virtual on_place_top : [> ] t -> unit
    
    method private virtual on_place_bottom : [> ] t -> unit
    
    method private virtual on_place_above : [> ] t -> other:([`River_node_v1], [> Imports.River_node_v1.versions], [`Server]) Proxy.t ->
                                            unit
    
    method private virtual on_place_below : [> ] t -> other:([`River_node_v1], [> Imports.River_node_v1.versions], [`Server]) Proxy.t ->
                                            unit
    
    
    method dispatch (_proxy : 'v t) _msg =
      let _proxy = Proxy.cast_version _proxy in
      match Msg.op _msg with
      | 0 ->
        Proxy.shutdown_recv _proxy;
        _self#on_destroy _proxy 
      | 1 ->
        let x = Msg.get_int _msg in
        let y = Msg.get_int _msg in
        _self#on_set_position _proxy ~x ~y
      | 2 ->
        _self#on_place_top _proxy 
      | 3 ->
        _self#on_place_bottom _proxy 
      | 4 ->
        let other : ([`River_node_v1], _, _) Proxy.t =
          let Proxy.Proxy p = Msg.get_int _msg |> Proxy.lookup_other _proxy in
          match Proxy.ty p with
          | Imports.River_node_v1.T -> p
          | _ -> Proxy.wrong_type ~parent:_proxy ~expected:"river_node_v1" p
          in
        _self#on_place_above _proxy ~other
      | 5 ->
        let other : ([`River_node_v1], _, _) Proxy.t =
          let Proxy.Proxy p = Msg.get_int _msg |> Proxy.lookup_other _proxy in
          match Proxy.ty p with
          | Imports.River_node_v1.T -> p
          | _ -> Proxy.wrong_type ~parent:_proxy ~expected:"river_node_v1" p
          in
        _self#on_place_below _proxy ~other
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
    method private virtual on_destroy : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Destroy the decoration object.
        
        This request indicates that the client will no longer use the node
        object and that it may be safely destroyed. *)
    
    method private virtual on_set_position : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> x:int32 -> y:int32 -> unit
    
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
    
    method private virtual on_place_top : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Place node above all other nodes.
        
        This request places the node above all other nodes in the compositor's
        render list.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_place_bottom : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Place node below all other nodes.
        
        This request places the node below all other nodes in the compositor's
        render list.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_place_above : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> other:([`River_node_v1], [> Imports.River_node_v1.versions], [`Server]) Proxy.t ->
                                            unit
    
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
    
    method private virtual on_place_below : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> other:([`River_node_v1], [> Imports.River_node_v1.versions], [`Server]) Proxy.t ->
                                            unit
    
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
    
    method min_version = 1l
  end
  
  (** Handler for a proxy with version >= 2. *)
  class virtual ['v] v2 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V2 | `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_destroy : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Destroy the decoration object.
        
        This request indicates that the client will no longer use the node
        object and that it may be safely destroyed. *)
    
    method private virtual on_set_position : [> `V2 | `V3 | `V4 | `V5] t -> x:int32 -> y:int32 -> unit
    
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
    
    method private virtual on_place_top : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Place node above all other nodes.
        
        This request places the node above all other nodes in the compositor's
        render list.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_place_bottom : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Place node below all other nodes.
        
        This request places the node below all other nodes in the compositor's
        render list.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_place_above : [> `V2 | `V3 | `V4 | `V5] t -> other:([`River_node_v1], [> Imports.River_node_v1.versions], [`Server]) Proxy.t ->
                                            unit
    
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
    
    method private virtual on_place_below : [> `V2 | `V3 | `V4 | `V5] t -> other:([`River_node_v1], [> Imports.River_node_v1.versions], [`Server]) Proxy.t ->
                                            unit
    
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
    
    method min_version = 2l
  end
  
  (** Handler for a proxy with version >= 3. *)
  class virtual ['v] v3 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_destroy : [> `V3 | `V4 | `V5] t -> unit
    
    (** Destroy the decoration object.
        
        This request indicates that the client will no longer use the node
        object and that it may be safely destroyed. *)
    
    method private virtual on_set_position : [> `V3 | `V4 | `V5] t -> x:int32 -> y:int32 -> unit
    
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
    
    method private virtual on_place_top : [> `V3 | `V4 | `V5] t -> unit
    
    (** Place node above all other nodes.
        
        This request places the node above all other nodes in the compositor's
        render list.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_place_bottom : [> `V3 | `V4 | `V5] t -> unit
    
    (** Place node below all other nodes.
        
        This request places the node below all other nodes in the compositor's
        render list.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_place_above : [> `V3 | `V4 | `V5] t -> other:([`River_node_v1], [> Imports.River_node_v1.versions], [`Server]) Proxy.t ->
                                            unit
    
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
    
    method private virtual on_place_below : [> `V3 | `V4 | `V5] t -> other:([`River_node_v1], [> Imports.River_node_v1.versions], [`Server]) Proxy.t ->
                                            unit
    
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
    
    method min_version = 3l
  end
  
  (** Handler for a proxy with version >= 4. *)
  class virtual ['v] v4 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_destroy : [> `V4 | `V5] t -> unit
    
    (** Destroy the decoration object.
        
        This request indicates that the client will no longer use the node
        object and that it may be safely destroyed. *)
    
    method private virtual on_set_position : [> `V4 | `V5] t -> x:int32 -> y:int32 -> unit
    
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
    
    method private virtual on_place_top : [> `V4 | `V5] t -> unit
    
    (** Place node above all other nodes.
        
        This request places the node above all other nodes in the compositor's
        render list.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_place_bottom : [> `V4 | `V5] t -> unit
    
    (** Place node below all other nodes.
        
        This request places the node below all other nodes in the compositor's
        render list.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_place_above : [> `V4 | `V5] t -> other:([`River_node_v1], [> Imports.River_node_v1.versions], [`Server]) Proxy.t ->
                                            unit
    
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
    
    method private virtual on_place_below : [> `V4 | `V5] t -> other:([`River_node_v1], [> Imports.River_node_v1.versions], [`Server]) Proxy.t ->
                                            unit
    
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
    
    method min_version = 4l
  end
  
  (** Handler for a proxy with version >= 5. *)
  class virtual ['v] v5 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_destroy : [> `V5] t -> unit
    
    (** Destroy the decoration object.
        
        This request indicates that the client will no longer use the node
        object and that it may be safely destroyed. *)
    
    method private virtual on_set_position : [> `V5] t -> x:int32 -> y:int32 -> unit
    
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
    
    method private virtual on_place_top : [> `V5] t -> unit
    
    (** Place node above all other nodes.
        
        This request places the node above all other nodes in the compositor's
        render list.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_place_bottom : [> `V5] t -> unit
    
    (** Place node below all other nodes.
        
        This request places the node below all other nodes in the compositor's
        render list.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_place_above : [> `V5] t -> other:([`River_node_v1], [> Imports.River_node_v1.versions], [`Server]) Proxy.t ->
                                            unit
    
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
    
    method private virtual on_place_below : [> `V5] t -> other:([`River_node_v1], [> Imports.River_node_v1.versions], [`Server]) Proxy.t ->
                                            unit
    
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
  type 'v t = ([`River_output_v1], 'v, [`Server]) Proxy.t
  module Error = River_window_management_v1_proto.River_output_v1.Error
  
  module Presentation_mode = River_window_management_v1_proto.River_output_v1.Presentation_mode
  
  (** {2 Version 1, 2, 3} *)
  
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
  let dimensions (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) ~width ~height =
    let _msg = Proxy.alloc _t ~op:3 ~ints:2 ~strings:[] ~arrays:[] in
    Msg.add_int _msg width;
    Msg.add_int _msg height;
    Proxy.send _t _msg
  
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
  let position (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) ~x ~y =
    let _msg = Proxy.alloc _t ~op:2 ~ints:2 ~strings:[] ~arrays:[] in
    Msg.add_int _msg x;
    Msg.add_int _msg y;
    Proxy.send _t _msg
  
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
  let wl_output (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) ~name =
    let _msg = Proxy.alloc _t ~op:1 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg name;
    Proxy.send _t _msg
  
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
  let removed (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:0 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  
  (** {2 Version 4} *)
  
  
  (** {2 Version 5} *)
  
  (** Output screen capture sessions.
      
      This event informs the window manager of the number of active screen
      capture sessions for the output.
      
      This event is sent once when the river_output_v1 is created and again
      whenever the number of capture sessions changes.
      
      This event will be followed by a manage_start event after all other new
      state has been sent by the server. *)
  let capture_sessions (_t:([< `V5] as 'v) t) ~count =
    let _msg = Proxy.alloc _t ~op:4 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg count;
    Proxy.send _t _msg
  
  (**/**)
  class virtual ['v] _handlers_unsafe = object (_self : (_, 'v, _) #Proxy.Handler.t)
    method user_data = S.No_data
    method metadata = (module River_window_management_v1_proto.River_output_v1)
    method max_version = 5l
    
    method private virtual on_destroy : [> ] t -> unit
    
    method private virtual on_set_presentation_mode : [> ] t -> mode:Imports.River_output_v1.Presentation_mode.t ->
                                                      unit
    
    
    method dispatch (_proxy : 'v t) _msg =
      let _proxy = Proxy.cast_version _proxy in
      match Msg.op _msg with
      | 0 ->
        Proxy.shutdown_recv _proxy;
        _self#on_destroy _proxy 
      | 1 ->
        let mode = Msg.get_int _msg |> Imports.River_output_v1.Presentation_mode.of_int32 in
        _self#on_set_presentation_mode _proxy ~mode
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
    method private virtual on_destroy : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Destroy the output object.
        
        This request indicates that the client will no longer use the output
        object and that it may be safely destroyed.
        
        This request should be made after the river_output_v1.removed event is
        received to complete destruction of the output. *)
    
    method private virtual on_set_presentation_mode : [> `V4 | `V5] t -> mode:Imports.River_output_v1.Presentation_mode.t ->
                                                      unit
    
    (** Set the preferred presentation mode.
        
        Set the preferred presentation mode of the output. The compositor should
        always respect the preference of the window manager if possible. If this
        request is never made, the preferred presentation mode is vsync.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
    method min_version = 1l
  end
  
  (** Handler for a proxy with version >= 2. *)
  class virtual ['v] v2 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V2 | `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_destroy : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Destroy the output object.
        
        This request indicates that the client will no longer use the output
        object and that it may be safely destroyed.
        
        This request should be made after the river_output_v1.removed event is
        received to complete destruction of the output. *)
    
    method private virtual on_set_presentation_mode : [> `V4 | `V5] t -> mode:Imports.River_output_v1.Presentation_mode.t ->
                                                      unit
    
    (** Set the preferred presentation mode.
        
        Set the preferred presentation mode of the output. The compositor should
        always respect the preference of the window manager if possible. If this
        request is never made, the preferred presentation mode is vsync.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
    method min_version = 2l
  end
  
  (** Handler for a proxy with version >= 3. *)
  class virtual ['v] v3 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_destroy : [> `V3 | `V4 | `V5] t -> unit
    
    (** Destroy the output object.
        
        This request indicates that the client will no longer use the output
        object and that it may be safely destroyed.
        
        This request should be made after the river_output_v1.removed event is
        received to complete destruction of the output. *)
    
    method private virtual on_set_presentation_mode : [> `V4 | `V5] t -> mode:Imports.River_output_v1.Presentation_mode.t ->
                                                      unit
    
    (** Set the preferred presentation mode.
        
        Set the preferred presentation mode of the output. The compositor should
        always respect the preference of the window manager if possible. If this
        request is never made, the preferred presentation mode is vsync.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
    method min_version = 3l
  end
  
  (** Handler for a proxy with version >= 4. *)
  class virtual ['v] v4 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_destroy : [> `V4 | `V5] t -> unit
    
    (** Destroy the output object.
        
        This request indicates that the client will no longer use the output
        object and that it may be safely destroyed.
        
        This request should be made after the river_output_v1.removed event is
        received to complete destruction of the output. *)
    
    method private virtual on_set_presentation_mode : [> `V4 | `V5] t -> mode:Imports.River_output_v1.Presentation_mode.t ->
                                                      unit
    
    (** Set the preferred presentation mode.
        
        Set the preferred presentation mode of the output. The compositor should
        always respect the preference of the window manager if possible. If this
        request is never made, the preferred presentation mode is vsync.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
    method min_version = 4l
  end
  
  (** Handler for a proxy with version >= 5. *)
  class virtual ['v] v5 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_destroy : [> `V5] t -> unit
    
    (** Destroy the output object.
        
        This request indicates that the client will no longer use the output
        object and that it may be safely destroyed.
        
        This request should be made after the river_output_v1.removed event is
        received to complete destruction of the output. *)
    
    method private virtual on_set_presentation_mode : [> `V5] t -> mode:Imports.River_output_v1.Presentation_mode.t ->
                                                      unit
    
    (** Set the preferred presentation mode.
        
        Set the preferred presentation mode of the output. The compositor should
        always respect the preference of the window manager if possible. If this
        request is never made, the preferred presentation mode is vsync.
        
        This request modifies rendering state and may only be made as part of a
        render sequence, see the river_window_manager_v1 description. *)
    
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
  type 'v t = ([`River_seat_v1], 'v, [`Server]) Proxy.t
  module Modifiers = River_window_management_v1_proto.River_seat_v1.Modifiers
  
  (** {2 Version 1} *)
  
  (** Operation input has been released.
      
      The input driving the current interactive operation has been released.
      For a pointer op for example, all pointer buttons have been released.
      
      Depending on the op type, op_delta events may continue to be sent until
      the op is ended with the op_end request.
      
      This event is sent at most once during an interactive operation.
      
      This event will be followed by a manage_start event after all other new
      state has been sent by the server. *)
  let op_release (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:7 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (** Total cumulative motion since op start.
      
      This event indicates the total change in position since the start of the
      operation of the pointer/touch point/etc.
      
      This event will be followed by a manage_start event after all other new
      state has been sent by the server. *)
  let op_delta (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) ~dx ~dy =
    let _msg = Proxy.alloc _t ~op:6 ~ints:2 ~strings:[] ~arrays:[] in
    Msg.add_int _msg dx;
    Msg.add_int _msg dy;
    Proxy.send _t _msg
  
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
  let shell_surface_interaction (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) 
    ~(shell_surface:([`River_shell_surface_v1], _, [`Server]) Proxy.t) =
    let _msg = Proxy.alloc _t ~op:5 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id shell_surface);
    Proxy.send _t _msg
  
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
  let window_interaction (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) 
    ~(window:([`River_window_v1], _, [`Server]) Proxy.t) =
    let _msg = Proxy.alloc _t ~op:4 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id window);
    Proxy.send _t _msg
  
  (** Pointer left the entered window.
      
      The seat's pointer left the window for which pointer_enter was most
      recently sent. See pointer_enter for details.
      
      This event will be followed by a manage_start event after all other new
      state has been sent by the server. *)
  let pointer_leave (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:3 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
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
  let pointer_enter (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) ~(window:([`River_window_v1], _, [`Server]) Proxy.t) =
    let _msg = Proxy.alloc _t ~op:2 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id window);
    Proxy.send _t _msg
  
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
  let wl_seat (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t) ~name =
    let _msg = Proxy.alloc _t ~op:1 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg name;
    Proxy.send _t _msg
  
  (** The seat is removed.
      
      This event indicates that seat is no longer in use and should be
      destroyed.
      
      The server will send no further events on this object and ignore any
      request (other than river_seat_v1.destroy) made after this event is
      sent.  The client should destroy this object with the
      river_seat_v1.destroy request to free up resources.
      
      This event will be followed by a manage_start event after all other new
      state has been sent by the server. *)
  let removed (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:0 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  
  (** {2 Version 2} *)
  
  (** The current position of the pointer.
      
      The current position of the pointer in the compositor's logical
      coordinate space.
      
      This state is special in that a change in pointer position alone must
      not cause the compositor to start a manage sequence.
      
      Assuming the seat has a pointer, this event must be sent in every manage
      sequence unless there is no change in x/y position since the last time this
      event was sent. *)
  let pointer_position (_t:([< `V2 | `V3 | `V4 | `V5] as 'v) t) ~x ~y =
    let _msg = Proxy.alloc _t ~op:8 ~ints:2 ~strings:[] ~arrays:[] in
    Msg.add_int _msg x;
    Msg.add_int _msg y;
    Proxy.send _t _msg
  
  
  (** {2 Version 3, 4, 5} *)
  
  (**/**)
  class virtual ['v] _handlers_unsafe = object (_self : (_, 'v, _) #Proxy.Handler.t)
    method user_data = S.No_data
    method metadata = (module River_window_management_v1_proto.River_seat_v1)
    method max_version = 5l
    
    method private virtual on_destroy : [> ] t -> unit
    
    method private virtual on_focus_window : [> ] t -> window:([`River_window_v1], [> Imports.River_window_v1.versions], [`Server]) Proxy.t ->
                                             unit
    
    method private virtual on_focus_shell_surface : [> ] t -> shell_surface:([`River_shell_surface_v1], [> Imports.River_shell_surface_v1.versions], [`Server]) Proxy.t ->
                                                    unit
    
    method private virtual on_clear_focus : [> ] t -> unit
    
    method private virtual on_op_start_pointer : [> ] t -> unit
    
    method private virtual on_op_end : [> ] t -> unit
    
    method private virtual on_get_pointer_binding : [> ] t -> ([`River_pointer_binding_v1], 'v, [`Server]) Proxy.t ->
                                                    button:int32 -> modifiers:Imports.River_seat_v1.Modifiers.t -> unit
    
    method private virtual on_set_xcursor_theme : [> ] t -> name:string -> size:int32 -> unit
    
    method private virtual on_pointer_warp : [> ] t -> x:int32 -> y:int32 -> unit
    
    
    method dispatch (_proxy : 'v t) _msg =
      let _proxy = Proxy.cast_version _proxy in
      match Msg.op _msg with
      | 0 ->
        Proxy.shutdown_recv _proxy;
        _self#on_destroy _proxy 
      | 1 ->
        let window : ([`River_window_v1], _, _) Proxy.t =
          let Proxy.Proxy p = Msg.get_int _msg |> Proxy.lookup_other _proxy in
          match Proxy.ty p with
          | Imports.River_window_v1.T -> p
          | _ -> Proxy.wrong_type ~parent:_proxy ~expected:"river_window_v1" p
          in
        _self#on_focus_window _proxy ~window
      | 2 ->
        let shell_surface : ([`River_shell_surface_v1], _, _) Proxy.t =
          let Proxy.Proxy p = Msg.get_int _msg |> Proxy.lookup_other _proxy in
          match Proxy.ty p with
          | Imports.River_shell_surface_v1.T -> p
          | _ -> Proxy.wrong_type ~parent:_proxy ~expected:"river_shell_surface_v1" p
          in
        _self#on_focus_shell_surface _proxy ~shell_surface
      | 3 ->
        _self#on_clear_focus _proxy 
      | 4 ->
        _self#on_op_start_pointer _proxy 
      | 5 ->
        _self#on_op_end _proxy 
      | 6 ->
        let id : ([`River_pointer_binding_v1], _, _) Proxy.t =
          Msg.get_int _msg |> Proxy.Handler.accept_new _proxy (module Imports.River_pointer_binding_v1) in
        let button = Msg.get_int _msg in
        let modifiers = Msg.get_int _msg |> Imports.River_seat_v1.Modifiers.of_int32 in
        _self#on_get_pointer_binding _proxy id ~button ~modifiers
      | 7 ->
        let name = Msg.get_string _msg in
        let size = Msg.get_int _msg in
        _self#on_set_xcursor_theme _proxy ~name ~size
      | 8 ->
        let x = Msg.get_int _msg in
        let y = Msg.get_int _msg in
        _self#on_pointer_warp _proxy ~x ~y
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
    method private virtual on_destroy : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Destroy the seat object.
        
        This request indicates that the client will no longer use the seat
        object and that it may be safely destroyed.
        
        This request should be made after the river_seat_v1.removed event is
        received to complete destruction of the seat. *)
    
    method private virtual on_focus_window : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> window:([`River_window_v1], [> Imports.River_window_v1.versions], [`Server]) Proxy.t ->
                                             unit
    
    (** Give keyboard focus to a window.
        
        Request that the compositor send keyboard input to the given window.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_focus_shell_surface : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> shell_surface:([`River_shell_surface_v1], [> Imports.River_shell_surface_v1.versions], [`Server]) Proxy.t ->
                                                    unit
    
    (** Give keyboard focus to a shell_surface.
        
        Request that the compositor send keyboard input to the given shell
        surface.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_clear_focus : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Clear keyboard focus.
        
        Request that the compositor not send keyboard input to any client.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_op_start_pointer : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
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
    
    method private virtual on_op_end : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** End an interactive operation.
        
        End an interactive operation.
        
        This request is ignored if there is no operation in progress.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_get_pointer_binding : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> ([`River_pointer_binding_v1], 'v, [`Server]) Proxy.t ->
                                                    button:int32 -> modifiers:Imports.River_seat_v1.Modifiers.t -> unit
    
    (** Define a new pointer binding.
        
        Define a pointer binding in terms of a pointer button, keyboard
        modifiers, and other configurable properties.
        
        The button argument is a Linux input event code defined in the
        linux/input-event-codes.h header file (e.g. BTN_RIGHT).
        
        The new pointer binding is not enabled until initial configuration is
        completed and the enable request is made during a manage sequence. *)
    
    method private virtual on_set_xcursor_theme : [> `V2 | `V3 | `V4 | `V5] t -> name:string -> size:int32 -> unit
    
    (** Set the xcursor theme for the seat.
        
        Set the XCursor theme for the seat. This theme is used for cursors
        rendered by the compositor, but not necessarily for cursors rendered by
        clients.
        
        Note: The window manager may also wish to set the XCURSOR_THEME and
        XCURSOR_SIZE environment variable for programs it starts. *)
    
    method private virtual on_pointer_warp : [> `V3 | `V4 | `V5] t -> x:int32 -> y:int32 -> unit
    
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
    
    method min_version = 1l
  end
  
  (** Handler for a proxy with version >= 2. *)
  class virtual ['v] v2 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V2 | `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_destroy : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Destroy the seat object.
        
        This request indicates that the client will no longer use the seat
        object and that it may be safely destroyed.
        
        This request should be made after the river_seat_v1.removed event is
        received to complete destruction of the seat. *)
    
    method private virtual on_focus_window : [> `V2 | `V3 | `V4 | `V5] t -> window:([`River_window_v1], [> Imports.River_window_v1.versions], [`Server]) Proxy.t ->
                                             unit
    
    (** Give keyboard focus to a window.
        
        Request that the compositor send keyboard input to the given window.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_focus_shell_surface : [> `V2 | `V3 | `V4 | `V5] t -> shell_surface:([`River_shell_surface_v1], [> Imports.River_shell_surface_v1.versions], [`Server]) Proxy.t ->
                                                    unit
    
    (** Give keyboard focus to a shell_surface.
        
        Request that the compositor send keyboard input to the given shell
        surface.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_clear_focus : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Clear keyboard focus.
        
        Request that the compositor not send keyboard input to any client.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_op_start_pointer : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
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
    
    method private virtual on_op_end : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** End an interactive operation.
        
        End an interactive operation.
        
        This request is ignored if there is no operation in progress.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_get_pointer_binding : [> `V2 | `V3 | `V4 | `V5] t -> ([`River_pointer_binding_v1], 'v, [`Server]) Proxy.t ->
                                                    button:int32 -> modifiers:Imports.River_seat_v1.Modifiers.t -> unit
    
    (** Define a new pointer binding.
        
        Define a pointer binding in terms of a pointer button, keyboard
        modifiers, and other configurable properties.
        
        The button argument is a Linux input event code defined in the
        linux/input-event-codes.h header file (e.g. BTN_RIGHT).
        
        The new pointer binding is not enabled until initial configuration is
        completed and the enable request is made during a manage sequence. *)
    
    method private virtual on_set_xcursor_theme : [> `V2 | `V3 | `V4 | `V5] t -> name:string -> size:int32 -> unit
    
    (** Set the xcursor theme for the seat.
        
        Set the XCursor theme for the seat. This theme is used for cursors
        rendered by the compositor, but not necessarily for cursors rendered by
        clients.
        
        Note: The window manager may also wish to set the XCURSOR_THEME and
        XCURSOR_SIZE environment variable for programs it starts. *)
    
    method private virtual on_pointer_warp : [> `V3 | `V4 | `V5] t -> x:int32 -> y:int32 -> unit
    
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
    
    method min_version = 2l
  end
  
  (** Handler for a proxy with version >= 3. *)
  class virtual ['v] v3 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_destroy : [> `V3 | `V4 | `V5] t -> unit
    
    (** Destroy the seat object.
        
        This request indicates that the client will no longer use the seat
        object and that it may be safely destroyed.
        
        This request should be made after the river_seat_v1.removed event is
        received to complete destruction of the seat. *)
    
    method private virtual on_focus_window : [> `V3 | `V4 | `V5] t -> window:([`River_window_v1], [> Imports.River_window_v1.versions], [`Server]) Proxy.t ->
                                             unit
    
    (** Give keyboard focus to a window.
        
        Request that the compositor send keyboard input to the given window.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_focus_shell_surface : [> `V3 | `V4 | `V5] t -> shell_surface:([`River_shell_surface_v1], [> Imports.River_shell_surface_v1.versions], [`Server]) Proxy.t ->
                                                    unit
    
    (** Give keyboard focus to a shell_surface.
        
        Request that the compositor send keyboard input to the given shell
        surface.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_clear_focus : [> `V3 | `V4 | `V5] t -> unit
    
    (** Clear keyboard focus.
        
        Request that the compositor not send keyboard input to any client.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_op_start_pointer : [> `V3 | `V4 | `V5] t -> unit
    
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
    
    method private virtual on_op_end : [> `V3 | `V4 | `V5] t -> unit
    
    (** End an interactive operation.
        
        End an interactive operation.
        
        This request is ignored if there is no operation in progress.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_get_pointer_binding : [> `V3 | `V4 | `V5] t -> ([`River_pointer_binding_v1], 'v, [`Server]) Proxy.t ->
                                                    button:int32 -> modifiers:Imports.River_seat_v1.Modifiers.t -> unit
    
    (** Define a new pointer binding.
        
        Define a pointer binding in terms of a pointer button, keyboard
        modifiers, and other configurable properties.
        
        The button argument is a Linux input event code defined in the
        linux/input-event-codes.h header file (e.g. BTN_RIGHT).
        
        The new pointer binding is not enabled until initial configuration is
        completed and the enable request is made during a manage sequence. *)
    
    method private virtual on_set_xcursor_theme : [> `V3 | `V4 | `V5] t -> name:string -> size:int32 -> unit
    
    (** Set the xcursor theme for the seat.
        
        Set the XCursor theme for the seat. This theme is used for cursors
        rendered by the compositor, but not necessarily for cursors rendered by
        clients.
        
        Note: The window manager may also wish to set the XCURSOR_THEME and
        XCURSOR_SIZE environment variable for programs it starts. *)
    
    method private virtual on_pointer_warp : [> `V3 | `V4 | `V5] t -> x:int32 -> y:int32 -> unit
    
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
    
    method min_version = 3l
  end
  
  (** Handler for a proxy with version >= 4. *)
  class virtual ['v] v4 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_destroy : [> `V4 | `V5] t -> unit
    
    (** Destroy the seat object.
        
        This request indicates that the client will no longer use the seat
        object and that it may be safely destroyed.
        
        This request should be made after the river_seat_v1.removed event is
        received to complete destruction of the seat. *)
    
    method private virtual on_focus_window : [> `V4 | `V5] t -> window:([`River_window_v1], [> Imports.River_window_v1.versions], [`Server]) Proxy.t ->
                                             unit
    
    (** Give keyboard focus to a window.
        
        Request that the compositor send keyboard input to the given window.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_focus_shell_surface : [> `V4 | `V5] t -> shell_surface:([`River_shell_surface_v1], [> Imports.River_shell_surface_v1.versions], [`Server]) Proxy.t ->
                                                    unit
    
    (** Give keyboard focus to a shell_surface.
        
        Request that the compositor send keyboard input to the given shell
        surface.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_clear_focus : [> `V4 | `V5] t -> unit
    
    (** Clear keyboard focus.
        
        Request that the compositor not send keyboard input to any client.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_op_start_pointer : [> `V4 | `V5] t -> unit
    
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
    
    method private virtual on_op_end : [> `V4 | `V5] t -> unit
    
    (** End an interactive operation.
        
        End an interactive operation.
        
        This request is ignored if there is no operation in progress.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_get_pointer_binding : [> `V4 | `V5] t -> ([`River_pointer_binding_v1], 'v, [`Server]) Proxy.t ->
                                                    button:int32 -> modifiers:Imports.River_seat_v1.Modifiers.t -> unit
    
    (** Define a new pointer binding.
        
        Define a pointer binding in terms of a pointer button, keyboard
        modifiers, and other configurable properties.
        
        The button argument is a Linux input event code defined in the
        linux/input-event-codes.h header file (e.g. BTN_RIGHT).
        
        The new pointer binding is not enabled until initial configuration is
        completed and the enable request is made during a manage sequence. *)
    
    method private virtual on_set_xcursor_theme : [> `V4 | `V5] t -> name:string -> size:int32 -> unit
    
    (** Set the xcursor theme for the seat.
        
        Set the XCursor theme for the seat. This theme is used for cursors
        rendered by the compositor, but not necessarily for cursors rendered by
        clients.
        
        Note: The window manager may also wish to set the XCURSOR_THEME and
        XCURSOR_SIZE environment variable for programs it starts. *)
    
    method private virtual on_pointer_warp : [> `V4 | `V5] t -> x:int32 -> y:int32 -> unit
    
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
    
    method min_version = 4l
  end
  
  (** Handler for a proxy with version >= 5. *)
  class virtual ['v] v5 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_destroy : [> `V5] t -> unit
    
    (** Destroy the seat object.
        
        This request indicates that the client will no longer use the seat
        object and that it may be safely destroyed.
        
        This request should be made after the river_seat_v1.removed event is
        received to complete destruction of the seat. *)
    
    method private virtual on_focus_window : [> `V5] t -> window:([`River_window_v1], [> Imports.River_window_v1.versions], [`Server]) Proxy.t ->
                                             unit
    
    (** Give keyboard focus to a window.
        
        Request that the compositor send keyboard input to the given window.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_focus_shell_surface : [> `V5] t -> shell_surface:([`River_shell_surface_v1], [> Imports.River_shell_surface_v1.versions], [`Server]) Proxy.t ->
                                                    unit
    
    (** Give keyboard focus to a shell_surface.
        
        Request that the compositor send keyboard input to the given shell
        surface.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_clear_focus : [> `V5] t -> unit
    
    (** Clear keyboard focus.
        
        Request that the compositor not send keyboard input to any client.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_op_start_pointer : [> `V5] t -> unit
    
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
    
    method private virtual on_op_end : [> `V5] t -> unit
    
    (** End an interactive operation.
        
        End an interactive operation.
        
        This request is ignored if there is no operation in progress.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_get_pointer_binding : [> `V5] t -> ([`River_pointer_binding_v1], 'v, [`Server]) Proxy.t ->
                                                    button:int32 -> modifiers:Imports.River_seat_v1.Modifiers.t -> unit
    
    (** Define a new pointer binding.
        
        Define a pointer binding in terms of a pointer button, keyboard
        modifiers, and other configurable properties.
        
        The button argument is a Linux input event code defined in the
        linux/input-event-codes.h header file (e.g. BTN_RIGHT).
        
        The new pointer binding is not enabled until initial configuration is
        completed and the enable request is made during a manage sequence. *)
    
    method private virtual on_set_xcursor_theme : [> `V5] t -> name:string -> size:int32 -> unit
    
    (** Set the xcursor theme for the seat.
        
        Set the XCursor theme for the seat. This theme is used for cursors
        rendered by the compositor, but not necessarily for cursors rendered by
        clients.
        
        Note: The window manager may also wish to set the XCURSOR_THEME and
        XCURSOR_SIZE environment variable for programs it starts. *)
    
    method private virtual on_pointer_warp : [> `V5] t -> x:int32 -> y:int32 -> unit
    
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
  type 'v t = ([`River_pointer_binding_v1], 'v, [`Server]) Proxy.t
  
  (** {2 Version 1, 2, 3, 4, 5} *)
  
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
  let released (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:1 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
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
  let pressed (_t:([< `V1 | `V2 | `V3 | `V4 | `V5] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:0 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (**/**)
  class virtual ['v] _handlers_unsafe = object (_self : (_, 'v, _) #Proxy.Handler.t)
    method user_data = S.No_data
    method metadata = (module River_window_management_v1_proto.River_pointer_binding_v1)
    method max_version = 5l
    
    method private virtual on_destroy : [> ] t -> unit
    
    method private virtual on_enable : [> ] t -> unit
    
    method private virtual on_disable : [> ] t -> unit
    
    
    method dispatch (_proxy : 'v t) _msg =
      let _proxy = Proxy.cast_version _proxy in
      match Msg.op _msg with
      | 0 ->
        Proxy.shutdown_recv _proxy;
        _self#on_destroy _proxy 
      | 1 ->
        _self#on_enable _proxy 
      | 2 ->
        _self#on_disable _proxy 
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
    method private virtual on_destroy : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Destroy the pointer binding object.
        
        This request indicates that the client will no longer use the pointer
        binding object and that it may be safely destroyed. *)
    
    method private virtual on_enable : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Enable the pointer binding.
        
        This request should be made after all initial configuration has been
        completed and the window manager wishes the pointer binding to be able
        to be triggered.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_disable : [> `V1 | `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Disable the pointer binding.
        
        This request may be used to temporarily disable the pointer binding. It
        may be later re-enabled with the enable request.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method min_version = 1l
  end
  
  (** Handler for a proxy with version >= 2. *)
  class virtual ['v] v2 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V2 | `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_destroy : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Destroy the pointer binding object.
        
        This request indicates that the client will no longer use the pointer
        binding object and that it may be safely destroyed. *)
    
    method private virtual on_enable : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Enable the pointer binding.
        
        This request should be made after all initial configuration has been
        completed and the window manager wishes the pointer binding to be able
        to be triggered.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_disable : [> `V2 | `V3 | `V4 | `V5] t -> unit
    
    (** Disable the pointer binding.
        
        This request may be used to temporarily disable the pointer binding. It
        may be later re-enabled with the enable request.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method min_version = 2l
  end
  
  (** Handler for a proxy with version >= 3. *)
  class virtual ['v] v3 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V3 | `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_destroy : [> `V3 | `V4 | `V5] t -> unit
    
    (** Destroy the pointer binding object.
        
        This request indicates that the client will no longer use the pointer
        binding object and that it may be safely destroyed. *)
    
    method private virtual on_enable : [> `V3 | `V4 | `V5] t -> unit
    
    (** Enable the pointer binding.
        
        This request should be made after all initial configuration has been
        completed and the window manager wishes the pointer binding to be able
        to be triggered.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_disable : [> `V3 | `V4 | `V5] t -> unit
    
    (** Disable the pointer binding.
        
        This request may be used to temporarily disable the pointer binding. It
        may be later re-enabled with the enable request.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method min_version = 3l
  end
  
  (** Handler for a proxy with version >= 4. *)
  class virtual ['v] v4 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V4 | `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_destroy : [> `V4 | `V5] t -> unit
    
    (** Destroy the pointer binding object.
        
        This request indicates that the client will no longer use the pointer
        binding object and that it may be safely destroyed. *)
    
    method private virtual on_enable : [> `V4 | `V5] t -> unit
    
    (** Enable the pointer binding.
        
        This request should be made after all initial configuration has been
        completed and the window manager wishes the pointer binding to be able
        to be triggered.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_disable : [> `V4 | `V5] t -> unit
    
    (** Disable the pointer binding.
        
        This request may be used to temporarily disable the pointer binding. It
        may be later re-enabled with the enable request.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method min_version = 4l
  end
  
  (** Handler for a proxy with version >= 5. *)
  class virtual ['v] v5 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V5] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_destroy : [> `V5] t -> unit
    
    (** Destroy the pointer binding object.
        
        This request indicates that the client will no longer use the pointer
        binding object and that it may be safely destroyed. *)
    
    method private virtual on_enable : [> `V5] t -> unit
    
    (** Enable the pointer binding.
        
        This request should be made after all initial configuration has been
        completed and the window manager wishes the pointer binding to be able
        to be triggered.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method private virtual on_disable : [> `V5] t -> unit
    
    (** Disable the pointer binding.
        
        This request may be used to temporarily disable the pointer binding. It
        may be later re-enabled with the enable request.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method min_version = 5l
  end
end