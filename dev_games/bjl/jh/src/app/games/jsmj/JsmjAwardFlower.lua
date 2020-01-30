--[[--
     文件名称: JsmjAwardFlower.lua
     功能    : 奖花界面
]]
local C = class("JsmjAwardFlower", cc.Node)
local JsmjDefine = import(".JsmjDefine")
local Tile = import(".JsmjTile")

local scheduler = cc.Director:getInstance():getScheduler()
local MAX_TING_NUM = 9 -- 最多显示6张
--local font = ui.DEFAULT_TTF_FONT
local maxSize = CCSizeMake(0, 0)
local LAYER_MAIN = 200
local SEC_PER_FRAME = 1 / 30

local ZORDER_TILES = 2
local ZORDER_TILES_ANIM = 1
local ZORDER_TILES_ANIM2 = 3

--构造函数
function C:ctor(parent, hasAnim, callback)
    self.parentView_ = parent
    self.dimens_ = parent.dimens_
    self.mahjongData_ = parent.model
    self.hasAnim_ = hasAnim

    self.flowerTiles_ = {}

    self.callback = callback
    -- 字体大小
    self.fanStrFontsHeight_ = self.dimens_:getDimens(24)
    -- 牌的宽度
    self.tileWidth_ = self.dimens_:getDimens(89)
    -- 牌的高度
    self.tileHeight_ = self.dimens_:getDimens(130)
    -- 牌之间的距离
    self.tingBetweenW_ = self.dimens_:getDimens(50)
    self.tingBetweenH_ = self.dimens_:getDimens(10)

    self.imgTiles_ = {} --奖花弹框中的牌
    self.imgTilesBg_ = {} --奖花弹框中的牌
    self.imgTilesMask_ = {} -- mask
    self.lablePromptInfo_ = nil

    self.imgBgWidth_ = 0 --背景框的宽及高
    self.imgBgHeight_ = 0
    self.layerTileX_ = 0 -- tilegroup 的坐标
    self.layerTileY_ = 0
    self.layerMain_ = nil
    self.layerTile_ = nil
    self.layerTitleStatic_ = nil
    self.layerTitleAnim_ = nil
    self.layerFanFont_ = nil
    self.layerOneTile_ = {} --每个牌一个层

    self.turnCount_ = 0 --记录翻牌的数量
    self.hitTileIndex_ = 0 --中奖的牌
    self.hitCardHandler_ = nil -- 重奖的　timer
    self.turnCardHandler_ = nil --翻牌的 timer

    self:initData()
    self:initView()
end

--初始化手牌
function C:initView()
--    local left = self.dimens_.cx
--    local top = self.dimens_:getDimens(315)

    -- 计算控件宽度/高度
    local dataWidth = self:calcRealDataWidth() + 2 * self.tingBetweenW_
    local minWidth = self.dimens_:getDimens(200)
    if dataWidth < minWidth then
        dataWidth = minWidth
    end
    local dataHeight = self:calcRealDataHeight() + 2 * self.tingBetweenH_

    self.imgBgWidth_ = dataWidth
    self.imgBgHeight_ = dataHeight
    self:setContentSize(display.width, display.height)
    self:setPosition(display.width/2, display.height/2)
    self:setAnchorPoint(cc.p(0.5,0.5))

    local dataWidth = self:calcRealDataWidth()
    local dataHeight = self:calcRealDataHeight()
    -- 主层
    local layerMain = ccui.Layout:create()
    layerMain:setContentSize(display.width, display.height)

    local t = cc.CSLoader:createNode("games/jsmj/AwardFlower.csb")
    self:addChild(t)
    self.imgBg_ = t:getChildByName("Panel_close"):getChildByName("box_img") 

