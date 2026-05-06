type manage
type render
type 'p t = { wm : Types.Window_manager.t }

let wm c = c.wm
let with_manage wm f = f { wm }
let with_render wm f = f { wm }
