type t = { pid : int }

(** [resolve ?override_path ()] is the resolved init-script path:
    1. [override_path] if given
    2. $XDG_CONFIG_HOME/oxbow/init
    3. $HOME/.config/oxbow/init
    Only a path that exists and is executable counts; otherwise [None]. *)
val resolve : ?override_path:string -> unit -> string option

(** [fork ~cmd] runs [cmd] with [/bin/sh -c cmd] in a fresh session and returns
    the child pid. *)
val fork : cmd:string -> t

(** [shutdown script] signals [SIGTERM] to the script's whole process group.
    Swallows ESRCH (already gone); warns on other errno (e.g. EPERM). *)
val shutdown : t -> unit