--    self.imgBg_ = ccui.ImageView:create(GAME_JSMJ_IMAGES_RES .. "awardflower/awardflower_center_bg.png")
--    self.imgBg_:setPosition(self.imgBgWidth_ / 2, self.imgBgHeight_ / 2 + self.dimens_:getDimens(30))
--    self.imgBg_:setAnchorPoint(cc.p(0.5,0.5))
--    self:addChild(self.imgBg_)
--    self.imgBg_:setScaleX(self.dimens_.wScale_)
--    self.imgBg_:setScaleY(self.dimens_.hScale_)

    self.layerTileX_ = (self.imgBgWidth_ - dataWidth) / 2 -- layerMain 的坐标
    self.layerTileY_ = self.imgBgHeight_ - self.tingBetweenH_

    layerMain:setPosition(display.width/2, display.height/2)
    layerMain:setAnchorPoint(CCPoint(0.5, 0.5))
    layerMain:setTag(LAYER_MAIN)
    self:addChild(layerMain)

   
    self.layerTitleStatic_ = t:getChildByName("Panel_close"):getChildByName("Text_static") --静态奖花图片
    self.layerTitleAnim_ = t:getChildByName("Panel_close"):getChildByName("Text_anim") --光节点
    self.layerFanFont_ = t:getChildByName("Panel_close"):getChildByName("Text_fan") --总番数
    self.lablePromptInfo_ = t:getChildByName("Panel_close"):getChildByName("Text_prompt")

    -- 牌层
    self.layerTile_ = ccui.Layout:create()
    self.layerTile_:setContentSize(display.width, display.height)
    self.layerTile_:setPosition(display.width/2, display.height/2)
    self.layerTile_:setAnchorPoint(cc.p(0.5,0.5))
    layerMain:addChild(self.layerTile_)

    local fanNum = 10

    local textRuler = "每中一花加10番"
    self.lablePromptInfo_:setText(textRuler)

    if not self.hitTiles_ or #self.hitTiles_ == 0 then
    else
        local allHitTilesNumber = #self.hitTiles_
        local allfanNum = tostring(fanNum * allHitTilesNumber) .. "F"

        self.imgFanBg_ = ccui.ImageView:create(GAME_JSMJ_IMAGES_RES .. "awardflower/score_light_bg2.png")
        self.imgFanBg_:setAnchorPoint(cc.p(0.5,0.5))
        self.imgFanBg_:setPosition(0, 0)
        self.imgFanBg_:setVisible(false)
        self.imgFanBg_:setScale(self.dimens_.scale_ * 0.2)
        self.layerFanFont_:addChild(self.imgFanBg_)

        -- 奖花总番数
--        self.awardFanFont_ = jj.ui.JJLabelBMFont.new({
--            text = "+" .. allfanNum,
--            align = ui.TEXT_ALIGN_CENTER,
--            valign = ui.TEXT_VALIGN_CENTER,
--            font = self.theme_:getImage("game/awardflower/awardflower_fan_font.fnt")
--        })
       -- self.awardFanFont_ = display.newBMFontLabel({font = GAME_JSMJ_IMAGES_RES.."awardflower/awardflower_fan_font.fnt", text = "20" })
        self.awardFanFont_ = ccui.TextBMFont:create()
	    self.awardFanFont_:setFntFile(GAME_JSMJ_FONT_RES.."awardflower_fan_1.fnt")
	    self.awardFanFont_:setString("+" .. allfanNum)

        self.awardFanFont_:setAnchorPoint(cc.p(0.5,0.5))
        self.awardFanFont_:setPosition(0,0)
        self.awardFanFont_:setScale(self.dimens_.scale_ * 0.8)
        self.awardFanFont_:setVisible(false)
        self.layerFanFont_:addChild(self.awardFanFont_)
    end

    if self.flowerTiles_ then
        self:createTiles(self.layerTile_) --创建牌的正面及背面
        self:initDialogTitleAnim() --骨骼动画标题
--        if self:getHasAnim() then
--            SoundManager:playEffect(MahjongDef.GAME_SFX.SOUND_AWARD_FLOWER_SHOW)
--        end
        self:playTileEnterAnim() --牌张进场的动画
    else
        self.layerTitleStatic_:setVisible(false)
        self.layerTitleAnim_:setVisible(false)
    end
end

function C:initData()
    self.flowerTiles_ = self.mahjongData_:getAwardFlowerAllTiles() --所有能获得奖花的牌
    self.hitTiles_ = self.mahjongData_:getAwardFlowerHitTiles() -- 已经中奖花的牌列表
--    self.flowerTiles_ = self.parentView_:getAwardFlowerAllTiles() --所有能获得奖花的牌
--    self.hitTiles_ = self.parentView_:getAwardFlowerHitTiles() -- 已经中奖花的牌列表
end

