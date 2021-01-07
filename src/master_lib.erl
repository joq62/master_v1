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
    %% Start log event handler
    master_log:start([]),

    rpc:multicall(misc_oam:masters(),
		  master_log,log,
		  [["Starting intitilazation of cluster "],
		   node(),?MODULE,?LINE]),
    %% Set master env 
    [application:set_env(master,Par,Val)||
	{Par,Val}<-args_to_term:transform(EnvArgsStr)],
   
   % start local common 
    CommonStartResult=common:start(),
    rpc:multicall(misc_oam:masters(),
		  master_log,log,
		  [["Common start = ",CommonStartResult],
		   node(),?MODULE,?LINE]),
    timer:sleep(1),
     % start dbase
    rpc:multicall(misc_oam:masters(),
		  master_log,log,
		  [["Dbase start = ",dbase:start()],
		   node(),?MODULE,?LINE]),
    timer:sleep(1),
  
 % Update local dbase for boot
    init_dbase(),
  
   
    %% 1. Start ssh 
    ssh:start(),
    
    % 2. Check and update machine status
    StatusMachines=machine:status(all),
    rpc:multicall(misc_oam:masters(),
		  master_log,log,
		  [["StatusMachines = ",StatusMachines],
		   node(),?MODULE,?LINE]),
    timer:sleep(1),
    ok=machine:update_status(StatusMachines),
    

    %% 3. Check namen of MasterVm and start that one
   
    {ok,MasterAppSpec}=application:get_env(master,app_spec),
    rpc:multicall(misc_oam:masters(),
		  master_log,log,
		  [["MasterAppSpec = ",MasterAppSpec],
		   node(),?MODULE,?LINE]),
    timer:sleep(1),
    
    [MasterAppInfo]=db_app_spec:read(MasterAppSpec),
    {AppSpecId,AppVsn,master,Directives,Services}=MasterAppInfo,
    {host,HostId}=lists:keyfind(host,1,Directives),
    {vm_id,VmId}=lists:keyfind(vm_id,1,Directives),
    {vm_dir,VmDir}=lists:keyfind(vm_dir,1,Directives),
    
    MasterNode=list_to_atom(VmId++"@"++HostId),
    {ok,MasterNode}=vm:create(HostId,VmId,VmDir,?Cookie),
    rpc:multicall(misc_oam:masters(),
		  master_log,log,
		  [["Create Vm  = ",MasterNode],
		   node(),?MODULE,?LINE]),
    timer:sleep(1),
    
    %% Start now on Master Node same procedure as in boot
    %% 1. ssh start
    rpc:multicall(misc_oam:masters(),
		  master_log,log,
		  [["Start ssh @ masternode = ",rpc:call(MasterNode,ssh,start,[],2000)],
		   node(),?MODULE,?LINE]),
    timer:sleep(1),

    %%misc_oam:print("Start ssh ~p~n",[rpc:call(MasterNode,ssh,start,[],2000)]),
    
    %% Set application env on MasterNode
    rpc:multicall(misc_oam:masters(),
		  master_log,log,
		  [["Set application env = ",[
					      [rpc:call(MasterNode,application,set_env,[master,Par,Val],2000)||
						  {Par,Val}<-args_to_term:transform(EnvArgsStr)
					      ]
					     ]
		   ],
		   node(),?MODULE,?LINE]),
    timer:sleep(1),
    
    %% 2. Create Services
    io:format("Services ~p~n",[Services]),
    CreateResult=[service:create(ServiceSpecId,VmDir,MasterNode)||ServiceSpecId<-Services],
    rpc:multicall(misc_oam:masters(),
		  master_log,log,
		  [["Start master services = ",CreateResult],
		   node(),?MODULE,?LINE]),
    timer:sleep(1),
    
   %% misc_oam:print("Start master services ~p~n ",[CreateResult]),
    PingResult=rpc:call(MasterNode,master,ping,[],200),
    rpc:multicall(misc_oam:masters(),
		  master_log,log,
		  [["rpc:call(MasterNode,master,ping,[] = ",PingResult],
		   node(),?MODULE,?LINE]),
    timer:sleep(1),
    {pong,_,master}=PingResult,
    %% Init Dbase
    rpc:multicall(misc_oam:masters(),
		  master_log,log,
		  [["rpc:call(MasterNode,master_lib,init_dbase,[] = ",rpc:call(MasterNode,master_lib,init_dbase,[],2*5000)],
		   node(),?MODULE,?LINE]),
    timer:sleep(1),

    %misc_oam:print("InitDbase ~p~n ",[rpc:call(MasterNode,master_lib,init_dbase,[],2*5000)]),
    
    %% Update Sd with 
    MasterSdResult=[{rpc:call(MasterNode,db_sd,create,[ServiceId,
					ServiceVsn,
					AppSpecId,AppVsn,
					HostId,
					VmId,
					VmDir,
					MasterNode],5000),ServiceId,ServiceVsn}||
	{ok,ServiceId,ServiceVsn}<-CreateResult],
    rpc:multicall(misc_oam:masters(),
		  master_log,log,
		  [["MasterSdResult= ",MasterSdResult],
		   node(),?MODULE,?LINE]),
    timer:sleep(1),
    
    %% creat lock
    LockCreate=rpc:call(MasterNode,db_lock,create,[{db_lock,schedule}],2000),
    rpc:multicall(misc_oam:masters(),
		  master_log,log,
		  [["LockCreate = ",LockCreate],
		   node(),?MODULE,?LINE]),
    timer:sleep(1),
    {atomic,ok}=LockCreate,
 % 2. Check and update machine status
    StatusMachines2=rpc:call(MasterNode,machine,status,[all],2*5000),  
    rpc:multicall(misc_oam:masters(),
		  master_log,log,
		  [["StatusMachines2 = ",StatusMachines2],
		   node(),?MODULE,?LINE]),
    timer:sleep(1),
  
    MasterUpdateStatus=rpc:call(MasterNode,machine,update_status,[StatusMachines2],5000),
    rpc:multicall(misc_oam:masters(),
		  master_log,log,
		  [["MasterUpdateStatus = ",MasterUpdateStatus],
		   node(),?MODULE,?LINE]),
    timer:sleep(1),
    ok=MasterUpdateStatus,
    % Terminate and remove boot master 
    application:stop(master),
    {badrpc,_}=rpc:call(node(),master,ping,[],2000),
    % End boot sequence
      rpc:multicall(misc_oam:masters(),
		  master_log,log,
		  [["Boo sequence ended successfully"],
		   node(),?MODULE,?LINE]),
    timer:sleep(1),
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

