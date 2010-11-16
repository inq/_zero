-module(boot).
-export([start/0, module_list/1]).

module_list(Dir) ->
  {ok, Files} = file:list_dir(Dir),
  Modules = lists:map(fun(X) -> filename:basename(X, ".erl") end,
		      lists:filter(fun([$.|_]) -> false;
				      (File) -> lists:suffix(".erl", File) end, Files)).
start() ->
  tcp:listen(9090, release).
