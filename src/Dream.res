type client
type server

// https://aantron.github.io/dream/#methods
type method =
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

  type t = successful

  external set: t => t = "%identity"
}

let t1 = Status.set(Created)

type header = (string, string)
type headers = array<header>

// type request = Webapi.Fetch.Request.t

type message = {
  headers?: headers,
  status?: int,
  statusText?: string,
  url?: string,
  method?: method,
  json?: JSON.t,
  body?: string,
}

type response = message
type request = message

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

let router = (routes: array<route>) => (request: message) => {
  let requestMethod = request.method
  let requestPath = request.url

  Console.log(requestPath)

  switch (requestMethod, requestPath) {
  | (Some(GET), Some(requestPath)) =>
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
        let _ = switch response.status {
        | Some(status) => res->Express.status(status)
        | None => res
        }
        let _ = switch response.body {
        | Some(body) => res->Express.send(body)
        | None => res
        }

        let _ = switch response.json {
        | Some(json) => res->Express.json(json)
        | None => res
        }

        // let _headers = response.headers
        // let _ = res->Express.append("", "")
        next()
      })
    })

    app->Express.listenWithCallback(port, _ => {
      Js.Console.log(`Listening on http://localhost:${port->Belt.Int.toString}`)
    })
  }
}

external toJson: {..} => JSON.t = "%identity"

let json = t => {json: t->toJson, status: 200}

external jsxToBody: Jsx.element => string = "%identity"

let html = e => {body: e->jsxToBody, status: 200}
