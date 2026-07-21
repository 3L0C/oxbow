type t = float

let of_float f = Float.(min f 1.0 |> max 0.1)
let to_float wf = wf
