let _ = DreamExpress.run(
  Dream.router([
    Dream.get("/", async _ => Dream.html("Good morning, world?")),
    Dream.get("/echo/:word", async ({urlParams}) => {
      let name = urlParams->Dream.Request.param("word")
      Dream.html(name)
    }),
  ]),
)
