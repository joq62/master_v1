%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(master_tests).     
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include_lib("eunit/include/eunit.hrl").
%% --------------------------------------------------------------------

%% External exports
-export([start/0,
	cleanup/0]).



%% ====================================================================
%% External functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
start()->
    ?debugMsg("Start setup"),
    ?assertEqual(ok,setup()),
    ?debugMsg("stop setup"),
    
   
    ?debugMsg("Start new_test "),
    ?assertEqual(ok, new_test()),
    ?debugMsg("Stop new_test"),
    %% End application tests
    
    ?debugMsg("Start cleanup"),
    ?assertEqual(ok,cleanup()),
    ?debugMsg("Stop cleanup"),

    ?debugMsg("------>"++atom_to_list(?MODULE)++" ENDED SUCCESSFUL ---------"),
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
setup()->
     EnvArgsTuples=[{git_user,"joq62"}, 
		    {git_pw,"20Qazxsw20"},
		    {cl_dir,"cluster_config"},
		    {cl_file,"cluster_info.hrl"},
		    {app_specs_dir,"app_specs"},
		    {service_specs_dir,"service_specs"},
		    {int_test,42}],
  
    ?assertMatch([{ok,_},{ok,_},
		  {ok,"cluster_config"},{ok,"cluster_info.hrl"},
		  {ok,"app_specs"},
		  {ok,"service_specs"},
		  {ok,42}],
		  [rpc:call(misc_node:node("master"),application,get_env,[master,Par],2000)||{Par,_Val}<-EnvArgsTuples]),

    {badrpc,_}=rpc:call(misc_node:node("master"),master,crash_test,[1,0],2000),

    ?assertMatch([{ok,_},{ok,_},
		  {ok,"cluster_config"},{ok,"cluster_info.hrl"},
		  {ok,"app_specs"},
		  {ok,"service_specs"},
		  {ok,42}],
		 [rpc:call(misc_node:node("master"),application,get_env,[master,Par],2000)||{Par,_Val}<-EnvArgsTuples]),
    rpc:call(misc_node:node("master"),application,stop,[master],2000),
    ok=rpc:call(misc_node:node("master"),application,start,[master],2000),

    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------    

cleanup()->
    rpc:call(misc_node:node("master"), init,stop,[]),
    init:stop(),
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
new_test()->
    
    ?assertEqual([],
		 rpc:call(misc_node:node("master"),db_server,read_all,[],2000)),
    
     ?assertEqual(ok,rpc:call(misc_node:node("master"),master,new,[])),
    ?assertMatch([{"c2",_,_,"192.168.0.202",22,not_available},
		  {"c1",_,_,"192.168.0.201",22,not_available},
		  {"c0",_,_,"192.168.0.200",22,not_available}],
		 rpc:call(misc_node:node("master"),db_server,read_all,[],2000)),

    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
