(* This file was generated automatically by wayland-scanner-ocaml *)

[@@@ocaml.warning "-27-34"]
open struct
  module Imports = struct
    include River_input_management_v1_proto
  end
  
  module Proxy = Wayland.Proxy
  module Msg = Wayland.Msg
  module Fixed = Wayland.Fixed
  module Iface_reg = Wayland.Iface_reg
  module S = Wayland.S
end


(** Input manager global interface.
    
    Input manager global interface. *)
module River_input_manager_v1 = struct
  type 'v t = ([`River_input_manager_v1], 'v, [`Client]) Proxy.t
  module Error = River_input_management_v1_proto.River_input_manager_v1.Error
  
  (** {2 Version 1, 2} *)
  
  (** Destroy a seat.
      
      Destroy the seat with the given name. Has no effect if a seat with the
      given name does not exist.
      
      The default seat with name "default" cannot be destroyed and attempting
      to destroy it will have no effect.
      
      Any input devices assigned to the destroyed seat at the time of
      destruction are assigned to the default seat. *)
  let destroy_seat (_t:([< `V1 | `V2] as 'v) t) ~name =
    let _msg = Proxy.alloc _t ~op:3 ~ints:1 ~strings:[(Some name)] ~arrays:[] in
    Msg.add_string _msg name;
    Proxy.send _t _msg
  
  (** Create a new seat.
      
      Create a new seat with the given name. Has no effect if a seat with the
      given name already exists.
      
      The default seat with name "default" always exists and does not need to
      be explicitly created. *)
  let create_seat (_t:([< `V1 | `V2] as 'v) t) ~name =
    let _msg = Proxy.alloc _t ~op:2 ~ints:1 ~strings:[(Some name)] ~arrays:[] in
    Msg.add_string _msg name;
    Proxy.send _t _msg
  
  (** Destroy the river_input_manager_v1 object.
      
      This request should be called after the finished event has been received
      to complete destruction of the object.
      
      It is a protocol error to make this request before the finished event
      has been received.
      
      If a client wishes to destroy this object it should send a
      river_input_manager_v1.stop request and wait for a
      river_input_manager_v1.finished event. Once the finished event is
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
      for a river_input_manager_v1.finished event before destroying this
      object. *)
  let stop (_t:([< `V1 | `V2] as 'v) t)  =
    let _msg = Proxy.alloc _t ~op:0 ~ints:0 ~strings:[] ~arrays:[] in
    Proxy.send _t _msg
  
  (**/**)
  class virtual ['v] _handlers_unsafe = object (_self : (_, 'v, _) #Proxy.Handler.t)
    method user_data = S.No_data
    method metadata = (module River_input_management_v1_proto.River_input_manager_v1)
    method max_version = 2l
    
    method private virtual on_finished : [> ] t -> unit
    
    method private virtual on_input_device : [> ] t -> ([`River_input_device_v1], 'v, [`Client]) Proxy.t -> unit
    
    
    method dispatch (_proxy : 'v t) _msg =
      let _proxy = Proxy.cast_version _proxy in
      match Msg.op _msg with
      | 0 ->
        _self#on_finished _proxy 
      | 1 ->
        let id : ([`River_input_device_v1], _, _) Proxy.t =
          Msg.get_int _msg |> Proxy.Handler.accept_new _proxy (module Imports.River_input_device_v1) in
        _self#on_input_device _proxy id
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
    
    (** The server has finished with the input manager.
        
        This event indicates that the server will send no further events on this
        object. The client should destroy the object. See
        river_input_manager_v1.destroy for more information. *)
    
    method private virtual on_input_device : [> `V1 | `V2] t -> ([`River_input_device_v1], 'v, [`Client]) Proxy.t ->
                                             unit
    
    (** New input device.
        
        A new input device has been created. *)
    
    method min_version = 1l
    method bind_version : [`V1] = `V1
  end
  
  (** Handler for a proxy with version >= 2. *)
  class virtual ['v] v2 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V2] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_finished : [> `V2] t -> unit
    
    (** The server has finished with the input manager.
        
        This event indicates that the server will send no further events on this
        object. The client should destroy the object. See
        river_input_manager_v1.destroy for more information. *)
    
    method private virtual on_input_device : [> `V2] t -> ([`River_input_device_v1], 'v, [`Client]) Proxy.t -> unit
    
    (** New input device.
        
        A new input device has been created. *)
    
    method min_version = 2l
    method bind_version : [`V2] = `V2
  end
end

(** An input device.
    
    An input device represents a physical keyboard, mouse, touchscreen, or
    drawing tablet tool. It is assigned to exactly one seat at a time.
    By default, all input devices are assigned to the default seat. *)
module River_input_device_v1 = struct
  type 'v t = ([`River_input_device_v1], 'v, [`Client]) Proxy.t
  module Error = River_input_management_v1_proto.River_input_device_v1.Error
  
  module Type = River_input_management_v1_proto.River_input_device_v1.Type
  
  (** {2 Version 1} *)
  
  (** Map input device to the given rectangle.
      
      Map the input device to the given rectangle in the global compositor
      coordinate space. Has no effect if the device is not a pointer, touch,
      or tablet device.
      
      If mapped to both an output and a rectangle, the rectangle has priority.
      
      Width and height must be greater than or equal to 0.
      
      Passing 0 for width or height clears an existing mapping. *)
  let map_to_rectangle (_t:([< `V1 | `V2] as 'v) t) ~x ~y ~width ~height =
    let _msg = Proxy.alloc _t ~op:5 ~ints:4 ~strings:[] ~arrays:[] in
    Msg.add_int _msg x;
    Msg.add_int _msg y;
    Msg.add_int _msg width;
    Msg.add_int _msg height;
    Proxy.send _t _msg
  
  (** Map input device to the given output.
      
      Map the input device to the given output. Has no effect if the device is
      not a pointer, touch, or tablet device.
      
      If mapped to both an output and a rectangle, the rectangle has priority.
      
      Passing null clears an existing mapping. *)
  let map_to_output (_t:([< `V1 | `V2] as 'v) t) ~(output:([`Wl_output], _, [`Client]) Proxy.t option) =
    let _msg = Proxy.alloc _t ~op:4 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_int _msg (Proxy.id_opt output);
    Proxy.send _t _msg
  
  (** Set scroll factor.
      
      Set the scroll factor for a pointer input device. Has no effect if the
      device is not a pointer.
      
      For example, a factor of 0.5 will make scrolling twice as slow while a
      factor of 3.0 will make scrolling 3 times as fast.
      
      Setting a scroll factor less than 0 is a protocol error. *)
  let set_scroll_factor (_t:([< `V1 | `V2] as 'v) t) ~factor =
    let _msg = Proxy.alloc _t ~op:3 ~ints:1 ~strings:[] ~arrays:[] in
    Msg.add_fixed _msg factor;
    Proxy.send _t _msg
  
  (** Set keyboard repeat rate and delay.
      
      Set repeat rate and delay for a keyboard input device. Has no effect if
      the device is not a keyboard.
      
      Negative values for either rate or delay are illegal. A rate of zero
      will disable any repeating (regardless of the value of delay). *)
  let set_repeat_info (_t:([< `V1 | `V2] as 'v) t) ~rate ~delay =
    let _msg = Proxy.alloc _t ~op:2 ~ints:2 ~strings:[] ~arrays:[] in
    Msg.add_int _msg rate;
    Msg.add_int _msg delay;
    Proxy.send _t _msg
  
  (** Assign the input device to a seat.
      
      Assign the input device to a seat. All input devices not explicitly
      assigned to a seat are considered assigned to the default seat.
      
      Has no effect if a seat with the given name does not exist. *)
  let assign_to_seat (_t:([< `V1 | `V2] as 'v) t) ~name =
    let _msg = Proxy.alloc _t ~op:1 ~ints:1 ~strings:[(Some name)] ~arrays:[] in
    Msg.add_string _msg name;
    Proxy.send _t _msg
  
  (** Destroy the input device object.
      
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
    method metadata = (module River_input_management_v1_proto.River_input_device_v1)
    method max_version = 2l
    
    method private virtual on_removed : [> ] t -> unit
    
    method private virtual on_type : [> ] t -> type_:Imports.River_input_device_v1.Type.t -> unit
    
    method private virtual on_name : [> ] t -> name:string -> unit
    
    method private virtual on_done : [> ] t -> unit
    
    
    method dispatch (_proxy : 'v t) _msg =
      let _proxy = Proxy.cast_version _proxy in
      match Msg.op _msg with
      | 0 ->
        _self#on_removed _proxy 
      | 1 ->
        let type_ = Msg.get_int _msg |> Imports.River_input_device_v1.Type.of_int32 in
        _self#on_type _proxy ~type_
      | 2 ->
        let name = Msg.get_string _msg in
        _self#on_name _proxy ~name
      | 3 ->
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
    
    (** The input device is removed.
        
        This event indicates that the input device has been removed.
        
        The server will send no further events on this object and ignore any
        request (other than river_input_device_v1.destroy) made after this event is
        sent. The client should destroy this object with the
        river_input_device_v1.destroy request to free up resources. *)
    
    method private virtual on_type : [> `V1 | `V2] t -> type_:Imports.River_input_device_v1.Type.t -> unit
    
    (** The type of the input device.
        
        The type of the input device. This event is sent once when the
        river_input_device_v1 object is created. The device type cannot
        change during the lifetime of the object. *)
    
    method private virtual on_name : [> `V1 | `V2] t -> name:string -> unit
    
    (** The name of the input device.
        
        The name of the input device. This event is sent once when the
        river_input_device_v1 object is created. The device name cannot
        change during the lifetime of the object. *)
    
    method private virtual on_done : [> `V2] t -> unit
    
    (** All information has been sent.
        
        This event is sent after all information about the input device has
        been sent.
        
        This allows changes to one or more river_input_device_v1 properties to
        be seen as atomic, even if they happen via multiple events. *)
    
    method min_version = 1l
  end
  
  (** Handler for a proxy with version >= 2. *)
  class virtual ['v] v2 = object (_ : (_, 'v, _) #Proxy.Service_handler.t)
    (**/**)
    inherit [[< `V2] as 'v] _handlers_unsafe
    (**/**)
    method private virtual on_removed : [> `V2] t -> unit
    
    (** The input device is removed.
        
        This event indicates that the input device has been removed.
        
        The server will send no further events on this object and ignore any
        request (other than river_input_device_v1.destroy) made after this event is
        sent. The client should destroy this object with the
        river_input_device_v1.destroy request to free up resources. *)
    
    method private virtual on_type : [> `V2] t -> type_:Imports.River_input_device_v1.Type.t -> unit
    
    (** The type of the input device.
        
        The type of the input device. This event is sent once when the
        river_input_device_v1 object is created. The device type cannot
        change during the lifetime of the object. *)
    
    method private virtual on_name : [> `V2] t -> name:string -> unit
    
    (** The name of the input device.
        
        The name of the input device. This event is sent once when the
        river_input_device_v1 object is created. The device name cannot
        change during the lifetime of the object. *)
    
    method private virtual on_done : [> `V2] t -> unit
    
    (** All information has been sent.
        
        This event is sent after all information about the input device has
        been sent.
        
        This allows changes to one or more river_input_device_v1 properties to
        be seen as atomic, even if they happen via multiple events. *)
    
    method min_version = 2l
  end
end