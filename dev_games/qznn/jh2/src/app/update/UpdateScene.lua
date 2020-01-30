local C = class("UpdateScene",SceneBase)
UpdateScene = C

C.RESOURCE_FILENAME = "update/UpdateScene.csb"
C.RESOURCE_BINDING = {
	progressNode = {path="progress_node"},
	loading = {path="progress_node.loading"},
	updating = {path="progress_node.updating"},
	unziping = {path="progress_node.unziping"},
	loging = {path="progress_node.logining"},
	progressImg = {path="progress_node.progress_img"},
	progressBar = {path="progress_node.progress_img.progress_bar"},
	tipsLabel = {path="tips_label"},
}

function C:initialize()
	--适配宽度代码 1136为设计分辨率宽度
	local offsetX = (display.width-1136)/2
	self.resourceNode:setPositionX(offsetX)
	self.progressNode:setVisible(false)
	self.loading:setVisible(false)
	self.updating:setVisible(false)
	self.unziping:setVisible(false)
	self.loging:setVisible(false)
	self.progressBar:setPercent(0)
	self.tipsLabel:setVisible(false)
	self:startProgressAni()
end

function C:onExitTransitionStart()
	self:hideTips()
	self:stopProgressAni()
	C.super.onExitTransitionStart(self)
end

function C:startProgressAni()
	self:stopProgressAni()
	local array = {}
	array[1] = cc.DelayTime:create(0.02)
	array[2] = cc.CallFunc:create(function()
		local percent = self.progressBar:getPercent() + 1
		if percent > 100 then
			percent = 100
			self.progressBar:setPercent(percent)
			self:stopProgressAni()
		else
			self.progressBar:setPercent(percent)
		end
		
	end)
    local act = cc.RepeatForever:create(cc.Sequence:create(array))
    act:setTag(888)
	self.progressImg:runAction(act)
end

function C:stopProgressAni()
	self.progressImg:stopAllActions()
end

--提示类型 1：加载中  2：更新中  3：解压中  4：登录中
function C:showTips( ctype )
	self.progressNode:setVisible(true)
	self.loading:setVisible(false)
	self.loading:stopAllActions()
	self.updating:setVisible(false)
	self.updating:stopAllActions()
	self.unziping:setVisible(false)
	self.unziping:stopAllActions()
	self.loging:setVisible(false)
	self.loging:stopAllActions()
	self.tipsLabel:setVisible(false)
	if ctype == 1 then
		self:startDotAni(self.loading)
	elseif ctype == 2 then
		self:startDotAni(self.updating)
		self.tipsLabel:setVisible(true)
	elseif ctype == 3 then
		self:startDotAni(self.unziping)
	elseif ctype == 4 then
		self:startDotAni(self.loging)
	end
end

function C:hideTips()
	self:showTips(0)
	self.progressNode:setVisible(false)
end

function C:startDotAni( node )
	node:setVisible(true)
	local dot1 = node:getChildByName("dot_1")
	local dot2 = node:getChildByName("dot_2")
	local dot3 = node:getChildByName("dot_3")
	dot1:setVisible(true)
	dot2:setVisible(true)
	dot3:setVisible(true)
	local array = {}
	array[1] = cc.DelayTime:create(0.5)
    array[2] = cc.CallFunc:create(function()
		dot1:setVisible(false)
		dot2:setVisible(false)
		dot3:setVisible(false)
	end)
    array[3] = cc.DelayTime:create(0.25)
    array[4] = cc.CallFunc:create(function()
		dot1:setVisible(true)
		dot2:setVisible(false)
		dot3:setVisible(false)
	end)
    array[5] = cc.DelayTime:create(0.5)
    array[6] = cc.CallFunc:create(function()
		dot1:setVisible(true)
		dot2:setVisible(true)
		dot3:setVisible(false)
	end)
	array[7] = cc.DelayTime:create(0.5)
    array[8] = cc.CallFunc:create(function()
		dot1:setVisible(true)
		dot2:setVisible(true)
		dot3:setVisible(true)
	end)
    node:runAction(cc.RepeatForever:create(cc.Sequence:create(array)))
end

--设置进度条 0~100
function C:setProgressBar( percent )
	self:stopProgressAni()
	self.progressBar:setPercent(percent)
end

return UpdateScene