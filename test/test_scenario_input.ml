let check_input_rules_add ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check input rules add" h []
  @@ fun () ->
  oxctl "input rules mouse --name Logitech.* --natural-scroll enabled --accel-speed 0.5";
  oxctl "input rules mouse --name .* --left-handed enabled";
  oxctl "input rules list"
;;

let check_input_rules_remove ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check input rules remove" h []
  @@ fun () ->
  oxctl "input rules mouse --name Logitech.* --natural-scroll enabled";
  oxctl "input rules mouse --name .* --left-handed enabled";
  oxctl "input rules mouse --name Razer.* --natural-scroll disabled";
  oxctl "input rules mouse --name SteelSeries.* --accel-speed 0.5";
  oxctl "input rules mouse --name Kensington.* --scroll-factor 2.0";
  oxctl "input rules remove 0";
  oxctl "input rules list";
  oxctl "input rules remove 5";
  oxctl "input rules remove 0,2,3";
  oxctl "input rules list"
;;

(* NOTE this is a test of oxbow internals. It does not prove anything about
   Oxbow_wire.Emit *)
let check_input_touchpad_settings ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check input touchpad settings" h []
  @@ fun () ->
  oxctl "input touchpad --name .* --click-method button-areas";
  oxctl "input touchpad --name .* --tap enabled";
  oxctl "input touchpad --name .*"
;;

(* NOTE this is a test of oxbow internals. It does not prove anything about
   Oxbow_wire.Emit *)
let check_input_mouse_settings ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check input mouse settings" h []
  @@ fun () ->
  oxctl "input mouse --name Logitech.* --natural-scroll enabled --accel-speed 0.5";
  oxctl "input mouse --name .* --left-handed enabled";
  oxctl "input mouse --name .*"
;;

let () =
  Harness.run
  @@ fun ({ Harness.fake; section; _ } as h) ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0");
  check_input_rules_add h;
  check_input_rules_remove h;
  check_input_touchpad_settings h;
  check_input_mouse_settings h
;;