--显示重奖的动画
function C:drawHitTiles(index)
    if not self.hitTiles_ or #self.hitTiles_ == 0 then
        return
    end
    local layerTile = self.layerTile_
    local dataWidth = self:calcRealDataWidth()
    local dataHeight = self:calcRealDataHeight()
    -- 画牌
    local drawCount = 0

    if self.hitTiles_[index] then
        local awardtile = self.hitTiles_[index]
        for k, t in pairs(self.flowerTiles_) do

            local cardX, cardY = self.imgTiles_[k]:getPosition()

            if awardtile.id_ == t.id_ then
                local armatruePlist = nil

                local armatrueScale = nil --放大的效果
                local params = nil
                --SoundManager:playEffect(MahjongDef.GAME_SFX.SOUND_AWARD_FLOWER_SELECT)
                self.layerOneTile_[k]:setScale(self.dimens_.scale_ * 0.8)
               -- if MahjongArmatureUtil:isArmatureSupported() then
--                    local jsonName = "game/awardflower/anim/awardflower.ExportJson"
--                    params = {
--                        picture = self.theme_:getImage("game/awardflower/anim/awardflower0.png"),
--                        exportJson = self.theme_:getImage(jsonName),
--                        name = "awardflower",
--                    }
--                    armatrueScale = MahjongArmatureUtil:createArmatureByConfig(params)
                    armatrueScale = ccs.Armature:create("awardflower")
                    armatrueScale:setPosition(self.tileWidth_ / 2 + self.dimens_:getDimens(0),
                        self.dimens_:getDimens(0))
                    armatrueScale:setScale(self.dimens_.scale_ * 0.9)
                    armatrueScale:setZOrder(ZORDER_TILES_ANIM2)
                    self.layerOneTile_[k]:addChild(armatrueScale)
                    armatrueScale:getAnimation():play("jianghuapai")
                --end
                --                            self.imgTiles_[k]:setVisible(false)
                local delay0 = CCDelayTime:create(19 * SEC_PER_FRAME)
                local arrayScale = { }
                table.insert(arrayScale, CCScaleTo:create(19 * SEC_PER_FRAME, 1.2))
                --arrayScale:addObject(CCScaleTo:create(2 * SEC_PER_FRAME, 1.1))
                local actionScale = cc.Sequence:create(arrayScale)
                self.layerOneTile_[k]:runAction(actionScale)

                local arrayMaskScale = { }
                table.insert(arrayMaskScale,delay0)
                local rmCall0 = CCCallFunc:create(function()
                    self.imgTilesMask_[k]:setVisible(false)
                end)
                table.insert(arrayMaskScale,rmCall0)

                local actionMaskScale = CCSequence:create(arrayMaskScale)
                self.imgTilesMask_[k]:setVisible(true)
                self.imgTilesMask_[k]:runAction(actionMaskScale)

                local delay = CCDelayTime:create(2 * SEC_PER_FRAME)
                local rmCall = CCCallFunc:create(function()
                    self.imgTiles_[k]:setVisible(true)

                    if armatruePlist then
                        armatruePlist:stopAllActions()
                        self.layerOneTile_[k]:getNode():removeChild(armatruePlist)
                        armatruePlist = nil
                    end

                    -- 循环的动画 start
                    --if MahjongArmatureUtil:isArmatureSupported() then
                    
                        armatruePlist = ccs.Armature:create("awardflower")
                        --armatruePlist = MahjongArmatureUtil:createArmatureByConfig(params)
                        armatruePlist:setPosition(self.tileWidth_ / 2 + self.dimens_:getDimens(0),
                            self.dimens_:getDimens(0))
                        armatruePlist:setScale(self.dimens_.scale_ * 0.85)
                        armatruePlist:setZOrder(ZORDER_TILES_ANIM)
                        self.layerOneTile_[k]:addChild(armatruePlist)
                        armatruePlist:getAnimation():play("jianghuapai_zhongjiang")
                        PLAY_SOUND(GAME_JSMJ_SOUND_RES.."awardlight.mp3")

--                    else
--                        local imgSelect = ccui.ImageView:create(GAME_JSMJ_IMAGES_RES .. "awardflower/img_select.png")
--                        imgSelect:setAnchorPoint(AnchorPointDefine.CENTER)
--                        imgSelect:setZOrder(ZORDER_TILES_ANIM)
--                        imgSelect:setPosition(self.tileWidth_ / 2, self.tileHeight_ / 2)
--                        imgSelect:setScale(self.dimens_.scale_ * 0.9)
--                        self.layerOneTile_[k]:addChild(imgSelect)
--                    end
                    -- 循环的动画 end

                    if index == #self.hitTiles_ then
                        self:playFanNumAnim(true)
                    end
                end)

                local arrayDelay = { }

                table.insert(arrayDelay,delay)
                table.insert(arrayDelay,rmCall)

                local actions = cc.Sequence:create(arrayDelay)
                layerTile:runAction(actions)

                break -- 退出循环
            end

            drawCount = drawCount + 1
        end
    end
