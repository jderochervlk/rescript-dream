// https://aantron.github.io/dream/#methods
@unboxed
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

let t = GET

type status =
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

external performance: unit => float = "performance.now"

type header = (string, string)
type headers = array<header>

let headersToObject = (headers: option<headers>) => {
  let obj = Object.make()
  switch headers {
  | Some(headers) =>
    headers->Array.forEach(((key, value)) => {
      obj->Object.set(key, value)
    })
  | None => ignore()
  }

  obj
}

module Response = {
  type body = string

  external body: 'a => body = "%identity"

  type t = {
    headers?: headers,
    status: status,
    url?: string,
    json?: JSON.t,
    body?: body,
  }

  external make: t => t = "%identity"

  let status = res => {
    (res.status :> int)
  }
}

module Request = {
  type t = {
    method: method,
    url: string,
    /* params from the url, i.e. /path/:id becomes [ id ] */
    urlParams: option<{.}>,
    body: unknown,
  }

  let param = (t: option<{.}>, param) => {
    t->Option.flatMap(t => t->Object.get(param))
  }
}

type handler = Request.t => promise<Response.t>

type middleware = handler => handler

type path = Route.t

type route = Route(path, method, handler)
// | Get(path, handler)
// | Post(path, handler)

let get = (path, handler) => Route(path->Route.make, GET, handler)
let post = (path, handler) => Route(path->Route.make, POST, handler)

let router = (routes: array<route>) => (request: Request.t) => {
  let requestMethod = request.method
  let requestPath = request.url

  switch (requestMethod, requestPath) {
  | (GET, requestPath) =>
    switch routes->Array.find(route =>
      switch route {
      | Route(path, GET, _) => path(requestPath)->Option.isSome
      | _ => false
      }
    ) {
    | Some(Route(path, _, handler)) => {
        let params = path(requestPath)
        handler({...request, urlParams: params})
      }
    | None => Promise.resolve(Response.make({status: NotFound}))
    }
  | (POST, requestPath) =>
    switch routes->Array.find(route =>
      switch route {
      | Route(path, POST, _) => path(requestPath)->Option.isSome
      | _ => false
      }
    ) {
    | Some(Route(path, _, handler)) => {
        let params = path(requestPath)
        handler({...request, urlParams: params})
      }
    | None => Promise.resolve(Response.make({status: NotFound}))
    }
  | _ => Promise.resolve(Response.make({status: NotFound}))
  }
}

let json = (t: 'a) =>
  Response.make({
    body: t->JSON.stringifyAny->Option.getExn,
    status: Ok,
    headers: [("Content-Type", "application/octet-stream")],
  })

let html = (e, ~status=Ok) => Response.make({body: e->Response.body, status})

let sendStatus = status => Response.make({body: "", status})

let logger: middleware = handler => {
  async request => {
    let start = performance()
    let response = await handler(request)
    let end = performance() -. start
    Console.log(
      `${(request.method :> string)} - ${request.url} - ${end->Float.toPrecisionWithPrecision(
          ~digits=4,
        )} ms`,
    )
    response
  }
}
