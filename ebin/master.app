%% This is the application resource file (.app file) for the 'base'
%% application.
{application, master,
[{description, "master  " },
{vsn, "1.0.0" },
{modules, 
	  [master_app,master_sup,master,
	   control,dbase,common]},
{registered,[master,control,dbase,common]},
{applications, [kernel,stdlib]},
{mod, {master_app,[]}},
{start_phases, []}
]}.