end

--显示所有重奖的牌张，　无动画
function C:drawHitTilesNoAnim()
    if not self.hitTiles_ or #self.hitTiles_ == 0 then
        return
    end
    local layerTile = self.layerTile_
    local dataWidth = self:calcRealDataWidth()
    local dataHeight = self:calcRealDataHeight()
    -- 画牌

    local drawCount = #self.hitTiles_
    for index = 1, drawCount do
        if self.hitTiles_[index] then
            local awardtile = self.hitTiles_[index]
            for k, t in pairs(self.flowerTiles_) do

                local cardX, cardY = self.imgTiles_[k]:getPosition()
                if awardtile.id_ == t.id_ then
                    local armatruePlist = nil
                    local params = nil

                    self.imgTiles_[k]:setVisible(true)

                    -- 循环的动画 start
                    --if MahjongArmatureUtil:isArmatureSupported() then
--                        local jsonName = "game/awardflower/anim/awardflower.ExportJson"
--                        params = {
--                            picture = self.theme_:getImage("game/awardflower/anim/awardflower0.png"),
--                            exportJson = self.theme_:getImage(jsonName),
--                            name = "awardflower",
--                        } 
--                        armatruePlist = MahjongArmatureUtil:createArmatureByConfig(params)
                        armatruePlist = ccs.Armature:create("awardflower")
                        armatruePlist:setPosition(self.tileWidth_ / 2, self.dimens_:getDimens(0))
                        armatruePlist:setScale(self.dimens_.scale_ * 0.92)
                        armatruePlist:setZOrder(ZORDER_TILES_ANIM)
                        self.layerOneTile_[k]:addChild(armatruePlist)
                        armatruePlist:getAnimation():play("jianghuapai_zhongjiang")
                        self.layerOneTile_[k]:setScale(1.1)
--                    else
--                        local imgSelect = ccui.ImageView:create(GAME_JSMJ_IMAGES_RES .. "awardflower/img_select.png")
--                        imgSelect:setAnchorPoint(AnchorPointDefine.CENTER)
--                        imgSelect:setZOrder(ZORDER_TILES_ANIM)
--                        imgSelect:setPosition(self.tileWidth_ / 2, self.tileHeight_ / 2)
--                        imgSelect:setScale(self.dimens_.scale_)
--                        self.layerOneTile_[k]:addChild(imgSelect)
--                    end
                    -- 循环的动画 end
                    break -- 退出循环
                end
            end
        end

        -- 全中，　特效加强
        --if MahjongArmatureUtil:isArmatureSupported() then
            if #self.hitTiles_ == #self.flowerTiles_ then
                local armatrueLoop = nil --5张全中，加强的特效
                local tileNum = #self.hitTiles_
--                local params = {
--                    picture = self.theme_:getImage("game/awardflower/anim/awardflower0.png"),
--                    exportJson = self.theme_:getImage("game/awardflower/anim/awardflower.ExportJson"),
--                    name = "awardflower",
--                }
                for k = 1, tileNum do
                    if armatrueLoop then
                        armatrueLoop:stopAllActions()
                        self.layerOneTile_[k]:getNode():removeChild(armatrueLoop)
                        armatrueLoop = nil
                    end

--                    armatrueLoop = MahjongArmatureUtil:createArmatureByConfig(params)
                    armatrueLoop = ccs.Armature:create("awardflower")
                    armatrueLoop:setPosition(self.tileWidth_ / 2 ,0)
                    armatrueLoop:setScale(self.dimens_.scale_ * 0.92)
                    armatrueLoop:setZOrder(ZORDER_TILES_ANIM)
                    self.layerOneTile_[k]:addChild(armatrueLoop)
                    armatrueLoop:getAnimation():play("jianghuapai_loop")
                end
            end
        --end
    end
    self:playFanNumAnim(false)
end

--[[--
        计算实际显示的数据占用宽度
        @param none
        @return dataWidth:数据占用宽度
]]
function C:calcRealDataWidth()
    -- n张牌宽度 + (n-1)间隔
    local dataWidth = 0
    if self.flowerTiles_ then
        local size = #self.flowerTiles_
        if size > MAX_TING_NUM then
            size = MAX_TING_NUM
        end
        dataWidth = (self.tileWidth_ + self.tingBetweenW_) * size - self.tingBetweenW_

        dataWidth = dataWidth
    end
    return dataWidth
