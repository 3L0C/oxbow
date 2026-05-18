open Ocdwm_core
open Cmdliner
open Cmdliner.Term.Syntax

let conv : Target.t Arg.Conv.t =
  let parser s = Ok (Target.of_string s) in
  let pp ppf t = Format.fprintf ppf "%s" (Target.to_string t) in
  Arg.Conv.make ~docv:"OUTPUT" ~parser ~pp ()
;;
