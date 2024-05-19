// let router = Dream.router([
//   Dream.get("/", async _ => {
//     Dream.html(
//       <html>
//         <head>
//           <script src="https://unpkg.com/htmx.org@1.9.12" />
//         </head>
//         <button hxGet="/data" hxTarget="#data"> {Lite.string("Get data")} </button>
//         <div id="data" />
//       </html>,
//     )
//   }),
//   Dream.get("/data", async _ => {
//     Dream.html(<div> {"Data!"->Lite.string} </div>)
//   }),
// ])

// let logger = Dream.logger("tiny")

// let _ = DreamExpress.run(router->logger)