end

--计算实际显示的数据占用高度
function C:calcRealDataHeight()
    -- 牌高度 + 番数高度 + 张数高度 + 只胡自摸高度(自家有)
    local dataHeight = self.tileHeight_ + 2 * self.dimens_:getDimens(30)
    dataHeight = dataHeight + self.dimens_:getDimens(50)

    return dataHeight
end

--退出函数
function C:onExit()
end

--[[--
        获取字符串长度
        @param str:字符串
        @param fontHeight:字体大小
        @return width:字符串长度
  ]]
function C:getStringWidth(str)
--    if str then
--        local size = Util:getStringSize(str, font, self.fanStrFontsHeight_, maxSize)
--        local width = 0
--        if size and size.width then
--            width = size.width
--        end
--        if width == 0 then
--            width = self.dimens_:getDimens(70)
--        end
--        return width
--    end
    return 0
end

--点击事件处理
function C:onClick(target)
    local id = target:getId()
end

-- 奖花弹框动画(骨骼动画)
function C:initDialogTitleAnim()
    --if MahjongArmatureUtil.isArmatureSupported() then
        self.layerTitleStatic_:setVisible(false)
        self.layerTitleAnim_:setVisible(true)
--        local params = {
--            picture = self.theme_:getImage("game/awardflower/anim/awardflower0.png"),
--            exportJson = self.theme_:getImage("game/awardflower/anim/awardflower.ExportJson"),
--            name = "awardflower",
--        }

        local x = self.dimens_:getDimens(359)
        local y = self.dimens_:getDimens(160)

        local allHitTilesNumber = #self.hitTiles_
        if allHitTilesNumber > 0 then
            if self.guang1_ then
                self.guang1_:stopAllActions()
                self.layerTitleAnim_:removeChild(self.guang1_)
                self.guang1_ = nil
            end
--            self.guang1_ = MahjongArmatureUtil:createArmatureByConfig(params)
            self.guang1_ = ccs.Armature:create("awardflower")
            self.guang1_:setPosition(0, 0)
            self.guang1_:setScale(self.dimens_.scale_)
            self.layerTitleAnim_:addChild(self.guang1_)
            self.guang1_:getAnimation():play("jianghua_guang01")

            if self.guang2_ then
                self.guang2_:stopAllActions()
                self.layerTitleAnim_:removeChild(self.guang2_)
                self.guang2_ = nil
            end
--            self.guang2_ = MahjongArmatureUtil:createArmatureByConfig(params)
            self.guang2_ = ccs.Armature:create("awardflower")
            self.guang2_:setPosition(0, 0)
            self.guang2_:setScale(1)
            self.layerTitleAnim_:addChild(self.guang2_)
            self.guang2_:getAnimation():play("jianghua_guang02")
            self.guang2_:setVisible(false)
        end

        armatrueTitle = ccs.Armature:create("awardflower")
--        local armatrueTitle = MahjongArmatureUtil:createArmatureByConfig(params)

        armatrueTitle:setPosition(0, 0)
        armatrueTitle:setScale(self.dimens_.scale_)
        self.layerTitleAnim_:addChild(armatrueTitle)
        armatrueTitle:getAnimation():play("jianghua")

--    else
--        self.layerTitleStatic_:setVisible(true)
--        self.layerTitleAnim_:setVisible(false)
--    end
end

--[[ 创建牌的正面及背面
     @param layerTile: 所在的层
     @return none
 ]]
