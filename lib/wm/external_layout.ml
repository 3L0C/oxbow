type t =
  { data : Layout_data.t
  ; compute : Compute.t
  ; exec : string
  ; mutable proc : int option
  }
