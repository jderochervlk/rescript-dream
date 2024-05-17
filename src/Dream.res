type client
type server

type message<'a>

// https://aantron.github.io/dream/#methods
type method_ =
  | GET
  | POST
  | PUT
  | DELETE
  | HEAD
  | CONNECT
  | OPTIONS
  | TRACE
  | PATCH
  | Method(string)
// todo: method functions

// TODO status codes!
module Status = {
  type successful =
    | @as(200) Ok
    | @as(201) Created
    | @as(202) Accepted
    | @as(203) NonAuthoritativeInformation
    | @as(204) NoContent
    | @as(205) ResetContent
    | @as(206) PartialContent
    | @as(207) MultiStatus
    | @as(208) AlreadyReported
    | @as(226) IMUsed

  external set: successful => successful = "%identity"
}

let t1 = Status.set(Created)

type header = (string, string)
type headers = array<header>

type request = Webapi.Fetch.Request.t

type response = {headers?: headers, status?: int, statusText?: string}

type handler = request => promise<response>

type middleware = handler => handler

type path = string

type route = Get(path, handler)

external response: response => response = "%identity"

let get = (path, handler) => Get(path, handler)

let logger: middleware = handler => {
  request => {
    Console.log2("Request received:", "f")
    handler(request)
  }
}

let router = (routes: array<route>) => request => {
  let requestMethod = request->Webapi.Fetch.Request.method_
  let requestPath = request->Webapi.Fetch.Request.url
  switch requestMethod {
  | Get =>
    switch routes->Array.find(route =>
      switch route {
      | Get(path, _) => path === requestPath
      }
    ) {
    | Some(Get(_, handler)) => handler(request)
    | None => Promise.resolve({status: 404})
    }
  | _ => Promise.resolve({status: 404})
  }
}

module DreamExpress = {
  external transformRequest: Express.req => request = "%identity"
  @send external append: (Express.res, string, string) => Express.res = "append"

  let run = (port, handler: handler) => {
    let app = Express.express()

    app->Express.use((req, res, next) => {
      let _ = handler(req->transformRequest)->Promise.thenResolve(response => {
        let headers = response.headers
        let _ = res->Express.append("", "")
        next()
      })
    })

    app->Express.listenWithCallback(port, _ => {
      Js.Console.log(`Listening on http://localhost:${port->Belt.Int.toString}`)
    })
  }
}