function C:createTiles(layerTile)
    local dataWidth = self:calcRealDataWidth()
    local dataHeight = self:calcRealDataHeight()
    if not self.flowerTiles_ then
        error(" showTilesBg no tiles error")
        return
    end
    local maxTilesNum = #self.flowerTiles_
    local m = 0
    for k, t in pairs(self.flowerTiles_) do
        local rLeft = 0 --self:getLeftTileTotalWidth() + (self.tingBetweenW_ + self.tileWidth_) * (k - 1)
        rLeft = (self.tingBetweenW_ + self.tileWidth_) * (k - 1)
        local rTop = dataHeight

        -- 画牌
        rTop = rTop - self.tileHeight_ - self.dimens_:getDimens(180)
        t.mode_ = 0

        self.layerOneTile_[k] = ccui.Layout:create()
        self.layerOneTile_[k]:setContentSize(self.tileWidth_, self.tileHeight_)
        self.layerOneTile_[k]:setPosition(rLeft + self.tileWidth_ / 2, rTop + self.tileHeight_ / 2)
        self.layerOneTile_[k]:setAnchorPoint(cc.p(0.5,0.5))
        layerTile:addChild(self.layerOneTile_[k])

        -- 牌背面
        self.imgTilesBg_[k] = ccui.ImageView:create(GAME_JSMJ_IMAGES_RES .. "tilebg/player_down.png")
        self.imgTilesBg_[k]:setScale(self.dimens_.scale_)
        self.imgTilesBg_[k]:setAnchorPoint(cc.p(0.5,0.5))
        self.layerOneTile_[k]:addChild(self.imgTilesBg_[k])
        self.imgTilesBg_[k]:setPosition(t.tileWidth_/2, t.tileHeight_/2)
        self.imgTilesBg_[k]:setVisible(false)

        -- 牌正面
        self.imgTiles_[k] = t:getAwardFlowerTileImage(self.dimens_.scale_)
        --self.imgTiles_[k]:setPosition(0, 0)
        --self.imgTiles_[k]:setAnchorPoint(cc.p(0.5,1))
        self.imgTiles_[k]:setTag(k)
        self.imgTiles_[k]:setZOrder(ZORDER_TILES)
        self.imgTiles_[k]:setVisible(false)
        self.imgTiles_[k]:setScale(self.dimens_.scale_)
        self.layerOneTile_[k]:addChild(self.imgTiles_[k])

        self.imgTilesMask_[k] = ccui.ImageView:create(GAME_JSMJ_IMAGES_RES .. "tile/mahjong_tile_undisable.png")
        self.imgTilesMask_[k]:setScale(self.dimens_.scale_)
        self.imgTilesMask_[k]:setAnchorPoint(cc.p(0.5,0.5))
        self.layerOneTile_[k]:addChild(self.imgTilesMask_[k])
        self.imgTilesMask_[k]:setPosition(t.tileWidth_/2, t.tileHeight_/2)
        self.imgTilesMask_[k]:setZOrder(ZORDER_TILES_ANIM2)
        self.imgTilesMask_[k]:setVisible(false)
    end
end

--[[ 显示及关闭背景
     @param layerMain: 所在的层
     @return none
 ]]
function C:showTilesBg(show)
    if self.imgTilesBg_ then
        local num = #self.imgTilesBg_
        for i = 1, num do
            self.imgTilesBg_[i]:setVisible(show)
        end
    end
end

--[[ 显示及关闭牌张正面
     @param layerMain: 所在的层
     @return none
 ]]
function C:showTiles(show)
    if self.imgTiles_ then
        local num = #self.imgTiles_
        for i = 1, num do
            self.imgTiles_[i]:setVisible(show)
        end
    end
end

--[[ 创建牌的正面及背面
     @param layerMain: 所在的层
     @return none
 ]]
function C:showTurnCardAnim(index)
    if not self.flowerTiles_ then
        return
    end

    local turnCardTime = 3 * SEC_PER_FRAME
    local maxTilesNum = #self.flowerTiles_
    local m = 0
    --for k, t in pairs(self.flowerTiles_) do
    -- 翻转
    local cameraBg1 = CCOrbitCamera:create(turnCardTime, 1, 0, 0, -90, 0, 0)
    local rmCallBg1 = CCCallFunc:create(function()
        self.imgTiles_[index]:setVisible(true)
    end)
    self.imgTilesBg_[index]:runAction(cc.Sequence:create(cameraBg1, rmCallBg1))

    local camera1 = CCOrbitCamera:create(turnCardTime, 1, 0, 0, -90, 0, 0)
    local rmCall1 = CCCallFunc:create(function()
        self.imgTilesBg_[index]:setVisible(false)
        local camera2 = CCOrbitCamera:create(turnCardTime, 1, 0, -270, -90, 0, 0)
        local rmCall2 = CCCallFunc:create(function()
            m = m + 1 --最大值为8， 从中选一个值
            if maxTilesNum == m then
            end
            self.imgTilesMask_[index]:setVisible(true)
        end)
        self.imgTiles_[index]:runAction(cc.Sequence:create(camera2, rmCall2))
    end)
    self.imgTiles_[index]:runAction(cc.Sequence:create(camera1, rmCall1))
    --end
end

