exception Failure(string)

let successful = ref(0)
let failed = ref(0)

let countRequests = handler => {
  async request => {
    try {
      let response = await handler(request)
      successful := successful.contents + 1
      response
    } catch {
    | _ => {
        failed := failed.contents + 1
        Dream.sendStatus(InternalServerError)
      }
    }
  }
}

let _ = DreamExpress.run(
  Dream.router([
    Dream.get("/fail", async _ => {
      raise(Failure("The Web app failed!"))
    }),
    Dream.get("/", async _ =>
      Dream.html(
        `${successful.contents->Int.toString} request(s) successful <br/> ${failed.contents->Int.toString} request(s) failed`,
      )
    ),
  ])
  ->countRequests
  ->Dream.logger,
)
