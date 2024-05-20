// TODO: make this a real function
external transformRequest: Express.req => Dream.Request.t = "%identity"

@send external append: (Express.res, string, string) => Express.res = "append"

@send external setHeaders: (Express.res, {..}) => Express.res = "set"

let run = (~port=8080, handler: Dream.handler) => {
  let app = Express.express()

  app->Express.use((req, res, next) => {
    let _ = handler(req->transformRequest)->Promise.thenResolve(response => {
      let body = response.body
      let _ =
        res
        ->Express.status(response->Dream.Response.status)
        ->Express.send(body)
        ->setHeaders(response.headers->Dream.headersToObject)
      next()
    })
  })

  app->Express.listenWithCallback(port, _ => {
    Js.Console.log(`Listening on http://localhost:${port->Int.toString}`)
  })
}
