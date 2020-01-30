local C = class("QmdlPopupLayer",BaseLayer)
QmdlPopupLayer = C

C.RESOURCE_FILENAME = "base/QmdlPopupLayer.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="box_img.close_btn",events={{event="click",method="hide"}}},
	helpBtn = {path="box_img.help_btn",events={{event="click",method="onClickHelpBtn"}}},
	--tab btns
	tabListview = {path="box_img.tab_listview"},
	tgxxBtn = {path="box_img.tab_listview.tgxx_btn",events={{event="click",method="onClickTgxxBtn"}}},
	wdtdBtn = {path="box_img.tab_listview.wdtd_btn",events={{event="click",method="onClickWdtdBtn"}}},
	yjlqBtn = {path="box_img.tab_listview.yjlq_btn",events={{event="click",method="onClickYjlqBtn"}}},
	yjmxBtn = {path="box_img.tab_listview.yjmx_btn",events={{event="click",method="onClickYjmxBtn"}}},
	--推广信息
	tgxxPanel = {path="box_img.tgxx_panel"},
	tgxxHeadImg = {path="box_img.tgxx_panel.mine_img.head_img"},
	tgxxFrameImg = {path="box_img.tgxx_panel.mine_img.frame_img"},
	tgxxNameLabel = {path="box_img.tgxx_panel.mine_img.name_box.label"},
	tgxxIdLabel = {path="box_img.tgxx_panel.mine_img.id_box.label"},
	tgxxApplyPanel = {path="box_img.tgxx_panel.apply_panel"},
	tgxxApplyBtn = {path="box_img.tgxx_panel.apply_panel.btn",events={{event="click",method="onClickTgxxApplyBtn"}}},
	tgxxSharePanel = {path="box_img.tgxx_panel.share_panel"},
	tgxxQrcodeImg = {path="box_img.tgxx_panel.share_panel.qrcode_bg.img"},
	tgxxShareBtn = {path="box_img.tgxx_panel.share_panel.share_btn",events={{event="click",method="onClickTgxxShareBtn"}}},
	tgxxSaveBtn = {path="box_img.tgxx_panel.share_panel.save_btn",events={{event="click",method="onClickTgxxSaveBtn"}}},
	--我的团队
	wdtdPanel = {path="box_img.wdtd_panel"},
	wdtdOnlineLabel = {path="box_img.wdtd_panel.online_img.label"},
	wdtdTotalLabel = {path="box_img.wdtd_panel.total_img.label"},
	wdtdItem = {path="box_img.wdtd_panel.list_panel.item"},
	wdtdListview = {path="box_img.wdtd_panel.list_panel.listview"},
	wdtdUpBtn = {path="box_img.wdtd_panel.up_btn",events={{event="click",method="onClickWdtdUpBtn"}}},
	wdtdDownBtn = {path="box_img.wdtd_panel.down_btn",events={{event="click",method="onClickWdtdDownBtn"}}},
	wdtdIndexLabel = {path="box_img.wdtd_panel.index_label"},
	wdtdRefreshBtn = {path="box_img.wdtd_panel.refresh_btn",events={{event="click",method="onClickWdtdRefreshBtn"}}},
	--佣金领取
	yjlqPanel = {path="box_img.yjlq_panel"},
	yjlqBlanceLabel = {path="box_img.yjlq_panel.box_img.blance_label"},
	yjlqRewardLabel = {path="box_img.yjlq_panel.box_img.reward_label"},
	yjlqGetBtn = {path="box_img.yjlq_panel.get_btn",events={{event="click",method="onClickYjlqGetBtn"}}},
	--佣金明细
	yjmxPanel = {path="box_img.yjmx_panel"},
	yjmxItem = {path="box_img.yjmx_panel.list_panel.item"},
	yjmxListview = {path="box_img.yjmx_panel.list_panel.listview"},
	yjmxHeadImg = {path="box_img.yjmx_panel.mine_img.head_img"},
	yjmxFrameImg = {path="box_img.yjmx_panel.mine_img.frame_img"},
	yjmxIncomeLabel = {path="box_img.yjmx_panel.mine_img.income_box.label"},
	yjmxUpBtn = {path="box_img.yjmx_panel.up_btn",events={{event="click",method="onClickYjmxUpBtn"}}},
	yjmxDownBtn = {path="box_img.yjmx_panel.down_btn",events={{event="click",method="onClickYjmxDownBtn"}}},
	yjmxIndexLabel = {path="box_img.yjmx_panel.index_label"},
	yjmxRefreshBtn = {path="box_img.yjmx_panel.refresh_btn",events={{event="click",method="onClickYjmxRefreshBtn"}}},
}

