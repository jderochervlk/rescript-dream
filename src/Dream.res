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
  open Webapi.Fetch
  type t = Request.t
  let method = Request.method_
  let url = Request.url
}

type handler = Request.t => promise<Response.t>

type middleware = handler => handler

type path = string

type route = Get(path, handler)

let get = (path, handler) => Get(path, handler)

let router = (routes: array<route>) => (request: Request.t) => {
  let requestMethod = request->Request.method
  let requestPath = request->Request.url

  // Console.log(requestPath)

  switch (requestMethod, requestPath) {
  | (Get, requestPath) =>
    switch routes->Array.find(route =>
      switch route {
      | Get(path, _) => path === requestPath
      }
    ) {
    | Some(Get(_, handler)) => handler(request)
    | None => Promise.resolve(Response.make({status: NotFound}))
    }
  | _ => Promise.resolve(Response.make({status: NotFound}))
  }
}

external toJson: {..} => JSON.t = "%identity"

let json = t => Response.make({json: t->toJson, status: Ok})

let html = (e, ~status=Ok) => Response.make({body: e->Response.body, status})

module Morgan = {
  type logger = (Request.t, Response.t, unit => unit) => unit
  @module("morgan")
  external make: string => logger = "default"
}

let logger: string => middleware = string => {
  let log = Morgan.make(string)
  handler => {
    request => {
      let response = handler(request)
      response->Promise.then(res => {
        let _ = log(request, res, () => ()) // TODO: I am guessing this doesn't work since I am not using a real request object
        Promise.resolve(res)
      })
    }
  }
}
