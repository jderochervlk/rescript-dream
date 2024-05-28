module Route: {
  type t
  type pathMatch
  type isMatch
  type match
  @module("path-to-regexp")
  external match: string => match = "match"
  let make: string => string => option<{.}>
}
type method = GET | POST | PUT | DELETE | HEAD | CONNECT | OPTIONS | TRACE | PATCH

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

module Headers: {
  type header = (string, string)
  type t = array<header>
  let toObject: option<t> => {..}
}

module Response: {
  type body = string
  external body: 'a => body = "%identity"
  type t = {
    headers?: Headers.t,
    status: status,
    url?: string,
    json?: RescriptCore.JSON.t,
    body?: body,
  }
  external make: t => t = "%identity"
  let status: t => int
}

module Request: {
  type t = {method: method, url: string, urlParams: option<{.}>, body: unknown}
  let param: (option<{.}>, string) => option<'a>
}

type handler = Request.t => promise<Response.t>
type middleware = handler => handler
type path = Route.t
type route = Route(path, method, handler)
let get: (string, handler) => route
let post: (string, handler) => route
let router: array<route> => Request.t => RescriptCore.Promise.t<Response.t>
let json: 'a => Response.t
let html: ('a, ~status: status=?) => Response.t
let sendStatus: status => Response.t
let logger: middleware