C.wdtdCurrentPage = 0
C.wdtdTotalPage = 0
C.yjmxCurrentPage = 0
C.yjmxTotalPage = 0

function C:onCreate()
	C.super.onCreate(self)
	self.tabListview:setScrollBarEnabled(false)
	self:loadMineInfo()
	--推广信息
	self.tgxxApplyPanel:setVisible(false)
	self.tgxxQrcodeImg:setVisible(false)
	--我的团队
	--不显示在线人数
	self.wdtdOnlineLabel:setString("0")
	self.wdtdOnlineLabel:setVisible(false)
	self.wdtdTotalLabel:setString("0")
	self.wdtdItem:setVisible(false)
	self.wdtdListview:setTopPadding(5)
	self.wdtdListview:setScrollBarEnabled(false)
	self.wdtdListview:removeAllItems()
	self:setBtnEnabled(self.wdtdUpBtn,false)
	self:setBtnEnabled(self.wdtdDownBtn,false)
	self.wdtdIndexLabel:setString("0/0")
	self.wdtdIndexLabel:setVisible(false)
	--佣金领取
	self.yjlqBlanceLabel:setString("0.00")
	self.yjlqRewardLabel:setString("0.00")
	self.yjlqGetBtn:setEnabled(false)
	--佣金明细
	self.yjmxItem:setVisible(false)
	self.yjmxListview:setTopPadding(5)
	self.yjmxListview:setScrollBarEnabled(false)
	self.yjmxListview:removeAllItems()
	self.yjmxIncomeLabel:setString("0.00")
	self:setBtnEnabled(self.yjmxUpBtn,false)
	self:setBtnEnabled(self.yjmxDownBtn,false)
	self.yjmxIndexLabel:setString("0/0")
	self.yjmxIndexLabel:setVisible(false)
	--打开显示推广信息
	self:showTab(1)
	--刷新二维码
	self:refreshQrcodeImg()
end

function C:show()
	C.super.show(self)

	self.onRespGetBrokerageInfoHandler = handler(self,self.responseYjlqInfo)
	eventManager:on("RespGetBrokerageInfo",self.onRespGetBrokerageInfoHandler)

	self.onRespGetBrokerageMoneyHandler = handler(self,self.responseYjlqGet)
	eventManager:on("RespGetBrokerageMoney",self.onRespGetBrokerageMoneyHandler)

	self.onRespGetBrokerageListInfoHandler = handler(self,self.responseYjmxListInfo)
	eventManager:on("RespGetBrokerageListInfo",self.onRespGetBrokerageListInfoHandler)

	self.onRespGetAgentTeamListInfoHandler = handler(self,self.responseWdtdListInfo)
	eventManager:on("RespGetAgentTeamListInfo",self.onRespGetAgentTeamListInfoHandler)

	self.onRefreshQrcodeUrlRespHandler = handler(self,self.refreshQrcodeImg)
	eventManager:on("RefreshQrcodeUrlResp",self.onRefreshQrcodeUrlRespHandler)

	--显示推广信息
	self:showTab(1)
end

function C:onExit()
	C.super.onExit(self)
	eventManager:off("RespGetBrokerageInfo",self.onRespGetBrokerageInfoHandler)
	eventManager:off("RespGetBrokerageMoney",self.onRespGetBrokerageMoneyHandler)
	eventManager:off("RespGetBrokerageListInfo",self.onRespGetBrokerageListInfoHandler)
	eventManager:off("RespGetAgentTeamListInfo",self.onRespGetAgentTeamListInfoHandler)
	eventManager:off("RefreshQrcodeUrlResp",self.onRefreshQrcodeUrlRespHandler)
end

function C:showTab( index )
	self.tgxxPanel:setVisible(index==1)
	self.tgxxBtn:setEnabled(index~=1)
	self.wdtdPanel:setVisible(index==2)
	self.wdtdBtn:setEnabled(index~=2)
	self.yjlqPanel:setVisible(index==3)
	self.yjlqBtn:setEnabled(index~=3)
	self.yjmxPanel:setVisible(index==4)
	self.yjmxBtn:setEnabled(index~=4)
end

