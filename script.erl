-module(script).
-export([parse/1]).

parse(Data) -> lists:reverse(closed(Data, [], [])).

% yet the bracket is not opened
closed([], Acc, Result) -> 
  [{data, lists:reverse(Acc)}|Result];
closed([$<,$%|R], Acc, Result) -> 
  {Inline, Remain} =  opened(R, []),
  case Acc of
    [] ->
      closed(Remain, [], [{inline, Inline}|Result]);
    _ ->
      closed(Remain, [], [{inline, Inline},{data, lists:reverse(Acc)}|Result])
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
