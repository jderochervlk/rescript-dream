// Generated by ReScript, PLEASE EDIT WITH CARE

import Express from "express";

var Status = {};

function get(path, handler) {
  return {
          TAG: "Get",
          _0: path,
          _1: handler
        };
}

function logger(handler) {
  return function (request) {
    console.log("Request received:", request.method);
    return handler(request);
  };
}

function router(routes) {
  return function (request) {
    var requestMethod = request.method;
    var requestPath = request.url;
    console.log(requestPath);
    if (requestMethod !== undefined && typeof requestMethod !== "object" && requestMethod === "GET" && requestPath !== undefined) {
      var match = routes.find(function (route) {
            return route._0 === requestPath;
          });
      if (match !== undefined) {
        return match._1(request);
      } else {
        return Promise.resolve({
                    status: 404
                  });
      }
    }
    return Promise.resolve({
                status: 404
              });
  };
}

function run(port, handler) {
  var app = Express();
  app.use(function (req, res, next) {
        handler(req).then(function (response) {
              var status = response.status;
              if (status !== undefined) {
                res.status(status);
              }
              var body = response.body;
              if (body !== undefined) {
                res.send(body);
              }
              var json = response.json;
              if (json !== undefined) {
                res.json(json);
              }
              next();
            });
      });
  return app.listen(port, (function (param) {
                console.log("Listening on http://localhost:" + String(port));
              }));
}

var DreamExpress = {
  run: run
};

function json(t) {
  return {
          status: 200,
          json: t
        };
}

function html(e, statusOpt) {
  var status = statusOpt !== undefined ? statusOpt : 200;
  return {
          status: status,
          body: e
        };
}

export {
  Status ,
  get ,
  logger ,
  router ,
  DreamExpress ,
  json ,
  html ,
}
/* express Not a pure module */