function C:loadMineInfo()
	local name = dataManager.userInfo.nickname
	if name == nil or name == "" then
		name = tostring(dataManager.playerId)
	end
	local id = tostring(dataManager.playerId)
	local headId = dataManager.userInfo.headid
	local headUrl = dataManager.userInfo.wxheadurl
	SET_HEAD_IMG(self.tgxxHeadImg,headId,headUrl)
	SET_HEAD_IMG(self.yjmxHeadImg,headId,headUrl)
	self.tgxxNameLabel:setString(name)
	self.tgxxIdLabel:setString(id)
end

function C:onClickHelpBtn( event )
	QmdlHelpLayer.new():show()
end

function C:onClickTgxxBtn( event )
	self:showTab(1)
end

function C:onClickWdtdBtn( event )
	self:showTab(2)
	if self.wdtdCurrentPage == 0 then
		self:requestWdtdListInfo(1)
	end
end

function C:onClickYjlqBtn( event )
	self:showTab(3)
	self:requestYjlqInfo()
end

function C:onClickYjmxBtn( event )
	self:showTab(4)
	if self.yjmxCurrentPage == 0 then
		self:requestYjmxListInfo(1)
	end
end

function C:setBtnEnabled( btn,enabled )
	btn:setEnabled(enabled)
	btn:setVisible(enabled)
	-- if enabled then
	-- 	btn:setOpacity(255)
	-- else
	-- 	btn:setOpacity(102)
	-- end
end

--1:推广信息
function C:refreshQrcodeImg()
	local filename = dataManager:createQrcodeImg(dataManager.qrcodeUrl)
    if filename then
        self.tgxxQrcodeImg:loadTexture(filename)
        self.tgxxQrcodeImg:setVisible(true)
    end
end

function C:onClickTgxxApplyBtn( event )
	-- body
end

function C:onClickTgxxShareBtn( event )
	self:handleShareOrSaveQrcodeImg(1)
end

function C:onClickTgxxSaveBtn( event )
	self:handleShareOrSaveQrcodeImg(2)
end

--type: 1=分享 2=保存
function C:handleShareOrSaveQrcodeImg( ctype )
	if self.tgxxQrcodeImg:isVisible() == false then
		return
	end
	local isSupported = SUPPORT_WECHAT()
	local doAction = handler(self,self.shareQrcodeImg)
	if ctype == 2 then
		isSupported = SUPPORT_CAMERA()
		doAction = handler(self,self.saveQrcodeImg)
	end
	if isSupported then
		local text = tostring(dataManager.qrcodeUrl)
		local filename,filepath = dataManager:getShareQrcodeImgInfo(dataManager.qrcodeUrl)
		if cc.FileUtils:getInstance():isFileExist(filename) then
			--分享二维码存在直接处理
			doAction(filepath)
		else
			--请求服务器合成分享二维码图片路径
			loadingLayer:show("请稍后...",120)
			self:requestShareQrcodeImgPath(dataManager.qrcodeUrl,function(imageUrl)
				if imageUrl then
					--请求分享二维码成功，下载分享二维码图片
					self:downloadShareQrcodeImg(imageUrl,filename,function( absolutePath )
						--下载图片返回隐藏loading
						loadingLayer:hide()
						if absolutePath then
							--下载分享二维码成功
							doAction(absolutePath)
						else
							--下载失败，使用纯二维码图片
							local _,storagePath = dataManager:createQrcodeImg(dataManager.qrcodeUrl)
						    if storagePath then
						        doAction(storagePath)
						    end
						end
					end)
				else
					--请求分享二维码路径失败，隐藏loading 使用纯二维码图片 
					loadingLayer:hide()
					local _,storagePath = dataManager:createQrcodeImg(dataManager.qrcodeUrl)
				    if storagePath then
				        doAction(storagePath)
				    end
				end
			end)
		end
	else
		--不支持直接保存或者分享，
		local doAction = function( imageUrl )
			local text = "点击‘确定’按钮，使用浏览器打开您的二维码图片，长按图片弹出提示后选择‘存储图像’，打开系统相册即可查看您的二维码"
			DialogLayer.new():show(text,function(isOk)
				if isOk then
					utils:openUrl(imageUrl)
				end
			end)
		end
		if dataManager.shareQrcodeImgPath then
			--分享二维码图片地址存在直接调整
			doAction(dataManager.shareQrcodeImgPath)
		else
			--请求服务器合成分享二维码地址
			loadingLayer:show("请稍后...",120)
			self:requestShareQrcodeImgPath(dataManager.qrcodeUrl,function(imageUrl)
				--隐藏loading
				loadingLayer:hide()
				if imageUrl then
					doAction(imageUrl)
				end
			end)
		end
	end
