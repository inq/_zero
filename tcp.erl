-module(tcp).
-export([listen/1]).
-export([eval/2]).

-define(TCP_OPTIONS, 
	[binary, {packet, 0}, {active, false}, {reuseaddr, true}]).

-record(http_request, {method, path, version}).

eval(Code, Args) ->
  {ok, Scanned, _} = erl_scan:string(Code),
  {ok, Parsed} = erl_parse:parse_exprs(Scanned),
  Bindings = lists:foldl(fun ({Key, Val}, Result) ->
			     erl_eval:add_binding(Key, Val, Result)
			 end, erl_eval:new_bindings(), Args),
  {value, Result, _} = erl_eval:exprs(Parsed, Bindings),
  Result.
  

listen(Port) ->
  {ok, LSocket} = gen_tcp:listen(Port, ?TCP_OPTIONS),
  accept(LSocket).

accept(LSocket) ->
  {ok, Socket} = gen_tcp:accept(LSocket),
  spawn(fun() -> recv_request(Socket) end),
  accept(LSocket).

% Receive HTTP headers
recv_header(Socket, Request, Header) ->
  ok = inet:setopts(Socket, [{packet, httph}]),
  case gen_tcp:recv(Socket, 0) of
    {ok, {http_header, _, Field, _, Value}} ->
      recv_header(Socket, Request, dict:append(Field, Value, Header));
    {ok, http_eoh}->
      route:parse(Socket, Request, Header);
    {ok, _} ->
      io:format("FUCK")
    end.

% Receive HTTP request
recv_request(Socket) ->
  ok = inet:setopts(Socket, [{packet, http}]),
  case gen_tcp:recv(Socket, 0) of
    {ok, Request} when is_record(Request, http_request) ->
      io:format("~w ~w ~w ~n", [Request#http_request.method,
				Request#http_request.path,
			        Request#http_request.version]),
      recv_header(Socket, Request, dict:new());
    {error, closed} ->
      io:format("connection closed"),
      ok;
    _ ->
      io:format("fucking"),
      ok
  end.

