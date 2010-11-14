s-module(route).
-export([parse/3]).



parse(Socket, Request, _Header) ->
  case Request of
    {http_request, _Method, {abs_path, [_|Path]}, _Version} ->
      render:file(Socket, Path);
    _ ->
      render:error(Socket)
  end.
