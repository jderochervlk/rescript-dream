import { pathToRegexp, match, parse, compile } from "path-to-regexp"

let keys = []
let t1 = pathToRegexp("/echo/:word", keys)
console.log(t1.exec("/echo/bar"))

// console.log(match("foo")("foo"))