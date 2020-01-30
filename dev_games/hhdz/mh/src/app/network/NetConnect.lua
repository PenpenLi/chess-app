
local MAX_RECONNECT_COUNT = 5;

-----------------------------------------------------------------------------------
local hallServerIndex = 1;
local hallServerIp;
local hallServerPort;
local hallServerConnectCallback = nil;
local reconnectHallServerCount = 0;
local lastHallServerId = 0
local autoReconnectHallServer = false
local isHallConnecting = false --判断是否正在连接大厅，防止短时内同时连两次造成崩溃，比如微信登录回来，后台切换到前台出发连接大厅/微信登录回来连接大厅

HallServerConnected = false;

--连接大厅服务器
function ConnectHallServer(callback)
    autoReconnectHallServer = true
    hallServerConnectCallback = callback;
    local server = dataManager.hallServers[tostring(hallServerIndex)];
    hallServerIndex = lastHallServerId > 0 and lastHallServerId or 1;
    hallServerIp = server.ip;
    hallServerPort = tonumber(server.port);
    reconnectHallServerCount = 1;
    --正在连接直接返回
    if isHallConnecting then
        return
    end
    isHallConnecting = true
    Connect(hallServerIp,hallServerPort);
end

function CloseHallServer()
    autoReconnectHallServer = false
    HallServerConnected = false;
    isHallConnecting = false
    _Close()
end

function ReconnetHallServer()
    if HallServerConnected then
        return
    end
    HallServerConnected = false;
    autoReconnectHallServer = true;
    --正在连接直接返回
    if isHallConnecting then
        return
    end
    isHallConnecting = true
    Connect(hallServerIp,hallServerPort);
end

--发送数据到大厅服务器
function SendHallServer(mainProto,subProto,s)
	if s == nil then
		s = {mainProto,subProto}
	end
    printInfo("发送大厅协议：["..tostring(mainProto).."]["..tostring(subProto).."]")
	_Send(mainProto,subProto,s)
end

--连接大厅服务器成功
function OnClientConnect()
    isHallConnecting = false
    --连接成功设置重连次数为0
    reconnectHallServerCount = 0
    HallServerConnected = true;
    lastHallServerId = hallServerIndex;
    if hallServerConnectCallback then
        hallServerConnectCallback(true);
    end
end

--连接大厅服务器失败
function OnClientFaild()
    isHallConnecting = false
    HallServerConnected = false;
    printInfo("连接大厅服务器失败:"..tostring(hallServerIp)..":"..tostring(hallServerPort));

    if not autoReconnectHallServer then
        return
    end

    if reconnectHallServerCount > MAX_RECONNECT_COUNT then
        if hallServerConnectCallback then
            hallServerConnectCallback(false);
        end
        reconnectHallServerCount = 0
    else
        if hallServerIndex > #dataManager.hallServers then
            reconnectHallServerCount = reconnectHallServerCount + 1
            hallServerIndex = 0
        end
        hallServerIndex = hallServerIndex + 1
        local server = dataManager.hallServers[tostring(hallServerIndex)];
        hallServerIp = server.ip;
        hallServerPort = tonumber(server.port);
        ReconnetHallServer();
    end
end

--大厅服务器连接关闭
function OnClientClose()
    isHallConnecting = false
    HallServerConnected = false;
    print("与大厅服务器断开连接")
    if not autoReconnectHallServer then
        return
    end
    ReconnetHallServer();
end

function GetCurrentHallServerIp()
    return hallServerIp
end

--设置大厅连接回调
function SetHallServerConnectCallback(callback)
    hallServerConnectCallback = callback
end

--设置是否自动重连游戏服
function SetHallServerAutoReconnect(auto)
    autoReconnectHallServer = auto
end

----------------------------------------------------------------------------------------

local gameServerIp;
local gameServerPort;
local gameServerConnectCallback = nil;
local reconnectGameServerCount = 0;
local autoReconnectGameServer = false
local isGameConnecting = false --判断是否正在连接，防止段时间内发起多次连接导致崩溃

GameServerConnected = false;

