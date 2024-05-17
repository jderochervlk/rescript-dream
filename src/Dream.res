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
  type t =
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
    | @as(300) MultipleChoices
    | @as(301) MovedPermanently
    | @as(302) Found
    | @as(303) SeeOther
    | @as(304) NotModified
    | @as(305) UseProxy
    | @as(307) TemporaryRedirect
    | @as(308) PermanentRedirect
    | @as(400) BadRequest
    | @as(401) Unauthorized
    | @as(402) PaymentRequired
    | @as(403) Forbidden
    | @as(404) NotFound
    | @as(405) MethodNotAllowed
    | @as(406) NotAcceptable
    | @as(407) ProxyAuthenticationRequired
    | @as(408) RequestTimeout
    | @as(409) Conflict
    | @as(410) Gone
    | @as(411) LengthRequired
    | @as(412) PreconditionFailed
    | @as(413) PayloadTooLarge
    | @as(414) URITooLong
    | @as(415) UnsupportedMediaType
    | @as(416) RangeNotSatisfiable
    | @as(417) ExpectationFailed
    | @as(418) ImATeapot
    | @as(421) MisdirectedRequest
    | @as(422) UnprocessableEntity
    | @as(423) Locked
    | @as(424) FailedDependency
    | @as(425) UnorderedCollection
    | @as(426) UpgradeRequired
    | @as(428) PreconditionRequired
    | @as(429) TooManyRequests
    | @as(431) RequestHeaderFieldsTooLarge
    | @as(451) UnavailableForLegalReasons
    | @as(500) InternalServerError
    | @as(501) NotImplemented
    | @as(502) BadGateway
    | @as(503) ServiceUnavailable
    | @as(504) GatewayTimeout
    | @as(505) HTTPVersionNotSupported
    | @as(506) VariantAlsoNegotiates
    | @as(507) InsufficientStorage
    | @as(508) LoopDetected
    | @as(510) NotExtended
    | @as(511) NetworkAuthenticationRequired
}

type header = (string, string)
type headers = array<header>

// type request = Webapi.Fetch.Request.t

type message = {
  headers?: headers,
  status?: Status.t,
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
    Console.log2("Request received:", request.method)
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
    | None => Promise.resolve({status: NotFound})
    }
  | _ => Promise.resolve({status: NotFound})
  }
}

module DreamExpress = {
  external transformRequest: Express.req => request = "%identity"
  external transformStatus: Status.t => int = "%identity"

  @send external append: (Express.res, string, string) => Express.res = "append"

  let run = (port, handler: handler) => {
    let app = Express.express()

    app->Express.use((req, res, next) => {
      let _ = handler(req->transformRequest)->Promise.thenResolve(response => {
        let _ = switch response.status {
        | Some(status) => res->Express.status(status->transformStatus)
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
        next()
      })
    })

    app->Express.listenWithCallback(port, _ => {
      Js.Console.log(`Listening on http://localhost:${port->Belt.Int.toString}`)
    })
  }
}

external toJson: {..} => JSON.t = "%identity"

let json = t => {json: t->toJson, status: Ok}

external jsxToBody: Jsx.element => string = "%identity"

let html = (e, ~status=Status.Ok) => {body: e->jsxToBody, status}
