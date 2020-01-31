local C = class("SwitchLayer",BaseLayer)
SwitchLayer = C

C.RESOURCE_FILENAME = "base/SwitchLayer.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="box_img.close_btn",events={{event="click",method="hide"}}},
	resetBtn = {path="box_img.reset_btn",events={{event="click",method="onClickResetBtn"}}},
	otherBtn = {path="box_img.other_btn",events={{event="click",method="onClickOtherBtn"}}},
	listview = {path="box_img.account_listview"},
	confirmBtn = {path="box_img.confirm_btn",events={{event="click",method="onClickConfirmBtn"}}},
	template = {path="template"},
}

--历史登录账号列表
C.historyAccounts = nil

--是否使用显示隐藏动画
C.USE_ACTION = false
--是否使用模态
C.USE_MODAL = false

function C:onCreate()
	C.super.onCreate(self)
	self.template:setVisible(false)
	self.listview:setScrollBarEnabled(false)
	self.listview:removeAllItems()
	--获取历史登录账号列表
	self.historyAccounts = dataManager:getAccounts()
	for i=1,#self.historyAccounts do
		local text = self.historyAccounts[i]
		self:createItem(text)
	end
	self:refreshItems(0)
end

function C:createItem( text )
	local item = self.template:clone()
	item:setVisible(true)
	local itemBtn = item:getChildByName("item_btn")
	itemBtn:onClick((handler(self,self["onClickItem"])))
	local label = item:getChildByName("item_label")
	label:setString(text)
	local btn = item:getChildByName("delete_btn")
	btn:onClick(handler(self,self["onClickDeleteBtn"]))
	self.listview:pushBackCustomItem(item)
end

function C:refreshItems(selectedIndex)
	if #self.historyAccounts == 0 then
		return
	end
	if selectedIndex then
		self.listview:setCurSelectedIndex(selectedIndex)
	end
	local items = self.listview:getItems()
	for i=1,#items do
		local item = items[i]
		local itemBtn = item:getChildByName("item_btn")
		local itemLabel = item:getChildByName("item_label")
		local deleteBtn = item:getChildByName("delete_btn")
		itemBtn:setTag(i)
		deleteBtn:setTag(i)
		if selectedIndex ~= nil and selectedIndex == i-1 then
			itemBtn:setEnabled(false)
			itemLabel:setTextColor(cc.c4b(80,22,1,255))
		else
			itemBtn:setEnabled(true)
			itemLabel:setTextColor(cc.c4b(38,58,145,255))
		end
	end
end

function C:onClickItem( event )
	local index = event.target:getTag()
	self:refreshItems(index-1)
end

function C:onClickDeleteBtn( event )
	if #self.historyAccounts == 1 then
		toastLayer:show("至少保留一个账号")
		return
	end
	local index = event.target:getTag()
	DialogLayer.new():show("确定要删除记录吗？",function( isOk)
		if isOk then
			local selectedIndex = self.listview:getCurSelectedIndex()
			self.listview:removeItem(index-1)
            dataManager:removeAccount(self.historyAccounts[index])
			table.remove(self.historyAccounts,index)
			if selectedIndex == index-1 then
				self:refreshItems(0)
			else
				self:refreshItems()
			end
		end
	end)
end

--TODO:testStep
local testStep = 1

function C:onClickResetBtn( event )
	ResetLayer.new():show()
	--TODO:测试微信分享
	-- local scene = 0
	-- if testStep == 1 then
	-- 	self:testShareTextToWechat(scene)
	-- elseif testStep == 2 then
	-- 	self:testShareImageToWechat(scene)
	-- elseif testStep == 3 then
	-- 	self:testShareMusicToWechat(scene)
	-- elseif testStep == 4 then
	-- 	self:testShareVideoToWechat(scene)
	-- elseif testStep == 5 then
	-- 	self:testShareWebpageToWechat(scene)
	-- elseif testStep == 6 then
	-- 	self:testShareMiniprogramToWechat(scene)
	-- end
	-- testStep = testStep+1
end

function C:onClickOtherBtn( event )
	LoginLayer.new():show()
	--TODO:测试定位
	-- local callback = function( resultString )
	-- 	printInfo("=====location:"..tostring(resultString))
	-- 	DialogLayer.new():show(tostring(resultString))
	-- end
	-- utils:startLocation(callback)
end

