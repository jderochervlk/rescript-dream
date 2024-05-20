let _ = DreamExpress.run(
  Dream.router([
    Dream.get("/echo", async _ => Dream.html("echo")),
    Dream.post("/echo", async ({body}) => {
      Dream.json(body)
    }),
  ]),
)