end

--请求合成图片路径
-- string url = "http://47.107.183.152:15000?";
-- string key = "q1w2e3...abc";
-- string sign = GetMd5("platform=" + platform + "&url=" + qrcodeUrl + "&key=" + key);
-- string requestUrl = url + "platform=" + platform + "&url=" + qrcodeUrl + "&sign=" + sign;
-- {
--   "code":0,
--   "msg":"http://flyfox.oss-ap-southeast-1.aliyuncs.com/pic/209ed6fa4c7332fbd4646117c326c2f8.png"
-- }
function C:requestShareQrcodeImgPath(qrcodeUrl,callback)
	if qrcodeUrl == nil or qrcodeUrl == "" then
		if callback then
			callback(nil)
		end
		return
	end
	local sign = Md5.sumhexa("platform="..dataManager.styleId.."&url="..qrcodeUrl.."&key=q1w2e3...abc")
	qrcodeUrl = string.urlencode(qrcodeUrl)
	local domain = tostring(dataManager.shareQrcodeDomain)
    local len = string.len(domain)
    local index = string.find(domain,"?",len-1,len)
    if index == nil then
        domain = domain.."?"
    end
	local url = domain.."platform="..tostring(dataManager.styleId).."&url="..qrcodeUrl.."&sign="..tostring(sign)
	utils:httpGet(url,function( response )
		local path = nil
		if response and type(response) == "string" then
			local tb = json.decode(response)
			if tb and tonumber(tb.code) == 0 and tb.msg ~= nil and tb.msg ~= "" then
				path = tb.msg
				dataManager.shareQrcodeImgPath = path
			end
		end
		if callback then
			callback(path)
		end
	end)
end

--下载二维码图片
function C:downloadShareQrcodeImg(url,fileName,callback)
	imageUtils:downloadImage(url,fileName,function( fileName,absolutePath )
		if callback then
			callback(absolutePath)
		end
	end)
end

--分享二维码
function C:shareQrcodeImg( filePath )
	local info = {}
	info.title = "江湖娱乐"
	info.description = "精彩刺激好玩的游戏尽在江湖娱乐"
	info.imagePath = filePath
	--分享：0=聊天场景 1=朋友圈
	utils:shareToWechat(2,0,info)
end

--保存二维码
function C:saveQrcodeImg( filePath )
	utils:saveImage(filePath,function( success )
		if success == true or tonumber(success) == 1 then
			toastLayer:show("保存成功")
		else
			toastLayer:show("保存失败，请检查相册权限是否开启",3)
		end
	end)
end

--2:我的团队
function C:onClickWdtdUpBtn( event )
	local page = self.wdtdCurrentPage-1
	if page < 1 then
		page = 1
	end
	self:requestWdtdListInfo(page)
end

function C:onClickWdtdDownBtn( event )
	local page = self.wdtdCurrentPage+1
	if page < 1 then
		page = 1
	end
	self:requestWdtdListInfo(page)
end

function C:onClickWdtdRefreshBtn( event )
	self:requestWdtdListInfo(1)
end

function C:requestWdtdListInfo( page )
	eventManager:publish("ReqGetAgentTeamListInfo",page)
end

function C:responseWdtdListInfo( info )
	dump(info,"responseWdtdListInfo")
	if info then
		local totalcount = info.totalcount or 0
		self.wdtdTotalPage = info.pagecount or 0
		self.wdtdCurrentPage = info.pageno or 0
		if self.wdtdTotalPage == 0 then
			self.wdtdCurrentPage = 0
		end
		local record = info.record or {}
		self.wdtdTotalLabel:setString(tostring(totalcount))
		self.wdtdIndexLabel:setString(string.format("%d/%d",self.wdtdCurrentPage,self.wdtdTotalPage))
		self.wdtdIndexLabel:setVisible(self.wdtdTotalPage>1)
		self:setBtnEnabled(self.wdtdUpBtn,self.wdtdCurrentPage>1)
		self:setBtnEnabled(self.wdtdDownBtn,self.wdtdCurrentPage<self.wdtdTotalPage)
		self.wdtdListview:removeAllItems()
		for i,v in ipairs(record) do
			local item = self:createWdtdItem(v)
			self.wdtdListview:pushBackCustomItem(item)
		end
	end
end

