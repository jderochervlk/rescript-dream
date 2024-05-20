// TODO: make this a real function
external transformRequest: Request.t => Dream.Request.t = "%identity"

let run = (~port=8080, handler: Dream.handler) => {
  let server = Bun.serve({
    port,
    fetch: async (request, _server) => {
      let url = request->Request.url->URL.make->URL.pathname
      let response = await handler({...request->transformRequest, url})
      let headers = HeadersInit.FromArray(response.headers->Option.getOr([]))

      Response.make(
        response.body,
        ~options={
          status: response->Dream.Response.status,
          headers,
        },
      )
    },
  })

  let port =
    server
    ->Bun.Server.port
    ->Int.toString

  let hostName = server->Bun.Server.hostname

  Console.log(`Server listening on http://${hostName}:${port}!`)
}
