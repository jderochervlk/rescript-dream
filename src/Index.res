// open Express

// let app = express()

// app->get("/", (_req, res) => {
//   let _ =
//     res
//     ->status(200)
//     ->send(
//       <html>
//         <head>
//           <script src="https://unpkg.com/htmx.org@1.9.12" />
//         </head>
//         <button hxGet="/data" hxTarget="#data" hxVals={`{"foo": "bar"}`->JSON.parseExn}>
//           {Lite.string("Get data")}
//         </button>
//         <div id="data" />
//       </html>,
//     )
// })

// app->get("/data", (_req, res) => {
//   // Console.log(_req)
//   let _ =
//     res
//     ->status(200)
//     ->send(<div> {"Data!"->Lite.string} </div>)
// })

let port = 8081
// let _ = app->listenWithCallback(port, _ => {
//   Js.Console.log(`Listening on http://localhost:${port->Belt.Int.toString}`)
// })
// let mainHandler =
let app = Express.express()

let router = Dream.router([
  Dream.get("/", _ => {
    Promise.resolve(
      Dream.html(
        <html>
          <head>
            <script src="https://unpkg.com/htmx.org@1.9.12" />
          </head>
          <button hxGet="/data" hxTarget="#data"> {Lite.string("Get data")} </button>
          <div id="data" />
        </html>,
      ),
    )
    // Promise.resolve(Response.make(`{"Hello": "world"}`))
  }),
  Dream.get("/data", _ => {
    Promise.resolve(Dream.html(<div> {"Data!"->Lite.string} </div>))
  }),
])

let _ = Dream.DreamExpress.run(8081, router->Dream.logger)
