-module(boot).
-export([start/0]).

start() ->
  tcp:listen(9090).
