%%% -------------------------------------------------------------------
%%% @author  : Joq Erlang
%%% @doc: : 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(master). 

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
%-include("log.hrl").
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% Key Data structures
%% 
%% --------------------------------------------------------------------
-record(state,{}).


%% --------------------------------------------------------------------
%% Definitions 
-define(HeartbeatInterval,60*1000).
%% --------------------------------------------------------------------

-export([
	 new/0
	]).


-export([boot/1,
	 crash_test/2,
	 start/0,
	 stop/0,
	 ping/0,
	 heartbeat/1
	]).

%% gen_server callbacks
-export([init/1, handle_call/3,handle_cast/2, handle_info/2, terminate/2, code_change/3]).


%% ====================================================================
%% External functions
%% ====================================================================

%% Asynchrounus Signals
boot(EnvArgsStr)->
   % io:format("TRansformed ~p~n",[args_to_term:transform(EnvArgsStr)]),
    EnvArgsTuples=args_to_term:transform(EnvArgsStr),
    [application:set_env(?MODULE,Par,Val)||{Par,Val}<-EnvArgsTuples],
  %  io:format("GetEnv ~p~n",[[application:get_env(?MODULE,Par)||{Par,_Val}<-EnvArgsTuples]]),
    ok=application:start(?MODULE),
    ok.


%% Gen server functions
start()-> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
stop()-> gen_server:call(?MODULE, {stop},infinity).

ping()-> 
    gen_server:call(?MODULE, {ping},infinity).

crash_test(A,B)->
    gen_server:call(?MODULE, {crash_test,A,B},infinity).
    
%%-----------------------------------------------------------------------



new()->
    gen_server:call(?MODULE, {new},infinity). 


%%---------------------------------------------------------------------
heartbeat(Interval)->
    gen_server:cast(?MODULE, {heartbeat,Interval}).


%% ====================================================================
%% Server functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%
%% --------------------------------------------------------------------
init(_Args) ->
    spawn(fun()->h_beat(?HeartbeatInterval) end),
    {ok, #state{}}.   
    
%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (aterminate/2 is called)
%% --------------------------------------------------------------------
handle_call({ping},_From,State) ->
    Reply={pong,node(),?MODULE},
    {reply, Reply, State};

handle_call({crash_test,A,B},_From,State) ->
    Reply=A/B,
    {reply, Reply, State};



handle_call({new},_From,State) ->
    Reply=rpc:call(node(),master_lib,new,[],2*5000),
    {reply, Reply, State};


handle_call({stop}, _From, State) ->
    {stop, normal, shutdown_ok, State};

handle_call(Request, From, State) ->
    %?LOG_INFO(error,{unmatched_signal,Request,From}),
    Reply = {unmatched_signal,?MODULE,Request,From},
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% -------------------------------------------------------------------
handle_cast({heartbeat,HeartbeatInterval}, State) ->
    %% Check REsult
    io:format("heartbeat  ~p~n",[{?MODULE,?LINE}]),
    spawn(fun()->h_beat(HeartbeatInterval) end),
    {noreply, State};

handle_cast(Msg, State) ->
    io:format("unmatched match cast ~p~n",[{?MODULE,?LINE,Msg}]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------

handle_info(Info, State) ->
    io:format("unmatched match info ~p~n",[{?MODULE,?LINE,Info}]),
    {noreply, State}.


%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------
%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% Internal functions
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
h_beat(HeartbeatInterval)->

    timer:sleep(HeartbeatInterval),

    rpc:cast(node(),?MODULE,hearbeat,[HeartbeatInterval]).
			       
				   
			   
					   
   
    
