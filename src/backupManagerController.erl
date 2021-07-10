-module(backupManagerController).
-export([init/0,init/1]).
-export([handle_info/2, handle_call/3]).
-record(state,{username,database,window}).

init()->gen_server:start_link({local,backupManagerController},?MODULE,[],[]).

init([])->
    wx:new(),
	process_flag(trap_exit,true),
    {ok,#state{}}.

handle_info({wx,0,_,_,_},State)->
    dets:close(State#state.database),
	init:stop(),
    {noreply,State};
handle_info({wx,7,_,{Dirs,UserData},_},State)->
    Dets = State#state.database,
    Directory=wxTextCtrl:getValue(UserData),
	case backupManagerService:valid_add_dir(Dets,Directory) of
		ok->dets:insert_new(Dets,{Directory});
		Msg->showMsg(Msg)
	end,
	wxTextCtrl:setValue(Dirs,backupManagerService:getStringDirs(Dets)),
    {noreply,State};
handle_info({wx,8,_,{Dirs,UserData},_},State)->
    Dets = State#state.database,
	Directory=wxTextCtrl:getValue(UserData),
	case backupManagerService:valid_delete_dir(Dets,Directory) of
		ok->dets:delete(Dets,Directory);
		Msg->showMsg(Msg)
	end,
	wxTextCtrl:setValue(Dirs,backupManagerService:getStringDirs(Dets)),
    {noreply,State};
handle_info({wx,9,BtnBackup,UserData,_},State)->
    Dets = State#state.database,
	case backupManagerService:scanHardware() of
		no_hardware->showMsg("NESSUN SUPPORTO DI MEMORIZZAZIONE TROVATO");
		HwDir->
			[wxButton:disable(Btn)||Btn<-[BtnBackup]++UserData],
			Workers=backupManagerService:startBackup(Dets,HwDir),
			[receive {'EXIT',_,_}->ok end||_<-Workers],
			showMsg("BACKUP TERMINATO : "++HwDir),
			[wxButton:enable(Btn)||Btn<-[BtnBackup]++UserData]
		end,
	{noreply,State}.

handle_call({onloginok,Name,_,_},_,State)->
    Database = backupManagerService:open_database(Name),
    Window = backupManagerGraphic:getInitialFrame(Database),
    NewState = State#state{username = Name, window = Window, database = Database},
    wxFrame:show(Window),
    {reply,ok,NewState};
handle_call({oncredentialchangeok,Name,NewName,_,_,_},_,State)->
    Database = backupManagerService:open_database(Name),
    backupManagerService:changeDatabaseName(Name,NewName),
    dets:close(Database),
    {reply,ok,State}.

showMsg(Msg)->
	wxMessageDialog:showModal(wxMessageDialog:new(wx:null(),Msg)).