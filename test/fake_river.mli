type t

(** [start ~sw socket] serves the river globals on [socket].

    {b Effects:} I/O *)
val start : sw:Eio.Switch.t -> _ Eio_unix.Net.stream_socket -> t

(** [tick t] runs one manage sequence, then one render sequence.  It returns
    after render_finish arrives.

    {b Effects:} sends Wayland events *)
val tick : t -> unit

(** [add_output t ~name] announces one output, then ticks.

    {b Effects:} sends Wayland events *)
val add_output : t -> name:string -> unit

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

(** [close_window t ~app_id] sends closed on the first window with [app_id],
    then ticks.

    {b Effects:} sends Wayland events *)
val close_window : t -> app_id:string option -> unit

(** [press_binding t ~index] sends pressed on binding [index], outside a
    sequence. Bindings count in creation order.

    {b Effects:} sends Wayland events *)
val press_binding : t -> index:int -> unit

(** [trace t] returns the recorded requests, oldest first. *)
val trace : t -> string list

(** [manage_dirty_count t] counts the manage_dirty requests. *)
val manage_dirty_count : t -> int

(** [binding_count t] counts the xkb bindings, in creation order. *)
val binding_count : t -> int

(** [idle t] is true when no sequence runs and no update is due. *)
val idle : t -> bool
