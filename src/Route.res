type re

@module("path-to-regexp")
external pathToRegexp: string => re = "pathToRegexp"

@send
external exec: (re, string) => nullable<array<string>> = "exec"

type t = string => option<array<string>>

let make = s => {
  let r = s->pathToRegexp
  path =>
    switch r->exec(path) {
    | Value(t) => Some(t->Array.sliceToEnd(~start=1))
    | _ => None
    }
}
