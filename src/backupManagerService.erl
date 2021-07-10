-module(backupManagerService).
-export([valid_add_dir/2,valid_delete_dir/2,scanHardware/0,startBackup/2,backup/2,getStringDirs/1,changeDatabaseName/2,open_database/1]).
-define(HWDIR,"/media/luca/").
-define(PATHDIRECTORIES,"./priv/DirectoriesBackup/").
-define(DIRECTORYSUFFIX,"Dirs").

open_database(Username)->
    DatabaseFileName = ?PATHDIRECTORIES++Username++?DIRECTORYSUFFIX,
    {ok,Dets}=dets:open_file(pwd,[{file,DatabaseFileName},{type,set}]),
    Dets.

changeDatabaseName(Name,NewName)->
	DatabaseFileName = ?PATHDIRECTORIES++Name++?DIRECTORYSUFFIX,
	NewDatabaseFileName = ?PATHDIRECTORIES++NewName++?DIRECTORYSUFFIX,
	file:rename(DatabaseFileName,NewDatabaseFileName).

valid_delete_dir(Dets,Directory)->
	case dets:member(Dets,Directory) of
		true->ok;
		false->"DIRECTORY/FILE NON PRESENTE,NESSUNA CANCELLAZIONE"
	end.

valid_add_dir(Dets,Directory)->
	Dirs=getDirs(Dets),
	case filelib:is_file(Directory) of
		true->case dets:member(Dets,Directory) of
				true->"DIRECTORY/FILE PRESENTE,NESSUN SALVATAGGIO";
				false->case check_sup_dirs(Directory,Dirs) of
						ok-> case check_inf_dirs(Directory,Dirs) of
							 ok-> ok;
							 Inf-> "DIRECTORY INFERIORE PRESENTE: "++Inf
							end;
						Sup->"DIRECTORY SUPERIORE PRESENTE: "++Sup
					end
			end;
		false->"DIRECTORY/FILE NON VALIDO,NESSUN SALVATAGGIO"
	end.

check_inf_dirs(Directory,Directories)->
	case [Dir||Dir<-Directories,lists:prefix(Directory,Dir)] of
		[]->ok;
		L->hd(L)
	end.

check_sup_dirs(Directory,Directories)->
	case [Dir||Dir<-Directories,lists:prefix(Dir,Directory)] of
		[]->ok;
		L->hd(L)
	end.

scanHardware()->
	{ok,Hardwares}=file:list_dir(?HWDIR),
	case erlang:length(Hardwares) of
		0->
			no_hardware;
		_->
			?HWDIR++erlang:hd(Hardwares)
	end.

startBackup(Dets,HwDir)->
	FolderName=createName(),
	DirRoot=HwDir++"/"++FolderName,
	file:make_dir(DirRoot),
	A=fun({Dir},List)->[Dir|List] end,
	Directories=dets:foldl(A,[],Dets),
    [spawn_link(?MODULE,backup,[Source,DirRoot])||Source<-Directories].

backup(Src,Dst)->
	case filelib:is_file(Src) of
		true->
			ParentDir=filename:dirname(Src),
			File=filename:basename(Src),
			Root=Dst++"/"++File,
			file:make_dir(Root),
			file:write_file(Root++"/metadata.meta",ParentDir),
			copy(Src,Root);
		false->ok
	end,
	io:fwrite("FINE: ~p~n",[Src]).

copy(Src,Dst)->
	case filelib:is_dir(Src) of
		true->
			NewDst=Dst++"/"++filename:basename(Src),
			file:make_dir(NewDst),
			{ok,Files}=file:list_dir(Src),
			[copy(Src++"/"++File,NewDst)||File<-Files];
		false->file:copy(Src,Dst++"/"++filename:basename(Src))
	end.

getDirs(Dets)->
	A=fun({Dir},Acc)->[Dir|Acc] end,
	dets:foldl(A,[],Dets).

getStringDirs(Dets)->
	A=fun({Dir},Acc)->Acc++Dir++"\n" end,
	dets:foldl(A,"",Dets).

createName()->
	{Data,Ora}=erlang:localtime(),
	StringData=string:join([integer_to_list(X)||X<-tuple_to_list(Data)],"-"),
	StringTime=string:join([integer_to_list(X)||X<-tuple_to_list(Ora)],"-"),
	string:concat(StringData,string:concat("*",StringTime)).