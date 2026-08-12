type t

(** [start ~sw socket] serves the river globals on [socket].

    {b Effects:} I/O *)
val start : sw:Eio.Switch.t -> _ Eio_unix.Net.stream_socket -> t

(** [tick t] runs one manage sequence, then one render sequence.  It returns
    after render_finish arrives.

    {b Effects:} sends Wayland events *)
val tick : t -> unit

(** [add_output ?x ?y t ~name] announces one output at ([x], [y]),
    default (0, 0), then ticks.

    {b Effects:} sends Wayland events *)
val add_output : ?x:int32 -> ?y:int32 -> t -> name:string -> unit

(** [add_seat t ~name] announces one seat, then ticks.

    {b Effects:} sends Wayland events *)
val add_seat : t -> name:string -> unit

(** [add_window ?pid t ~app_id] announces one window, then ticks. When [pid]
    is present, the unreliable_pid event follows the app_id event.

    {b Effects:} sends Wayland events *)
val add_window : ?pid:int -> t -> app_id:string option -> unit

(** [send_dimensions_hint t ~app_id ~min_w ~min_h ~max_w ~max_h] sends
    dimensions_hint on the first window with [app_id], then ticks.

    {b Effects:} sends Wayland events *)
val send_dimensions_hint
  :  t
  -> app_id:string option
  -> min_w:int32
  -> min_h:int32
  -> max_w:int32
  -> max_h:int32
  -> unit

(** [send_capture_sessions t ~app_id ~count] sends capture_sessions on the first
    window with [app_id], then ticks.

    {b Effects:} sends Wayland events *)
val send_capture_sessions : t -> app_id:string option -> count:int32 -> unit

(** [send_output_capture_sessions t ~name ~count] sends output_capture_sessions
    on the first output with [name], then ticks.

    {b Effects:} sends Wayland events *)
val send_output_capture_sessions : t -> name:string -> count:int32 -> unit

(** [close_window t ~app_id] sends closed on the first window with [app_id],
    then ticks.

    {b Effects:} sends Wayland events *)
val close_window : t -> app_id:string option -> unit

(** [press_binding t ~index] sends pressed on binding [index], outside a
    sequence. Bindings count in creation order.

    {b Effects:} sends Wayland events *)
val press_binding : t -> index:int -> unit

(** [send_pointer_enter t ~seat ~app_id] sends pointer_enter on the first window
    with [app_id], then ticks.

    {b Effects:} sends Wayland events *)
val send_pointer_enter : t -> seat:string -> app_id:string option -> unit

(** [send_pointer_position t ~seat ~x ~y] sends pointer_position ([x], [y]) on
    [seat], then ticks.

    {b Effects:} sends Wayland events *)
val send_pointer_position : t -> seat:string -> x:int32 -> y:int32 -> unit

(** [send_pointer_hover t ~seat ~app_id ~x ~y] sends pointer_enter on the first
    window with [app_id], then pointer_position ([x], [y]), then ticks once.

    {b Effects:} sends Wayland events *)
val send_pointer_hover
  :  t
  -> seat:string
  -> app_id:string option
  -> x:int32
  -> y:int32
  -> unit

(** [send_op_delta t ~seat ~dx ~dy] sends op_delta ([dx], [dy]) on [seat], then
    ticks.

    {b Effects:} sends Wayland events *)
val send_op_delta : t -> seat:string -> dx:int32 -> dy:int32 -> unit

(** [send_op_release t ~seat] sends op_release on [seat], then ticks.

    {b Effects:} sends Wayland events *)
val send_op_release : t -> seat:string -> unit

(** [trace t] returns the recorded requests, oldest first. *)
val trace : t -> string list

(** [manage_dirty_count t] counts the manage_dirty requests. *)
val manage_dirty_count : t -> int

(** [binding_count t] counts the xkb bindings, in creation order. *)
val binding_count : t -> int

(** [idle t] is true when no sequence runs and no update is due. *)
val idle : t -> bool
