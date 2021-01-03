%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Create1d : 10 dec 2012
%%% -------------------------------------------------------------------
-module(master_lib). 
    
%% --------------------------------------------------------------------
%% Include files

%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Definitions
-define(Terminal,'terminal@c2').
-define(Cookie,"abc").
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% External exports
-export([boot/1,
	 init_dbase/0]).

%% ====================================================================
%% External functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
boot(EnvArgsStr)->
    
    %% Start
    %% Set master env 
    [application:set_env(master,Par,Val)||
	{Par,Val}<-args_to_term:transform(EnvArgsStr)],
   
   % start local common 
    misc_oam:print("StartCommon ~p~n",[common:start()]),
   % start dbase
    misc_oam:print("Start Dbase ~p~n",[dbase:start()]),
   % Update local dbase for boot
    init_dbase(),
  
   
    %% 1. Start ssh 
    ssh:start(),
    
    % 2. Check and update machine status
    StatusMachines=machine:status(all),
    misc_oam:print("StatusMachines ~p~n",[StatusMachines]),
    ok=machine:update_status(StatusMachines),
    

    %% 3. Check namen of MasterVm and start that one
   

    {ok,MasterAppSpec}=application:get_env(master,app_spec),
    misc_oam:print("MasterAppSpec ~p~n",[MasterAppSpec]),
    [MasterAppInfo]=db_app_spec:read(MasterAppSpec),
    {AppSpecId,AppVsn,master,Directives,Services}=MasterAppInfo,
    {host,HostId}=lists:keyfind(host,1,Directives),
    {vm_id,VmId}=lists:keyfind(vm_id,1,Directives),
    {vm_dir,VmDir}=lists:keyfind(vm_dir,1,Directives),
    
    MasterNode=list_to_atom(VmId++"@"++HostId),
    {ok,MasterNode}=vm:create(HostId,VmId,VmDir,?Cookie),
    misc_oam:print("MasterNode ~p~n",[MasterNode]),
    
    %% Start now on Master Node same procedure as in boot
    %% 1. ssh start
    misc_oam:print("Start ssh ~p~n",[rpc:call(MasterNode,ssh,start,[],2000)]),
    
    %% Set application env on MasterNode
    misc_oam:print("Set application env ~p~n",[[rpc:call(MasterNode,application,set_env,[master,Par,Val],2000)||
					 {Par,Val}<-args_to_term:transform(EnvArgsStr)]]),
    
    %% 2. Create Services
    CreateResult=[service:create(ServiceSpecId,VmDir,MasterNode)||ServiceSpecId<-Services],
    misc_oam:print("Start master services ~p~n ",[CreateResult]),
    {pong,_,master}=rpc:call(MasterNode,master,ping,[],200),
    %% Init Dbase
    misc_oam:print("InitDbase ~p~n ",[rpc:call(MasterNode,master_lib,init_dbase,[],2*5000)]),
    
    %% Update Sd with 
    
    misc_oam:print("sd_create ~p~n",[[{rpc:call(MasterNode,db_sd,create,[ServiceId,
									 ServiceVsn,
									 AppSpecId,AppVsn,
									 HostId,
									 VmId,
									 VmDir,
									 MasterNode],5000),ServiceId,ServiceVsn}||{ok,ServiceId,ServiceVsn}<-CreateResult]]),
    
    %% creat lock
    {atomic,ok}=rpc:call(MasterNode,db_lock,create,[{db_lock,schedule}],2000),

 % 2. Check and update machine status
    StatusMachines2=rpc:call(MasterNode,machine,status,[all],2*5000),
    misc_oam:print("StatusMachines2 ~p~n",[StatusMachines2]),
    ok=rpc:call(MasterNode,machine,update_status,[StatusMachines2],5000),
    
    
    % Terminate and remove boot master 
    application:stop(master),
    {badrpc,_}=rpc:call(node(),master,ping,[],2000),
    % End boot sequence
    misc_oam:print("End boot sequence ~p~n",[{'End boot sequence',?MODULE,?LINE}]),
    ok.
%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
init_dbase()->
    {ok,GitUser}=application:get_env(master,git_user),
    {ok,GitPassWd}=application:get_env(master,git_pw),
    {ok,ClusterConfigDir}=application:get_env(master,cl_dir),
    {ok,ClusterConfigFileName}=application:get_env(master,cl_file),
    {ok,AppSpecsDir}=application:get_env(master,app_specs_dir),
    {ok,ServiceSpecsDir}=application:get_env(master,service_specs_dir),
  
 
    ok=config_lib:load_app_specs(AppSpecsDir,GitUser,GitPassWd),
    ok=config_lib:load_service_specs(ServiceSpecsDir,GitUser,GitPassWd),
    ok=config_lib:load_cluster_config(ClusterConfigDir,ClusterConfigFileName,GitUser,GitPassWd),
    ok.



%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------

