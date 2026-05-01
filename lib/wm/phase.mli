(** [during_cycle wm op f] runs [f] when [wm.phase <> P_idle]. Logs [op] warning
    otherwise. *)
val during_cycle :
   Types.window_manager ->
  op:string ->
  (unit -> unit) ->
  unit

(** [during_manage wm op f] runs [f] when [wm.phase = P_manage]. Logs [op]
    warning otherwise. *)
val during_manage :
   Types.window_manager ->
  op:string ->
  (unit -> unit) ->
  unit

(** [outside_cycle wm op f] runs [f] when [wm.phase = P_idle]. Logs [op] warning
    otherwise. *)
val outside_cycle :
   Types.window_manager ->
  op:string ->
  (unit -> unit) ->
  unit
