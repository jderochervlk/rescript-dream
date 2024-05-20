let count = ref(0)

let countRequests = handler => {
  async request => {
    count := count.contents + 1
    await handler(request)
  }
}

let _ = DreamExpress.run(
  (async _ => Dream.html(`Saw ${count.contents->Int.toString} request(s)!`))
  ->countRequests
  ->Dream.logger,
)
