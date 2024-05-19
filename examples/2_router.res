let _ = DreamExpress.run(
  Dream.router([
    Dream.get("/", async (_, ~params=[]) => Dream.html("Good morning, world!")),
    Dream.get("/echo/:word", async (_, ~params=[]) => {
      let name = params->Array.getUnsafe(0)
      Dream.html(name)
    }),
  ]),
)