--连接游戏服务器
function ConnectGameServer(ip, port,callback)
    autoReconnectGameServer = true
    reconnectGameServerCount = 1;
    gameServerIp = ip;
    gameServerPort = port;
    gameServerConnectCallback = callback;
    --正在连接直接返回
    if isGameConnecting then
        return
    end
    isGameConnecting = true
    Connect1(ip,port);
end


--重连游戏服务器
function ReconnectGameServer()
    if GameServerConnected then
        return
    end
    autoReconnectGameServer = true
    reconnectGameServerCount = reconnectGameServerCount + 1;
    --正在连接直接返回
    if isGameConnecting then
        return
    end
    isGameConnecting = true
    Connect1(gameServerIp,gameServerPort);
end

function CloseGameServer()
    isGameConnecting = false
    autoReconnectGameServer = false
    GameServerConnected = false;
    _Close1()
end

--发送数据到游戏服务器
function SendGameServer(mainProto,subProto,s)
    if not(GameServerConnected) then
        print("游戏服务器未连接")
        return
    end
	if s == nil then
		s = {mainProto,subProto}
	end
    printInfo("发送游戏协议：["..tostring(mainProto).."]["..tostring(subProto).."]")
	_Send1(mainProto,subProto,s)
end

--连接游戏服务器成功
function OnClientConnect1()
    isGameConnecting = false
    --连接成功设置重连次数为0
    reconnectGameServerCount = 0
    GameServerConnected = true;
    if gameServerConnectCallback then
        gameServerConnectCallback(true);
    end
end

--连接游戏服务器失败
function OnClientFaild1()
    isGameConnecting = false
    GameServerConnected = false;

    if not autoReconnectGameServer then 
        return
    end

    printInfo("连接游戏服务器失败");
    if reconnectGameServerCount > MAX_RECONNECT_COUNT then
        if gameServerConnectCallback then
            gameServerConnectCallback(false);
        end
        reconnectGameServerCount = 0
    else
        ReconnectGameServer();
    end
end

--游戏服务器连接关闭
function OnClientClose1()
    isGameConnecting = false
    GameServerConnected = false;
    print("与游戏服务器断开连接")
    if not autoReconnectGameServer then 
        return
    end
    ReconnectGameServer();
end

--设置游戏连接回调
function SetGameServerConnectCallback(callback)
    gameServerConnectCallback = callback
end

--设置是否自动重连游戏服
function SetGameServerAutoReconnect(auto)
    autoReconnectGameServer = auto
end

---------------------------------------------------------------------------------------------

local protoCallbacks = {}
local scheduler = cc.Director:getInstance():getScheduler()

--注册网络消息
function Register(mainProto,subProto,callback)
    if nil == protoCallbacks[mainProto] then
		protoCallbacks[mainProto]={}
	end
	protoCallbacks[mainProto][subProto]=callback
end

--反注册网络消息
function UnRegister(mainProto,subProto)
    Register(mainProto,subProto,nil)
end

function OnRecv(mainProto,subProto,connectId,s)
    if mainProto == nil then
        return;
    end
    if subProto == nil then
        return;
    end
    if protoCallbacks[mainProto] == nil or protoCallbacks[mainProto][subProto] == nil then
        printInfo("收到网络消息，没有找到相应回调["..mainProto.."]["..subProto.."]");
        dump(s,"data",10)
		return;
	end
    printInfo("收到网络消息["..mainProto.."]["..subProto.."]");
    protoCallbacks[mainProto][subProto](s);
end

local function heartBeat()
    scheduler:scheduleScriptFunc(
    function()

        if HallServerConnected then
            SendHallServer(MainProto.RegLogin,RegLogin.CS_HEART_CHECK_P,nil);
        end

        if GameServerConnected then
            SendGameServer(MainProto.RegLogin,RegLogin.CS_HEART_CHECK_P,nil);
        end

    end, 3, false)
end

heartBeat()

-----------------------------------------------------------------------------------------

function OnNetworkAvailable(str)
    print("<===============NetworkAvailable===============>")
end

function OnNetworkUnavailable(str)
    print("<==============NetworkUnavailable===============>")
end

-----------------------------------------------------------------------------------------