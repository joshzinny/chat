-module(chat).

%% API exports
-export([start/0, stop/0, listen/0]).

-define(DEFAULT_CHAT_PORT, 2000).

%%====================================================================
%% API functions
%%====================================================================
start() ->
    spawn(chat_hub, start, []),
    spawn(?MODULE, listen, []).


stop() ->
    chat_hub ! shutdown,
    exit(whereis(chat), kill).

listen() ->
    register(chat, self()),
    {ok, Socket} = gen_tcp:listen(?DEFAULT_CHAT_PORT, [listen, {active, false}, {reuseaddr, true}]),
    await_connection(Socket).

await_connection(Socket) ->
    {ok, Connection} = gen_tcp:accept(Socket),
    Client = spawn(chat_client, start, []),
    gen_tcp:controlling_process(Connection, Client),
    Client ! {socket, Connection},
    await_connection(Socket).
%%====================================================================
%% Internal functions
%%====================================================================
