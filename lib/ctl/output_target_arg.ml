open Ocdwm_core
open Cmdliner
open Cmdliner.Term.Syntax

let conv : Output_target.t Arg.Conv.t =
  let parser s = Ok (Output_target.of_string s) in
  let pp ppf t = Format.fprintf ppf "%s" (Output_target.to_string t) in
  Arg.Conv.make ~docv:"OUTPUT" ~parser ~pp ()
;;
