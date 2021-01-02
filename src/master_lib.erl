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
    %% ssh 
    ssh:start(),
    %% Set master env 
    [application:set_env(master,Par,Val)||
	{Par,Val}<-args_to_term:transform(EnvArgsStr)],
    % start local dbase 
    ok=application:start(master),

   % Update local dbase for boot
    init_dbase(),

   % Check and update machine status
    StatusMachines=machine:status(all),
    io:format("StatusMachines ~p~n",[StatusMachines]),
    ok=machine:update_status(StatusMachines),
    
    % Start master on this host 

    {ok,AppSpec}=application:get_env(master,app_spec),
    {ok,AppSpec,HostId,VmId,Vm,_}=control:create_application(AppSpec),
   
  %  AllInfo=db_sd:read_all_info(),
  %  io:format("AllInfo ~p~n",[AllInfo]),
    [{ServiceId,ServiceVsn,AppSpec,AppVsn,HostId,VmId,VmDir,Vm}]=db_sd:app_spec(AppSpec),
    

    % Initiate ssh and dbase on the new master node
    rpc:call(Vm,ssh,start,[]),
    [rpc:call(Vm,application,set_env,[master,Par,Val],2000)||
	{Par,Val}<-args_to_term:transform(EnvArgsStr)],
    ok=rpc:call(Vm,master_lib,init_dbase,[],2*5000),

   

    % Update sd
    
    {atomic,ok}=rpc:call(Vm,db_sd,create,[ServiceId,ServiceVsn,AppSpec,AppVsn,HostId,VmId,VmDir,Vm],5000),
    [{ServiceId,ServiceVsn,AppSpec,AppVsn,HostId,VmId,VmDir,Vm}]=rpc:call(Vm,db_sd,app_spec,[AppSpec],5000),
    
    % Terminate and remove boot master 
    application:stop(master),
    {badrpc,_}=rpc:call(node(),master,ping,[],2000),
    % End boot sequence
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