function C:onClickConfirmBtn( event )
	local index = self.listview:getCurSelectedIndex()
	if index == nil then
		toastLayer:show("请选择登录账号")
		return
	end

	local account = self.historyAccounts[index+1]
    if account == "游客" then account = "" end
    local password = dataManager:getPasswordByAccount(account)
    local random = dataManager:getRandomCerByAccount(account)
   	
   	loadingLayer:show("正在登录...")
    eventManager:send("Login",account,password,random)

	--TODO:测试微信登录
	-- local callback = function( code )
	-- 	printInfo("===========wechat login:"..tostring(code))
	-- 	-- DialogLayer.new():show(tostring(code))
	-- end
	-- utils:sendWechatLogin(callback)
	
end

--TODO:test share
function C:testShareTextToWechat( scene )
	utils:shareToWechat(1,scene,{text="草料二维码能实现电话，文本，短信，邮件，名片，wifi的二维码，还通过云技术，实现了文件（如ppt、doc等），图片、视频、音频的二维码生成。"})
end

function C:testShareImageToWechat( scene )
	local info = {}
	info.title = "标题"
	info.description = "描述"
	info.imagePath = self:testImagePath()
	utils:shareToWechat(2,scene,info)
end

function C:testShareMusicToWechat( scene )
	local info = {}
	info.title = "一无所有"
	info.description = "崔健"
	info.imagePath = self:testImagePath()
	info.musicUrl = "http://y.qq.com/i/song.html#p=7B22736F6E675F4E616D65223A22E4B880E697A0E68980E69C89222C22736F6E675F5761704C69766555524C223A22687474703A2F2F74736D7573696334382E74632E71712E636F6D2F586B30305156342F4141414130414141414E5430577532394D7A59344D7A63774D4C6735586A4C517747335A50676F47443864704151526643473444442F4E653765776B617A733D2F31303130333334372E6D34613F7569643D3233343734363930373526616D703B63743D3026616D703B636869643D30222C22736F6E675F5769666955524C223A22687474703A2F2F73747265616D31342E71716D757369632E71712E636F6D2F33303130333334372E6D7033222C226E657454797065223A2277696669222C22736F6E675F416C62756D223A22E4B880E697A0E68980E69C89222C22736F6E675F4944223A3130333334372C22736F6E675F54797065223A312C22736F6E675F53696E676572223A22E5B494E581A5222C22736F6E675F576170446F776E4C6F616455524C223A22687474703A2F2F74736D757369633132382E74632E71712E636F6D2F586C464E4D313574414141416A41414141477A4C36445039536A457A525467304E7A38774E446E752B6473483833344843756B5041576B6D48316C4A434E626F4D34394E4E7A754450444A647A7A45304F513D3D2F33303130333334372E6D70333F7569643D3233343734363930373526616D703B63743D3026616D703B636869643D3026616D703B73747265616D5F706F733D35227D"
	info.musicDataUrl = "http://stream20.qqmusic.qq.com/32464723.mp3"
	utils:shareToWechat(3,scene,info)
end

function C:testShareVideoToWechat( scene )
	local info = {}
	info.title = "乔布斯访谈"
	info.description = "饿着肚皮，傻逼着。"
	info.imagePath = self:testImagePath()
	info.videoUrl = "http://v.youku.com/v_show/id_XNTUxNDY1NDY4.html"
	utils:shareToWechat(4,scene,info)
end

function C:testShareWebpageToWechat( scene )
	local info = {}
	info.title = "专访张小龙：产品之上的世界观"
	info.description = "微信的平台化发展方向是否真的会让这个原本简洁的产品变得臃肿？在国际化发展方向上，微信面临的问题真的是文化差异壁垒吗？腾讯高级副总裁、微信产品负责人张小龙给出了自己的回复。"
	info.imagePath = self:testImagePath()
	info.webpageUrl = "http://tech.qq.com/zt2012/tmtdecode/252.htm"
	utils:shareToWechat(5,scene,info)
end

function C:testShareMiniprogramToWechat( scene )
	local info = {}
	info.title = "乔布斯访谈"
	info.description = "饿着肚皮，傻逼着。"
	info.imagePath = self:testImagePath()
	info.webpageUrl = "http://tech.qq.com/zt2012/tmtdecode/252.htm"
	info.userName = "小程序"
	info.path = "path"
	info.withShareTicket = true
	info.miniProgramType = 0
	utils:shareToWechat(6,scene,info)
end

function C:testImagePath()
	local text = "https://www.baidu.com?t="..tostring(os.time())
	local storagePath = ""
	local fileName = Md5.sumhexa(tostring(text))..".png"
    if cc.FileUtils:getInstance():isFileExist(fileName) == false then
        storagePath = DOWNLOAD_PATH..fileName
        local result = utils:createQRCode(text,256,storagePath)
        if result then
            printInfo("=================testImagePath:success")
        end
    end
    return storagePath
end

return SwitchLayer





























