module Select = struct
  type t =
    | Best [@name "best"]
    | Cycle [@name "cycle"]
  [@@deriving yojson]
end

module Window = struct
  module One = struct
    type t =
      | Focused [@name "focused"]
      | Matching of
          { wmatch : Window_match.t
          ; select : Select.t
          } [@name "matching"]
    [@@deriving yojson]
  end

  module Any = struct
    type t =
      | One of One.t [@name "one"]
      | All of { wmatch : Window_match.t } [@name "all"]
    [@@deriving yojson]
  end
end

module Output = struct
  module One = struct
    type t =
      | Focused [@name "focused"]
      | Matching of
          { omatch : Output_match.t
          ; select : Select.t
          } [@name "matching"]
    [@@deriving yojson]
  end

  module Any = struct
    type t =
      | One of One.t [@name "one"]
      | All of { omatch : Output_match.t } [@name "all"]
    [@@deriving yojson]
  end
end
