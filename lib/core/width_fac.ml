type t = float

let of_float f = Float.(min f 1.0 |> max 0.1)
let to_float wf = wf
let presets = [ 1.0 /. 3.0; 0.5; 2.0 /. 3.0 ]

let cycle wf =
  match List.find_opt (fun p -> Float.compare p wf > 0) presets with
  | None -> List.hd presets
  | Some p -> p
;;
