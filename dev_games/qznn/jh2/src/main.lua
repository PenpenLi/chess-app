APP_VER = 2
DOWNLOAD_PATH = cc.FileUtils:getInstance():getWritablePath().."download/"
if cc.Application:getInstance():getTargetPlatform() == 0 then
    DOWNLOAD_PATH = "C://Fox/"
end

require "config"
require "cocos.init"
--加载这两个文件只是为了获取CHANNEL_ID和GAME_ALIAS
require "src.app.channel"
require "src.app.define"

local userDefault = cc.UserDefault:getInstance()
local oldAppVer = userDefault:getIntegerForKey("APP_VER",-1)
local oldChannelId = userDefault:getIntegerForKey("CHANNEL_ID",-1)

--判断底包覆盖安装，APP_VER或者CHANNEL_ID不一样，需要清理工程，重新拉更新资源
if APP_VER ~= oldAppVer or CHANNEL_ID ~= oldChannelId then
	--删除download文件夹下资源
	local fileUtil = cc.FileUtils:getInstance()
    if fileUtil:isDirectoryExist(DOWNLOAD_PATH) then
        fileUtil:removeDirectory(DOWNLOAD_PATH)
    end
    --获取到跨平台的UserDefault文件内容，暂时无法准确查找到current-version-codeXXXX，download-version-codeXXXX，
    --通过对更新连接加时间错参数解决由于连接hash指一样导致不更新问题
    --iOS平台UserDefault保存文件地址
  --   local storeFilePath = cc.FileUtils:getInstance():getWritablePath().."Preferences/com.jinyong.game.plist"
  --   storeFilePath = string.gsub(storeFilePath,"Documents","Library")
  --   --加载UserDefault文件内容
  --   if cc.FileUtils:getInstance():isFileExist(storeFilePath) then
	 --    -- local xmlFilePath = cc.UserDefault:getXMLFilePath()
		-- local f = assert(io.open(storeFilePath,'r'))
		-- local content = f:read('*all')
		-- f:close()
  --       print("====content:"..tostring(content))
		-- --注意中划线问题
		-- content = string.gsub(content,"-","_")
		-- --查找并删除current-version-codeXXXX
		-- for item in string.gmatch(content,"<current_version_code%w+") do
		-- 	local key = string.gsub(item,"_","-")
		-- 	key = string.gsub(key,"<","")
		-- 	userDefault:deleteValueForKey(key)
		-- end
		-- --查找删除download-version-codeXXXX
		-- for item in string.gmatch(content,"<downloaded_version_code%w+") do
		-- 	local key = string.gsub(item,"_","-")
		-- 	key = string.gsub(key,"<","")
		-- 	userDefault:deleteValueForKey(key)
		-- end
  --   end
    --删除大厅本地版本
    userDefault:deleteValueForKey("localBaseVersion")
    --删除子游戏本地版本
    if GAME_ALIAS then
    	for k,v in pairs(GAME_ALIAS) do
    		userDefault:deleteValueForKey("game"..tostring(k).."ver")
    	end
    end
    --保存新版本新渠道标识
    userDefault:setIntegerForKey("APP_VER",APP_VER)
    userDefault:setIntegerForKey("CHANNEL_ID",CHANNEL_ID)
    userDefault:flush()
end

local searchPaths = cc.FileUtils:getInstance():getSearchPaths()
table.insert(searchPaths, 1, DOWNLOAD_PATH.."src/")
table.insert(searchPaths, 1, DOWNLOAD_PATH.."res/")
cc.FileUtils:getInstance():setSearchPaths(searchPaths)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")
cc.FileUtils:getInstance():setPopupNotify(false)

local function main()
    require("app.update.UpdateCore"):create():run()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
