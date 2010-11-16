-module(script).
-export([parse/1, render/2]).

parse(Data) -> lists:reverse(closed(Data, [], [])).

% render
render([], _) -> [];
render([H|T], Env) ->
  case H of
    {inline, Inline} ->
      Result = case erl_eval:exprs(Inline, Env) of
	{value, V, _} when is_integer(V) ->
	  integer_to_list(V);
	{value, V, _} when is_float(V) ->
	  float_to_list(V);
	{value, V, _} when is_list(V) ->
	  V;
	{value, V, _} ->
	  io:format("~w", [V])
      end,
      [Result|render(T, Env)];
    {data, Data} ->
      [Data|render(T, Env)]
  end.

% interpret
interp(Inline) ->
  {ok, Tokens, _} = erl_scan:string(Inline),
  {ok, Form} = erl_parse:parse_exprs(Tokens),
  Form.


% the bracket is not opened yet
closed([], Acc, Result) -> 
  [{data, lists:reverse(Acc)}|Result];
closed([$<,$%|R], Acc, Result) -> 
  {Inline, Remain} =  opened(R, []),
  case Acc of
    [] ->
      closed(Remain, [], [{inline, interp(Inline)}|Result]);
    _ ->
      closed(Remain, [], [{inline, interp(Inline)},{data, lists:reverse(Acc)}|Result])
  end;
closed([C|R], Acc, Result) -> 
  closed(R, [C|Acc], Result).
  
% after opening the bracket
opened([$\\,C|R], Acc, T) ->
  opened(R, [C,$\\|Acc], T);
opened([T|R], Acc, T) ->
  opened(R, [T|Acc]);
opened([C|R], Acc, T) ->
  opened(R, [C|Acc], T).

opened([$\\,C|R], Acc) ->
  opened(R, [$\\,C|Acc]);
opened([C=$'|R], Acc) ->
  opened(R, [C|Acc], C);
opened([C=$"|R], Acc) ->
  opened(R, [C|Acc], C);
opened([$%,$>|R], Acc) ->
  {lists:reverse(Acc), R};
opened([C|R], Acc) ->
  opened(R, [C|Acc]).