--背张背面移少的动画
function C:playTileEnterAnim()
    if self:getHasAnim() then
        for k = 1, #self.imgTilesBg_ do
            -- 显示背面
            self.imgTilesBg_[k]:setVisible(true)
        end
        local allHitTilesNumber = #self.hitTiles_
        local layerTile = self.layerTile_
        if layerTile then
            local animtime = 0.2
            local moveDistence = self.dimens_:getDimens(125)

            layerTile:setPosition(display.width -280 - moveDistence, display.height)

            local array = { }
            table.insert(array, CCMoveTo:create(animtime, ccp(display.width-280, display.height)))
            local function CallFucnCallback1()
                if self.guang1_ then
                    self.guang1_:setVisible(false)
                end
                if allHitTilesNumber > 0 then
                    if self.guang2_ then
                        self.guang2_:setVisible(true)
                    end
                end
                -- 运行第二级动画
                self:playAllAnim()
            end

            table.insert(array, CCCallFuncN:create(CallFucnCallback1))

            local action1 = cc.Sequence:create(array)
            layerTile:runAction(action1)
        end
    else
        -- 无动画情况下，直接显示牌
        for k = 1, #self.imgTilesBg_ do
            -- 显示背面
            self.imgTilesBg_[k]:setVisible(false)
            self.imgTiles_[k]:setVisible(true)
        end
        self:drawHitTilesNoAnim()
    end
end

