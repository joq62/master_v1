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
-export([boot/1]).

%% ====================================================================
%% External functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
boot(EnvArgsStr)->
    %% Set master env 
    [application:set_env(master,Par,Val)||
	{Par,Val}<-args_to_term:transform(EnvArgsStr)],
    % start local dbase 
    ok=application:start(master),
    
   % Update local dbase for boot
    init_dbase(),
    % Start master on this host 

    {ok,AppSpec}=application:get_env(master,app_spec),
    {ok,_,_,_,_}=control:create_application(AppSpec),

    % Terminate and remove boot master 

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

