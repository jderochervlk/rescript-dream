let _ = DreamExpress.run(
  Dream.router([
    Dream.get("/", async _ => Dream.html("Good morning, world!")),
    Dream.get("/echo/:word", async _ => Dream.html("Good morning, world!")),
  ]),
)

let filterEmptyStrings = (arr: array<string>): array<string> => {
  arr->Array.filter(s => s != "")
}
