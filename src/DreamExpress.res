external transformRequest: Express.req => Dream.request = "%identity"
external transformStatus: Dream.Status.t => int = "%identity"

@send external append: (Express.res, string, string) => Express.res = "append"

let run = (~port=8080, handler: Dream.handler) => {
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
