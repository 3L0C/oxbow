(* ocdwm ipc types - shared type definitions *)

module Subscriber = struct
  type t =
    { mutable fd : Unix.file_descr
    ; mutable events : string list
      (* TODO: shouldn't this be a better type than [string]? *)
    }
end

module Ipc_conn = struct
  type t =
    { socket_path : string
    ; server_fd : Unix.file_descr
    ; mutable subscribers : Subscriber.t list
    }
end

module Ipc_state = struct
  type t =
    | Ipc_inactive
    | Ipc_active of Ipc_conn.t
end
