local C = class("ZjhOperationClass",ViewBaseClass)

C.BINDING = {
	genzhuBtn = {path="genzhu_btn"},
	kanpaiBtn = {path="kanpai_btn"},
	bipaiBtn = {path="bipai_btn"},
	quanyaBtn = {path="quanya_btn"},
	gzyzBtn = {path="guzhuyizhi_btn"},
	jiazhu1Btn = {path="jiazhu1_btn"},
	jiazhu2Btn = {path="jiazhu2_btn"},
	jiazhu3Btn = {path="jiazhu3_btn"},
	alwaysBtn = {path="always_btn"},
	unalwaysBtn = {path="unalways_btn"},
	qipaiBtn = {path="qipai_btn"},
}

C.btnArray = nil
C.btnAutoPos = {cc.p(1126,38),cc.p(913,38)}
C.btnOtherPos = {cc.p(1126,38),cc.p(990,38),cc.p(788,38)}
C.btnPos = {cc.p(1126,38),cc.p(960,38),cc.p(822,38),cc.p(684,38),cc.p(546,38),cc.p(408,38),cc.p(270,38),cc.p(132,38)}

function C:onCreate()
	C.super.onCreate(self)
	self.jiazhu1Btn:setName(ZJH.BTN_NAME.JIAZHU1)
	self.jiazhu2Btn:setName(ZJH.BTN_NAME.JIAZHU2)
	self.jiazhu3Btn:setName(ZJH.BTN_NAME.JIAZHU3)
	self.quanyaBtn:setName(ZJH.BTN_NAME.QUANYA)
	self.gzyzBtn:setName(ZJH.BTN_NAME.GZYZ)
	self.bipaiBtn:setName(ZJH.BTN_NAME.BIPAI)
	self.kanpaiBtn:setName(ZJH.BTN_NAME.KANPAI)
	self.genzhuBtn:setName(ZJH.BTN_NAME.GENZHU)
	self.alwaysBtn:setName(ZJH.BTN_NAME.ALWAYS)
	self.unalwaysBtn:setName(ZJH.BTN_NAME.UNALWAYS)
	self.qipaiBtn:setName(ZJH.BTN_NAME.QIPAI)
	self.btnArray = {}
	table.insert(self.btnArray,self.qipaiBtn)
	table.insert(self.btnArray,self.alwaysBtn)
	table.insert(self.btnArray,self.unalwaysBtn)
	table.insert(self.btnArray,self.gzyzBtn)
	table.insert(self.btnArray,self.genzhuBtn)
	table.insert(self.btnArray,self.kanpaiBtn)
	table.insert(self.btnArray,self.bipaiBtn)
	table.insert(self.btnArray,self.quanyaBtn)
	table.insert(self.btnArray,self.jiazhu3Btn)
	table.insert(self.btnArray,self.jiazhu2Btn)
	table.insert(self.btnArray,self.jiazhu1Btn)
	self:updateBtns({},false,false)
end

function C:updateJiazhu( jiazhu1, jiazhu2, jiazhu3 )
	self.jiazhu1Btn:getChildByName("label"):setString(jiazhu1)
	self.jiazhu2Btn:getChildByName("label"):setString(jiazhu2)
	self.jiazhu3Btn:getChildByName("label"):setString(jiazhu3)
end

function C:updateBtns( config, isAuto, isMyTurn )
	self:setVisible(true)
	local pos = nil
    local startI = 1
    for i = 1, #self.btnArray do
        local btn = self.btnArray[i]
        local name = btn:getName()
        if config[name] then
            btn:setVisible(true)
            if isAuto then
                pos = self.btnAutoPos[startI]
            elseif not isMyTurn then
                pos = self.btnOtherPos[startI]
            else
                pos = self.btnPos[startI]
            end
            startI = startI + 1
            btn:setPosition(pos)
        else
            btn:setVisible(false)
        end
    end
end

return C