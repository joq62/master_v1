%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Create1d : 10 dec 2012
%%% -------------------------------------------------------------------
-module(log_files). 
     
%% --------------------------------------------------------------------
%% Include files
-include_lib("kernel/include/file.hrl").
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Definitions

%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
-export([size_all/1,
	write_log_file/2,
	 unconsult/2,
	format/5]).



%% ====================================================================
%% External functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
write_log_file(File,{Severity,Msg,Node,Module,Line})->
    unconsult(File,format(Severity,Msg,Node,Module,Line)).

format(Severity,Msg,Node,Module,Line)->
    [{{timestamp,{date(),time()}},
      {severity,Severity},
      {message,Msg},
      {node,Node},{module,Module},{line,Line}}].

unconsult(File,L)->
    {ok,S}=file:open(File,[append]),
    lists:foreach(fun(X)->
			  io:format(S,"~p.~n",[X]) end,L),
    file:close(S).


%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
size_all(Dir)->
    {ok,BaseNames}=file:list_dir(Dir),
    FileNamesLogFiles=[filename:join(Dir,BaseFileName)||BaseFileName<-BaseNames,
							".log"==filename:extension(BaseFileName)],
    Facts=get_info(FileNamesLogFiles,[]),  
    TotalBytes=lists:sum([Size||{_,Size,_}<-Facts]),
    SortedOldestFirst=qsort(Facts),
    {TotalBytes,SortedOldestFirst}.


qsort([{FileNameLogFile,Size,Mtime}|T]) ->
    qsort([{XFileNameLogFile,XSize,XMtime} || {XFileNameLogFile,XSize,XMtime} <- T, XMtime < Mtime]) ++
    [{FileNameLogFile,Size,Mtime}] ++
    qsort([ {XFileNameLogFile,XSize,XMtime} || {XFileNameLogFile,XSize,XMtime} <- T, XMtime >= Mtime]);
qsort([]) -> [].

get_info([],FileInfo)->
    FileInfo;
get_info([FileNameLogFile|T],Acc)->
    {ok,Facts}=file:read_file_info(FileNameLogFile),
    get_info(T,[{FileNameLogFile,Facts#file_info.size,Facts#file_info.mtime}|Acc]).
