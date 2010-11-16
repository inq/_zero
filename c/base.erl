-module(c.base).
-export([hello/1]).
-import(io).

hello(Arg) ->
  io:format("~w~n", [Arg]).
