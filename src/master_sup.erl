%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description :
%%%
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(master_sup).

-behaviour(supervisor).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
 
%% --------------------------------------------------------------------
%% Definitions 
-define(HeartbeatInterval,30*1000).
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
%% --------------------------------------------------------------------

-export([heartbeat/1]).
-export([start_link/0]).

%% --------------------------------------------------------------------
%% Internal exports
%% --------------------------------------------------------------------
-export([
	 init/1
        ]).

%% --------------------------------------------------------------------
%% Macros
%% --------------------------------------------------------------------
-define(SERVER, ?MODULE).
%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start, []}, permanent, 5000, Type, [I]}).
%% --------------------------------------------------------------------
%% Records
%% --------------------------------------------------------------------

%% ====================================================================
%% External functions
%% ====================================================================

start_link()->
   supervisor:start_link({local,?MODULE}, ?MODULE,[]).


heartbeat(HeartBeatInterval)->
    spawn(fun()->h_beat(HeartBeatInterval) end).

%% ====================================================================
%% Server functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Func: init/1
%% Returns: {ok,  {SupFlags,  [ChildSpec]}} |
%%          ignore                          |
%%          {error, Reason}
%% --------------------------------------------------------------------
init([]) ->
    spawn(fun()->h_beat(?HeartbeatInterval) end),
    {ok,{{one_for_one,5,10}, 
	 children()
	}
    }.
children()->
    [
     ?CHILD(common,worker),
     ?CHILD(dbase,worker),
     ?CHILD(master,worker),
     ?CHILD(control,worker)
    ].
%% ====================================================================
%% Internal functions
%% ====================================================================
h_beat(HeartBeatInterval)->
    timer:sleep(1000),
    Children=children(),
    PingResult=[M:ping()||{M, {M, _, _}, _, _, _, [M]}<-Children],
    Result=update_sd(PingResult,[]),
    io:format("Result ~p~n",[{time(),Result}]),
    timer:sleep(HeartBeatInterval),
    rpc:cast(node(),?MODULE,heartbeat,[HeartBeatInterval]).

update_sd([],Result) ->
    Result;
update_sd([{pong,Node,Module}|T],Acc)->
    rpc:cast(node(),if_db,call,[db_sd,heartbeat,[Module,Node]]),
    NewAcc=[{ok,Module,Node}|Acc],
    update_sd(T,NewAcc);
update_sd([Reason|T],Acc) ->
    NewAcc=[{error,[Reason,?MODULE,?LINE]}|Acc],
    update_sd(T,NewAcc).
