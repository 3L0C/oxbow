type t =
  | Ipc_inactive
  | Ipc_active of Ipc_connection.t
