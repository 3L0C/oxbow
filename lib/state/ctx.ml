type manage
type render
type 'p t = { wm : Types.Wm.t }

let wm c = c.wm
let with_manage wm f = Schedule.with_tick (fun () -> f { wm })
let with_render wm f = f { wm }
