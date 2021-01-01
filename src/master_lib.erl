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
    [application:set_env(?MODULE,Par,Val)||
	{Par,Val}<-args_to_term:transform(EnvArgsStr)],
    % Update local dbase for boot
    init_dabase(),
    % start local dbase 
    ok=application:start(master),
    
    % Get app spec for this host master 


    % starart master on this host 


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
init_dabase()->
    {ok,GitUser}=application:get_env(git_user),
    {ok,GitPassWd}=application:get_env(git_pw),
    {ok,ClusterConfigDir}=application:get_env(cl_dir),
    {ok,ClusterConfigFileName}=application:get_env(cl_file),
    {ok,AppSpecsDir}=application:get_env(app_specs_dir),
    {ok,ServiceSpecsDir}=application:get_env(service_specs_dir),
 
    ok=config_lib:load_app_specs(AppSpecsDir,GitUser,GitPassWd),
    ok=config_lib:load_service_specs(ServiceSpecsDir,GitUser,GitPassWd),
    ok=config_lib:load_cluster_config(ClusterConfigDir,ClusterConfigFileName,GitUser,GitPassWd),
    ok.



%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------