--层示所有动画流程
function C:playAllAnim()
    local layerTile = self.layerTile_
    if layerTile then
        self:showTilesBg(true) --显示背惊
        local turnCardTime = 25 --翻中奖牌的时间(一张张翻牌的时间)
        local delay0 = CCDelayTime:create(5 * SEC_PER_FRAME)

        local delay1 = CCDelayTime:create(4 * SEC_PER_FRAME)
        local delay2 = CCDelayTime:create(4 * SEC_PER_FRAME)
        local delayValue = 60
        if not self.hitTiles_ or #self.hitTiles_ == 0 then
            turnCardTime = 1
            delayValue = 60
        else
            -- 80: 全翻开后，停留时间
            delayValue = 80 + turnCardTime * (#self.hitTiles_)
        end
        local delay3 = CCDelayTime:create(delayValue * SEC_PER_FRAME)
        local delayTurnCard = CCDelayTime:create(turnCardTime * SEC_PER_FRAME)

        local array = { }
        table.insert(array, delay0)
        local callTurnCard = CCCallFunc:create(function()
            self.turnCardHandler_ = scheduler:scheduleScriptFunc(handler(self, self.onTimerTurnCard), 0.1, false) --逐个翻牌
        end)
        table.insert(array, callTurnCard)
        local callShowPlist = CCCallFunc:create(function()
            if not self.hitTiles_ or #self.hitTiles_ == 0 then

            else
                self.hitCardHandler_ = scheduler:scheduleScriptFunc(handler(self, self.onTimerHitCard),
                    (turnCardTime - 1) * SEC_PER_FRAME, false) --逐个翻牌
            end
        end)
        table.insert(array, callShowPlist)

        table.insert(array, delay1)
        local callShowHandCardMask = CCCallFunc:create(function()
            self.parentView_:drawTileFrontMask(true) -- 对手牌蒙灰处理
        end)
        table.insert(array, callShowHandCardMask)
        local animEnd = CCCallFunc:create(function()
            if self.callback then
			    self.callback()
		    end
            self.parentView_:showAwardFlowerView(false)    
        end)
        table.insert(array, delay3)
        table.insert(array, animEnd)
        local actions = cc.Sequence:create(array)
        layerTile:runAction(actions)
    end
end

--翻牌倒计时
function C:stopTurnCardSchedule()
    if self.turnCardHandler_ then
        scheduler:unscheduleScriptEntry(self.turnCardHandler_)
        self.turnCardHandler_ = nil
    end
end

--创建牌的正面及背面
function C:onTimerTurnCard()
    if self.flowerTiles_ then
        local allTilesNumber = #self.flowerTiles_
        self.turnCount_ = self.turnCount_ + 1
        if self.turnCount_ > allTilesNumber then
            self:stopTurnCardSchedule()
        else
            self:showTurnCardAnim(self.turnCount_) --从第一个开始展开牌
        end
    end
end

--翻牌倒计时
function C:stopHitCardSchedule()
    if self.hitCardHandler_ then
        scheduler:unscheduleScriptEntry(self.hitCardHandler_)
        self.hitCardHandler_ = nil
    end
end

--显示中奖的牌张
function C:onTimerHitCard()
    if self.flowerTiles_ then
        local allHitTilesNumber = #self.hitTiles_
        self.hitTileIndex_ = self.hitTileIndex_ + 1
        if self.hitTileIndex_ > allHitTilesNumber then
            self:stopTurnCardSchedule()
            --if MahjongArmatureUtil:isArmatureSupported() then
                -- 全中，　特效加强
                if #self.hitTiles_ == #self.flowerTiles_ then
                    local armatrueLoop = nil --5张全中，加强的特效
                    local tileNum = #self.hitTiles_
--                    local params = {
--                        picture = self.theme_:getImage("game/awardflower/anim/awardflower0.png"),
--                        exportJson = self.theme_:getImage("game/awardflower/anim/awardflower.ExportJson"),
--                        name = "awardflower",
--                    }

                    for k = 1, tileNum do
                        if armatrueLoop then
                            armatrueLoop:stopAllActions()
                            self.layerOneTile_[k]:getNode():removeChild(armatrueLoop)
                            armatrueLoop = nil
                        end

                        armatrueLoop = ccs.Armature:create("awardflower")
--                        armatrueLoop = MahjongArmatureUtil:createArmatureByConfig(params)
                        armatrueLoop:setPosition(self.tileWidth_ / 2 + self.dimens_:getDimens(0),
                            self.dimens_:getDimens(0))
                        armatrueLoop:setScale(self.dimens_.scale_ * 0.92)
                        armatrueLoop:setZOrder(ZORDER_TILES_ANIM)
                        self.layerOneTile_[k]:getNode():addChild(armatrueLoop)
                        armatrueLoop:getAnimation():play("jianghuapai_loop")
                    end
                end
            --end

        else
            self:drawHitTiles(self.hitTileIndex_) --从第一个开始展开牌
            if self.mahjongData_:getWinSeat() == self.mahjongData_:getSelfSeat() then
                self.parentView_:drawFlowerHitTile(self.hitTiles_[self.hitTileIndex_]) -- 高亮选定的牌
            end
        end
    end
end

--[[--
        获取是否有动画的标识
        @param hasAnim: 是否有动画
        @return none
  ]]
function C:getHasAnim()
    return self.hasAnim_
end

--[[ 总翻数显示的动画
     @param hasAnim: 是否有动画
 ]]
function C:playFanNumAnim(hasAnim)
    if hasAnim then
        self.awardFanFont_:setVisible(true)
        self.imgFanBg_:setVisible(true)

        local animtime = 0.2
        local moveDistenceX = self.dimens_:getDimens(125)
        local moveDistenceY = self.dimens_:getDimens(25)

        local targetX = self.dimens_:getDimens(0)
        local targetY = self.dimens_:getDimens(0)

        self.awardFanFont_:setPosition(targetX + moveDistenceX, targetY - moveDistenceY)

        local array = { }
        table.insert(array, CCMoveTo:create(animtime, ccp(targetX, targetY)))
        local function CallFucnCallback1()
            self:playFanNumAnim2(hasAnim)
        end

        table.insert(array, CCCallFuncN:create(CallFucnCallback1))

        local action1 = cc.Sequence:create(array)
        self.awardFanFont_:runAction(action1)

    else
        self.awardFanFont_:setVisible(true)
    end
end

function C:playFanNumAnim2(hasAnim)
    if hasAnim then
        self.awardFanFont_:setVisible(true)
        self.imgFanBg_:setVisible(true)
        local standScale = self.dimens_.scale_
        local standScale = 1.2
        local arrayScale = { }
        local delay = CCDelayTime:create(0 * SEC_PER_FRAME)
        local delayInVisible = CCDelayTime:create(0.3)
        table.insert(arrayScale, delay)
        table.insert(arrayScale, CCScaleTo:create(0 * SEC_PER_FRAME, standScale * 1.6))
        table.insert(arrayScale, CCScaleTo:create(3 * SEC_PER_FRAME, standScale * 1.6, standScale * 0.5))
        table.insert(arrayScale, CCScaleTo:create(2 * SEC_PER_FRAME, standScale * 1))

        local rmCall = CCCallFunc:create(function()
            --self.awardFanFont_:setVisible(false)
            self.imgFanBg_:setVisible(false)
        end)
        table.insert(arrayScale, delayInVisible)
        table.insert(arrayScale, rmCall)

        local actionScale = cc.Sequence:create(arrayScale)
        local arraySpawn = { }
        table.insert(arraySpawn, actionScale)

        local actions = CCSpawn:create(arraySpawn)
        self.imgFanBg_:runAction(actions)
    end
end

return C