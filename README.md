# @jvlk/rescript-dream
A functional ReScript server framework for Javascript runtimes.
Currently supports Express and Bun.

Inspired and heavily based on [Dream for OCaml](https://aantron.github.io/dream/).

## Installation
```bash
npm i @jvlk/rescript-dream
```
Modify your project's `rescript.json` file.
```diff
{
    "bs-dependencies": [
+       "@jvlk/rescript-dream"
    ]
}
```

You might also want some JSX bindings to support returning HTML from the server. You can use any JSX bindings you like, but I recommend [`@jvlk/rescript-lite-jsx`](https://github.com/jderochervlk/rescript-lite-jsx).

## Example
Check out the example folder for more examples, but here's a basic server with HTMX.

```rescript
let router = Dream.router([
  Dream.get("/", async _ => {
    Dream.html(
      <html>
        <head>
          <script src="https://unpkg.com/htmx.org@1.9.12" />
        </head>
        <button hxGet="/data" hxTarget="#data"> {Lite.string("Get data")} </button>
        <div id="data" />
      </html>,
    )
  }),
  Dream.get("/data", async _ => {
    Dream.html(<div> {"Data!"->Lite.string} </div>)
  }),
])

// You can also use DreamExpress.run
let _ = DreamBun.run(router->Dream.logger)
```