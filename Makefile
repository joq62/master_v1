all:
	rm -rf ebin/* src/*.beam *.beam;
	rm -rf  *~ */*~  erl_cra*;
	rm -rf *_specs *_config;
#	Dependencies
#	Common service
	erlc -o ebin ../../services/common_src/src/*.erl;
#	Dbase service
	erlc -o ebin ../../services/dbase_src/src/*.erl;
#	Control service
	erlc -o ebin ../../services/control_src/src/*.erl;
#	master application
	cp src/*.app ebin;
	erlc -o ebin src/*.erl;
	echo Done
doc_gen:
	echo glurk not implemented
test:
	rm -rf ebin/* src/*.beam *.beam;
	rm -rf  *~ */*~  erl_cra*;
	rm -rf *_specs *_config;
#	Common service
	erlc -o ebin ../../services/common_src/src/*.erl;
#	Dbase service
	erlc -o ebin ../../services/dbase_src/src/*.erl;
#	Control service
	erlc -o ebin ../../services/control_src/src/*.erl;
#	master application
	cp src/*.app ebin;
	erlc -o ebin src/*.erl;
	erl -pa ebin\
	    -run master boot\
	     { git_user str joq62 } { git_pw str 20Qazxsw20 } { cl_dir str cluster_config }\
	     { cl_file str cluster_info.hrl } { app_specs_dir str app_specs }\
	     { service_specs_dir str service_specs } { int_test int 42 }\
	    -sname master -setcookie app_test -detached;
	sleep 1;
	erl -pa ebin -s master_tests start -sname master_test -setcookie app_test
stop:
	erl_call -a 'init stop []' -sname master -c app_test
boot:
	rm -rf ebin/* src/*.beam *.beam;
	rm -rf  *~ */*~  erl_cra*;
	rm -rf *_specs *_config;
	erl -pa master/ebin\
	    -run master boot\
	     { git_user str joq62 } { git_pw str 20Qazxsw20 } { cl_dir str cluster_config }\
	     { cl_file str cluster_info.hrl } { app_specs_dir str app_specs }\
	     { service_specs_dir str service_specs }\
	    -sname master -setcookie app_test -detached;
