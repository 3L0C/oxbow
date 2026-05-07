open! Ocdwm_core

let accept_loop ~sw ~wm socket =
  while true do
    let flow, _addr = Eio.Net.accept ~sw socket in
    Eio.Fiber.fork ~sw (fun () ->
      try Ipc_handler.run ~wm flow with
      | exn -> Logs.warn (fun m -> m "ipc handler crashed: %s" (Printexc.to_string exn)))
  done
;;

let start ~sw ~net ~wm =
  let path = Socket_path.resolve () in
  let socket = Eio.Net.listen ~sw ~backlog:128 ~reuse_addr:true net (`Unix path) in
  Eio.Fiber.fork ~sw (fun () -> accept_loop ~sw ~wm socket);
  Logs.info (fun m -> m "ipc: listening on %s" path)
;;