function C:createWdtdItem( info )
	local item = self.wdtdItem:clone()
	local id = info.id or ""
	local recharge = info.ChargeAmount or 0
	local exchange = info.ExAmount or 0
	local time = info.regtime or ""
	item:getChildByName("id_label"):setString(tostring(id))
	item:getChildByName("recharge_label"):setString(utils:moneyString(recharge))
	item:getChildByName("exchange_label"):setString(utils:moneyString(exchange))
	item:getChildByName("time_label"):setString(tostring(time))
	item:setVisible(true)
	return item
end

--3:佣金领取
function C:requestYjlqInfo()
	eventManager:publish("ReqGetBrokerageInfo")
end

function C:responseYjlqInfo( info )
	dump(info,"responseYjlqInfo")
	if info.code == 0 then
		local blance = info.leftmoney or 0
		local money = info.cangetmoney or 0
		self.yjlqBlanceLabel:setString(utils:moneyString(blance,2))
		self.yjlqRewardLabel:setString(utils:moneyString(money,2))
		self.yjlqGetBtn:setEnabled(money>0)
	end
end

function C:onClickYjlqGetBtn( event )
	self:requestYjlqGet()
end

function C:requestYjlqGet()
	eventManager:publish("ReqGetBrokerageMoney")
end

function C:responseYjlqGet( info )
	dump(info,"responseYjlqGet")
	if info.code == 0 then
		local blance = info.leftmoney or 0
		local money = info.cangetmoney or 0
		self.yjlqBlanceLabel:setString(utils:moneyString(blance,2))
		self.yjlqRewardLabel:setString(utils:moneyString(money,2))
		self.yjlqGetBtn:setEnabled(money>0)
		--飘金币动画
        local currentScene = display.getRunningScene()
        if currentScene then
        	local particle = cc.ParticleSystemQuad:create("base/animation/particle/gold.plist")
	        particle:setAutoRemoveOnFinish(true)
	        particle:setPosition(display.cx,display.cy-100)
            currentScene:addChild(particle)
        end
        toastLayer:show("领取成功，请查看您的账号余额")
    else
    	toastLayer:show("领取失败")
	end
end

--4:佣金明细
function C:onClickYjmxUpBtn( event )
	local page = self.yjmxCurrentPage-1
	if page < 1 then
		page = 1
	end
	self:requestYjmxListInfo(page)
end

function C:onClickYjmxDownBtn( event )
	local page = self.yjmxCurrentPage+1
	if page < 1 then
		page = 1
	end
	self:requestYjmxListInfo(page)
end

function C:onClickYjmxRefreshBtn( event )
	self:requestYjmxListInfo(1)
end

function C:requestYjmxListInfo( page )
	eventManager:publish("ReqGetBrokerageListInfo",page)
end

function C:responseYjmxListInfo( info )
	dump(info,"responseYjmxListInfo")
	if info then
		local income = info.alltax or 0
		self.yjmxTotalPage = info.pagecount or 0
		self.yjmxCurrentPage = info.pageno or 0
		if self.yjmxTotalPage == 0 then
			self.yjmxCurrentPage = 0
		end
		local record = info.record or {}
		self.yjmxIncomeLabel:setString(utils:moneyString(income,2))
		self.yjmxIndexLabel:setString(string.format("%d/%d",self.yjmxCurrentPage,self.yjmxTotalPage))
		self.yjmxIndexLabel:setVisible(self.yjmxTotalPage>1)
		self:setBtnEnabled(self.yjmxUpBtn,self.yjmxCurrentPage>1)
		self:setBtnEnabled(self.yjmxDownBtn,self.yjmxCurrentPage<self.yjmxTotalPage)
		self.yjmxListview:removeAllItems()
		for i,v in ipairs(record) do
			local item = self:createYjmxItem(v)
			self.yjmxListview:pushBackCustomItem(item)
		end
	end
end

function C:createYjmxItem( info )
	local item = self.yjmxItem:clone()
	local time = info.statdate or ""
	local recharge = info.totalrecharge or 0
	local shuishou = info.tax or 0
	local percent = info.per or ""
	local reward = info.cangetmoney or 0
	item:getChildByName("time_label"):setString(tostring(time))
	item:getChildByName("recharge_label"):setString(utils:moneyString(recharge))
	item:getChildByName("shuishou_label"):setString(utils:moneyString(shuishou))
	item:getChildByName("percent_label"):setString(tostring(percent).."%")
	item:getChildByName("reward_label"):setString(utils:moneyString(reward))
	item:setVisible(true)
	return item
end

return QmdlPopupLayer