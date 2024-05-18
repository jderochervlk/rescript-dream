type t

@module("path-to-regexp")
external pathToRegexp: string => t = "pathToRegexp"

@send
external exec: (t, string) => nullable<array<string>> = "exec"

let validatePrefix = prefix => {
  let prefix = String.startsWith("/", prefix) ? prefix : "/" ++ prefix
  String.endsWith("/", prefix) ? prefix : prefix ++ "/"
}
let validateSuffix = (suffix: string) => {
  let suffix = String.startsWith("/", suffix) ? suffix : "/" ++ suffix
  String.endsWith("/", suffix) ? String.slice(~start=0, ~end=-1, suffix) : suffix
}

let validateParameter = parameter =>
  parameter->String.startsWith(":") ? parameter : ":" ++ parameter

let validateNParameter = (suffix: string) => {
  let suffix = String.startsWith("/:", suffix) ? suffix : "/:" ++ suffix
  suffix
}

let route = route => {
  let r = pathToRegexp(route)
  str =>
    switch r->exec(str) {
    | Value(_) => Some(true)
    | Null => None
    | Undefined => None
    }
}

let route1 = (p1, ~prefix="", ~suffix="") => {
  let r = pathToRegexp(prefix->validatePrefix ++ p1->validateParameter ++ suffix->validateSuffix)
  str =>
    switch r->exec(str) {
    | Value(t) => t[1]
    | Null => None
    | Undefined => None
    }
}

let route2 = (p1, p2, ~prefix1="", ~suffix1="", ~prefix2="", ~suffix2="") => {
  let r = pathToRegexp(
    prefix1->validatePrefix ++
    p1->validateParameter ++
    suffix1->validateSuffix ++
    prefix2->validatePrefix ++
    p2->validateNParameter ++
    suffix2->validateSuffix,
  )
  str => {
    switch r->exec(str) {
    | Value(t) => Some(t[1]->Option.getUnsafe, t[2]->Option.getUnsafe)
    | Null => None
    | Undefined => None
    }
  }
}

let _ = route1("word", ~prefix="echo")("/echo/foo")->Console.log
let _ = route2("first", "last", ~prefix1="name")("/name/josh/vlk")->Console.log
