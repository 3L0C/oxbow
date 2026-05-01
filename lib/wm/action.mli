(** [handle_window_request wm window request] carries out [request] on [window].

    {b Effects:} mutates WM state; sends River request

    {b Timing:} manage cycle *)
val handle_window_request :
   Types.window_manager ->
  Types.window ->
  Types.window_request ->
  unit

(** [handle_action wm seat action] carries out [action] on behalf of [seat].

    {b Effects:} mutates WM state; sends River request; I/O

    {b Timing:} manage cycle

    @raise [Types.Finished]*)
val handle_action :
   Types.window_manager ->
  Types.seat ->
  Ocdwm_ipc.Types.action ->
  unit
