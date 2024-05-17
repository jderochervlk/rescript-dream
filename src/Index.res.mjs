// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Lite from "@jvlk/rescript-lite-jsx/src/lite.res.mjs";
import * as Dream from "./Dream.res.mjs";
import Express from "express";

var app = Express();

var router = Dream.router([
      Dream.get("/", (async function (param) {
              return Dream.html(Lite.Elements.jsxs("html", {
                              children: [
                                Lite.Elements.jsx("head", {
                                      children: Lite.Elements.jsx("script", {
                                            src: "https://unpkg.com/htmx.org@1.9.12"
                                          })
                                    }),
                                Lite.Elements.jsx("button", {
                                      children: "Get data",
                                      "hx-get": "/data",
                                      "hx-target": "#data"
                                    }),
                                Lite.Elements.jsx("div", {
                                      id: "data"
                                    })
                              ]
                            }), undefined);
            })),
      Dream.get("/data", (async function (param) {
              return Dream.html(Lite.Elements.jsx("div", {
                              children: "Data!"
                            }), undefined);
            }))
    ]);

Dream.DreamExpress.run(8081, Dream.logger(router));

var port = 8081;

export {
  port ,
  app ,
  router ,
}
/* app Not a pure module */
