--Author : WB
--Date   : 2018/3/31

local HelpUI = class("HelpUI", cc.Node)


function HelpUI:ctor(nPageNum, path, upPos, downPos, closePos)
    self.BG = ccui.Layout:create()
    self.BG:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    self.BG:setBackGroundColor(cc.c3b(0, 0, 0))
    self.BG:setOpacity(200)
    self.BG:setContentSize(cc.size(1700, 1700))
    self.BG:setPosition(cc.p(-1700 / 2, -1700 / 2))
    self.BG:setTouchEnabled(true)
    self.BG:addClickEventListener(function()
        self.hClose()
    end)
    self:addChild(self.BG)

    self.arrPages = {}
	for i = 1, nPageNum do
        self.arrPages[i] = ccui.ImageView:create(path.."/help_"..i..".png")
        self.arrPages[i]:setVisible(false)
        self.arrPages[i]:setTouchEnabled(true)
        self:addChild(self.arrPages[i])
    end
    self.arrPages[1]:setVisible(true)

    self.btnUP = ccui.Button:create(path.."/help_up.png")
    self.btnDown = ccui.Button:create(path.."/help_down.png")
    if not cc.FileUtils:getInstance():isFileExist(path.."/help_up.png") then self.btnUP = self.btnDown:clone() self.btnUP:setFlippedX(true) end
    if not cc.FileUtils:getInstance():isFileExist(path.."/help_down.png") then self.btnDown = self.btnUP:clone() self.btnDown:setFlippedX(true) end

    self.btClose = ccui.Button:create(path.."/help_close.png")
    self.btnUP:setPosition(upPos)
    self.btnDown:setPosition(downPos)
    self.btnDown:setVisible(nPageNum > 1)
    self.btClose:setPosition(closePos)
    self.btnUP:setEnabled(false)
    self.btnUP:setVisible(nPageNum > 1)
    self.btnUP:addClickEventListener(function ()
        self.arrPages[self.nCurPage]:setVisible(false)
        self.arrPages[self.nCurPage - 1]:setVisible(true)
        self.nCurPage = self.nCurPage - 1
        self.btnDown:setEnabled(true)
        if (self.nCurPage == 1) then
            self.btnUP:setEnabled(false)
        end
    end)
    self.btnDown:addClickEventListener(function ()
        self.arrPages[self.nCurPage]:setVisible(false)
        self.arrPages[self.nCurPage + 1]:setVisible(true)
        self.nCurPage = self.nCurPage + 1
        self.btnUP:setEnabled(true)
        if (self.nCurPage == #self.arrPages) then
            self.btnDown:setEnabled(false)
        end
    end)
    self.hClose = function ()
        self.arrPages[self.nCurPage]:setVisible(false)
        self.arrPages[1]:setVisible(true)
        self.btnUP:setEnabled(false)
        self.btnDown:setEnabled(true)
        self:setVisible(false)
        self.nCurPage = 1
    end
    self.btClose:addClickEventListener(self.hClose)
    self:setPosition(cc.p(1334 / 2, 750 / 2))
    self:addChild(self.btnUP)
    self:addChild(self.btnDown)
    self:addChild(self.btClose)

	self.nCurPage = 1
end

return HelpUI