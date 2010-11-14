-module(render).
-export([error/1, file/2]).
-include_lib("kernel/include/file.hrl").

file_size(Path) ->
  {ok, FileInfo} = file:read_file_info(Path),
  FileInfo#file_info.size.

file(Socket, Path) ->
  case file:read_file(Path) of
    {ok, Binary}->
      gen_tcp:send(Socket, [<<"HTTP/1.1 200 OK\r\n">>,
			    <<"Document-Type:text/html\r\n">>,
			    io_lib:format("Content-Length: ~B\r\n", [file_size(Path)]),
			    <<"\r\n">>,
			    Binary]);
    {error, _}->
      render:error(Socket)
    end.


error(Socket) ->
  gen_tcp:send(Socket, [<<"HTTP/1.1 200 OK\r\n">>,
			<<"Document-Type:text/html\r\n">>,
			<<"Content-length: 20\r\n">>,
			<<"\r\n">>,
			<<"<html><body>Error!!!!</body></html>">>]).
