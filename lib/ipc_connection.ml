type t =
  { socket_path : string
  ; server_fd : Unix.file_descr
  ; mutable subscribers : Subscriber.t list
  }
