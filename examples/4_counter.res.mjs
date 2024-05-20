// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Dream from "../src/Dream.res.mjs";
import * as DreamExpress from "../src/DreamExpress.res.mjs";

var count = {
  contents: 0
};

function countRequests(handler) {
  return async function (request) {
    count.contents = count.contents + 1 | 0;
    return await handler(request);
  };
}

DreamExpress.run(undefined, Dream.logger(countRequests(async function (param) {
              return Dream.html("Saw " + count.contents.toString() + " request(s)!", undefined);
            })));

export {
  count ,
  countRequests ,
}
/*  Not a pure module */