-module(backupManagerGraphic).
-export([getInitialFrame/1]).
-include_lib("wx/include/wx.hrl").

getInitialFrame(Dets)->
	Frame=wxFrame:new(wx:null(),0,"BACKUP MANAGER"),
	wxFrame:connect(Frame, close_window, [{skip, true}]),%%quando schiacchio sulla chiusura finestra,fermo tutto il sistema|
	wxStaticText:new(Frame,1,"Directory",[{pos,{20,30}}]),
	Directory=wxTextCtrl:new(Frame,2,[{pos,{150, 30}}]),
	wxTextCtrl:setSize(Directory,210,37),
	CurrentDirs= wxTextCtrl:new(Frame,5,[{style, ?wxTE_MULTILINE bor ?wxTE_READONLY},{pos,{150,90}}]),
	wxTextCtrl:setSize(CurrentDirs,300,450),
	wxTextCtrl:setValue(CurrentDirs,backupManagerService:getStringDirs(Dets)),
	AddDirectory=wxButton:new(Frame,7, [{label, "AGGIUNGI\nDIRECTORY"}, {pos,{20, 60}}]),
	wxButton:connect(AddDirectory, command_button_clicked,[{userData,{CurrentDirs,Directory}}]),
	RmDirectory=wxButton:new(Frame,8, [{label, "RIMUOVI\nDIRECTORY"}, {pos,{20, 150}}]),
	wxButton:connect(RmDirectory, command_button_clicked,[{userData,{CurrentDirs,Directory}}]),
	StartBackup=wxButton:new(Frame,9, [{label, "INIZIA\nBACKUP"}, {pos,{20, 250}}]),
	wxButton:connect(StartBackup, command_button_clicked,[{userData,[AddDirectory,RmDirectory]}]),
	Frame.