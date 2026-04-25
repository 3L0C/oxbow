(* ocdwm core types - shared type definitions *)

type 'a rect = {
  x : 'a;
  y : 'a;
  w : 'a;
  h : 'a;
}

type direction =
  | Dir_next
  | Dir_prev
  | Dir_left
  | Dir_right
  | Dir_up
  | Dir_down

type 'a delta =
  | Abs of 'a
  | Rel of 'a

type stack_kind =
  | Stack_even
  | Stack_diminish
  | Stack_dwindle
