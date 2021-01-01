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
-export([new/0]).

%% ====================================================================
%% External functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
new()->
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

