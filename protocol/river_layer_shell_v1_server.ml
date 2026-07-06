(* This file was generated automatically by wayland-scanner-ocaml *)

[@@@ocaml.warning "-27-34"]
open struct
  module Imports = struct
    include River_layer_shell_v1_proto
  end
  
  module Proxy = Wayland.Proxy
  module Msg = Wayland.Msg
  module Fixed = Wayland.Fixed
  module Iface_reg = Wayland.Iface_reg
  module S = Wayland.S
end


(** River layer shell global interface.
    
    This global interface should only be advertised to the client if the
    river_window_manager_v1 global is also advertised. Binding this interface
    indicates that the window manager supports layer shell.
    
    If the window manager does not bind this interface, the compositor should
    not allow clients to map layer surfaces. This can be achieved by
    closing layer surfaces immediately. *)
module River_layer_shell_v1 = struct
  type 'v t = ([`River_layer_shell_v1], 'v, [`Server]) Proxy.t
  module Error = River_layer_shell_v1_proto.River_layer_shell_v1.Error
  
  (** {2 Version 1} *)
  
  (**/**)
  class virtual ['v] _handlers_unsafe = object (_self : (_, 'v, _) #Proxy.Handler.t)
    method user_data = S.No_data
    method metadata = (module River_layer_shell_v1_proto.River_layer_shell_v1)
    method max_version = 1l
    
    method private virtual on_destroy : [> ] t -> unit
    
    method private virtual on_get_output : [> ] t -> ([`River_layer_shell_output_v1], 'v, [`Server]) Proxy.t ->
                                           output:([`River_output_v1], [> Imports.River_output_v1.versions], [`Server]) Proxy.t ->
                                           unit
    
    method private virtual on_get_seat : [> ] t -> ([`River_layer_shell_seat_v1], 'v, [`Server]) Proxy.t ->
                                         seat:([`River_seat_v1], [> Imports.River_seat_v1.versions], [`Server]) Proxy.t ->
                                         unit
    
    
    method dispatch (_proxy : 'v t) _msg =
      let _proxy = Proxy.cast_version _proxy in
      match Msg.op _msg with
      | 0 ->
        Proxy.shutdown_recv _proxy;
        _self#on_destroy _proxy 
      | 1 ->
        let id : ([`River_layer_shell_output_v1], _, _) Proxy.t =
          Msg.get_int _msg |> Proxy.Handler.accept_new _proxy (module Imports.River_layer_shell_output_v1) in
        let output : ([`River_output_v1], _, _) Proxy.t =
          let Proxy.Proxy p = Msg.get_int _msg |> Proxy.lookup_other _proxy in
          match Proxy.ty p with
          | Imports.River_output_v1.T -> p
          | _ -> Proxy.wrong_type ~parent:_proxy ~expected:"river_output_v1" p
          in
        _self#on_get_output _proxy id ~output
      | 2 ->
        let id : ([`River_layer_shell_seat_v1], _, _) Proxy.t =
          Msg.get_int _msg |> Proxy.Handler.accept_new _proxy (module Imports.River_layer_shell_seat_v1) in
        let seat : ([`River_seat_v1], _, _) Proxy.t =
          let Proxy.Proxy p = Msg.get_int _msg |> Proxy.lookup_other _proxy in
          match Proxy.ty p with
          | Imports.River_seat_v1.T -> p
          | _ -> Proxy.wrong_type ~parent:_proxy ~expected:"river_seat_v1" p
          in
        _self#on_get_seat _proxy id ~seat
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
    method private virtual on_destroy : [> `V1] t -> unit
    
    (** Destroy the river_layer_shell_v1 object.
        
        This request indicates that the client will no longer use the
        river_layer_shell_v1 object. *)
    
    method private virtual on_get_output : [> `V1] t -> ([`River_layer_shell_output_v1], 'v, [`Server]) Proxy.t ->
                                           output:([`River_output_v1], [> Imports.River_output_v1.versions], [`Server]) Proxy.t ->
                                           unit
    
    (** Get layer shell output state.
        
        It is a protocol error to make this request more than once for a given
        river_output_v1 object. *)
    
    method private virtual on_get_seat : [> `V1] t -> ([`River_layer_shell_seat_v1], 'v, [`Server]) Proxy.t ->
                                         seat:([`River_seat_v1], [> Imports.River_seat_v1.versions], [`Server]) Proxy.t ->
                                         unit
    
    (** Get layer shell seat state.
        
        It is a protocol error to make this request more than once for a given
        river_seat_v1 object. *)
    
    method min_version = 1l
    method bind_version : [`V1] = `V1
  end
end

(** Layer shell output state.
    
    The lifetime of this object is tied to the corresponding river_output_v1.
    This object is made inert when the river_output_v1.removed event is sent
    and should be destroyed. *)
module River_layer_shell_output_v1 = struct
  type 'v t = ([`River_layer_shell_output_v1], 'v, [`Server]) Proxy.t
  
  (** {2 Version 1} *)
  
  (** Area left after subtracting exclusive zones.
      
      This event indicates the area of the output remaining after subtracting
      the exclusive zones of layer surfaces. Exclusive zones are a hint, the
      window manager is free to ignore this area hint if it wishes.
      
      The x and y values are in the global coordinate space, not relative to
      the position of the output.
      
      This event will be followed by a manage_start event after all other new
      state has been sent by the server. *)
  let non_exclusive_area (_t:([< `V1] as 'v) t) ~x ~y ~width ~height =
    let _msg = Proxy.alloc _t ~op:0 ~ints:4 ~strings:[] ~arrays:[] in
    Msg.add_int _msg x;
    Msg.add_int _msg y;
    Msg.add_int _msg width;
    Msg.add_int _msg height;
    Proxy.send _t _msg
  
  (**/**)
  class virtual ['v] _handlers_unsafe = object (_self : (_, 'v, _) #Proxy.Handler.t)
    method user_data = S.No_data
    method metadata = (module River_layer_shell_v1_proto.River_layer_shell_output_v1)
    method max_version = 1l
    
    method private virtual on_destroy : [> ] t -> unit
    
    method private virtual on_set_default : [> ] t -> unit
    
    
    method dispatch (_proxy : 'v t) _msg =
      let _proxy = Proxy.cast_version _proxy in
      match Msg.op _msg with
      | 0 ->
        Proxy.shutdown_recv _proxy;
        _self#on_destroy _proxy 
      | 1 ->
        _self#on_set_default _proxy 
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
    method private virtual on_destroy : [> `V1] t -> unit
    
    (** Destroy the object.
        
        This request indicates that the client will no longer use the
        river_layer_shell_output_v1 object and that it may be safely destroyed.
        
        This request should be made after the river_output_v1.removed event is
        received to complete destruction of the output. *)
    
    method private virtual on_set_default : [> `V1] t -> unit
    
    (** Set default output for layer surfaces.
        
        Mark this output as the default for new layer surfaces which do not
        request a specific output themselves. This request overrides any
        previous set_default request on any river_layer_shell_output_v1 object.
        
        If no set_default request is made or if the default output is destroyed,
        the default output is undefined until the next set_default request.
        
        This request modifies window management state and may only be made as
        part of a manage sequence, see the river_window_manager_v1 description. *)
    
    method min_version = 1l
  end
end

(** Layer shell seat state.
    
    The lifetime of this object is tied to the corresponding river_seat_v1.
    This object is made inert when the river_seat_v1.removed event is sent and
    should be destroyed. *)
module River_layer_shell_seat_v1 = struct
  type 'v t = ([`River_layer_shell_seat_v1], 'v, [`Server]) Proxy.t
  
  (** {2 Version 1} *)
  
  (** No layer shell surface has focus.
      
      No layer shell surface will have keyboard focus at the end of the manage
      sequence in which this event is sent. The window manager may want to
      return focus to whichever window last had focus, for example.
      
      This event will be followed by a manage_start event after all other new
      state has been sent by the server. *)
  let focus_none (_t:([< `V1] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:2 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (** Layer shell surface wants non-exclusive focus.
      
      A layer shell surface will be given non-exclusive keyboard focus at the
      end of the manage sequence in which this event is sent. The window
      manager may want to update window decorations or similar to indicate
      that no window is focused.
      
      The window manager continues to control focus and may choose to focus a
      different window/shell surface at any time. If the window manager sets
      focus during the same manage sequence in which this event is sent, the
      layer surface will not be focused.
      
      If the layer surface with non-exclusive focus is closed or the window
      manager chooses to move focus away from the layer surface, a focus_none
      event will be sent in the next manage sequence.
      
      This event will be followed by a manage_start event after all other new
      state has been sent by the server. *)
  let focus_non_exclusive (_t:([< `V1] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:1 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (** Layer shell surface has exclusive focus.
      
      A layer shell surface will be given exclusive keyboard focus at the end
      of the manage sequence in which this event is sent. The window manager
      may want to update window decorations or similar to indicate that no
      window is focused.
      
      Until the focus_non_exclusive or focus_none event is sent, all window
      manager requests to change focus are ignored.
      
      This event will be followed by a manage_start event after all other new
      state has been sent by the server. *)
  let focus_exclusive (_t:([< `V1] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:0 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (**/**)
  class virtual ['v] _handlers_unsafe = object (_self : (_, 'v, _) #Proxy.Handler.t)
    method user_data = S.No_data
    method metadata = (module River_layer_shell_v1_proto.River_layer_shell_seat_v1)
    method max_version = 1l
    
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
  class virtual ['v] v1 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V1] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_destroy : [> `V1] t -> unit
    
    (** Destroy the object.
        
        This request indicates that the client will no longer use the
        river_layer_shell_seat_v1 object and that it may be safely destroyed.
        
        This request should be made after the river_seat_v1.removed event is
        received to complete destruction of the seat. *)
    
    method min_version = 1l
  end
end