// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Route from "./Route.res.mjs";
import * as Core__Option from "@rescript/core/src/Core__Option.res.mjs";

function headersToObject(headers) {
  var obj = {};
  if (headers !== undefined) {
    headers.forEach(function (param) {
          obj[param[0]] = param[1];
        });
  }
  return obj;
}

function status(res) {
  return res.status;
}

var $$Response = {
  status: status
};

var $$Request = {};

function get(path, handler) {
  return {
          TAG: "Get",
          _0: Route.make(path),
          _1: handler
        };
}

function router(routes) {
  return function (request) {
    var requestMethod = request.method;
    var requestPath = request.url;
    if (requestMethod !== "GET") {
      return Promise.resolve({
                  status: 404
                });
    }
    var match = routes.find(function (route) {
          return Core__Option.isSome(route._0(requestPath));
        });
    if (match === undefined) {
      return Promise.resolve({
                  status: 404
                });
    }
    var params = Core__Option.getOr(match._0(requestPath), []);
    return match._1({
                method: request.method,
                url: request.url,
                urlParams: params
              });
  };
}

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

var Morgan = {};

var t = "GET";

export {
  t ,
  headersToObject ,
  $$Response ,
  $$Request ,
  get ,
  router ,
  json ,
  html ,
  Morgan ,
}
/* Route Not a pure module */
