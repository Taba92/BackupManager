-module(backupManager_app).
-behaviour(application).
-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    application:start(loginWindow),
    Listeners = #{onLoginOk => [backupManagerController], onCredentialChange => [backupManagerController]},
    gen_server:call(userLoginController,{set_listeners,Listeners}),
    backupManagerController:init().

stop(_State) ->
    ok.

%% internal functions
