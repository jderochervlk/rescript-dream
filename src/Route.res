type t

@module("path-to-regexp")
external pathToRegexp: string => t = "pathToRegexp"

@send
external exec: (t, string) => nullable<array<string>> = "exec"

let make = s => {
  let r = s->pathToRegexp
  path =>
    switch r->exec(path) {
    | Value(t) => Some(t->Array.sliceToEnd(~start=1))
    | _ => None
    }
}
