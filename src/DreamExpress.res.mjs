// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Dream from "./Dream.res.mjs";
import Express from "express";

function run(portOpt, handler) {
  var port = portOpt !== undefined ? portOpt : 8080;
  var app = Express();
  app.use(function (req, res, next) {
        handler(req).then(function (response) {
              var body = response.body;
              console.log(response.body);
              res.status(Dream.$$Response.status(response)).send(body).set(Dream.headersToObject(response.headers));
              next();
            });
      });
  return app.listen(port, (function (param) {
                console.log("Listening on http://localhost:" + port.toString());
              }));
}

export {
  run ,
}
/* Dream Not a pure module */
