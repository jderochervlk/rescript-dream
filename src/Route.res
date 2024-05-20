type t = string => option<{.}>

type m = {
  path: string,
  params: {.},
}

@unboxed
type isMatch =
  | Match(option<m>)
  | @as(false) False

type match = string => isMatch

@module("path-to-regexp")
external match: string => match = "match"

let make = url => {
  let fn = match(url)
  path =>
    switch fn(path) {
    | Match(t) => t->Option.map(t => t.params)
    | _ => None
    }
}
