local moveVertSource = 
"attribute vec2 a_position;\n"..
"attribute vec2 a_texCoord;\n"..
"uniform float ratio; \n"..
"uniform float radius; \n"..
"uniform float width;\n"..
"uniform float height;\n"..
"uniform float offx;\n"..
"uniform float offy;\n"..
"uniform float rotation;\n"..
"varying vec4 v_fragmentColor;\n"..
"varying vec2 v_texCoord;\n"..

"void main()\n"..
"{\n"..
"    vec4 tmp_pos = vec4(0.0, 0.0, 0.0, 0.0);;\n"..
"    tmp_pos = vec4(a_position.x, a_position.y, 0.0, 1.0);\n"..

"   float halfPeri = radius * 3.14159; \n"..
"   float hr = height * ratio;\n"..
"   if(hr > 0.0 && hr <= halfPeri){\n"..
"         if(tmp_pos.y < hr){\n"..
"               float rad = hr/ 3.14159;\n"..
"               float arc = (hr-tmp_pos.y)/rad;\n"..
"               tmp_pos.y = hr - sin(arc)*rad;\n"..
"               tmp_pos.z = rad * (1.0-cos(arc)); \n"..
"          }\n"..
"   }\n"..
"   if(hr > halfPeri){\n"..
"        float straight = (hr - halfPeri)/2.0;\n"..
"        if(tmp_pos.y < straight){\n"..
"            tmp_pos.y = hr  - tmp_pos.y;\n"..
"            tmp_pos.z = radius * 2.0; \n"..
"        }\n"..
"        else if(tmp_pos.y < (straight + halfPeri)) {\n"..
"            float dy = halfPeri - (tmp_pos.y - straight);\n"..
"            float arc = dy/radius;\n"..
"            tmp_pos.y = hr - straight - sin(arc)*radius;\n"..
"            tmp_pos.z = radius * (1.0-cos(arc)); \n"..
"        }\n"..
"    }\n"..
"    float y1 = tmp_pos.y;\n"..
"    float z1 = tmp_pos.z;\n"..
"    float y2 = height;\n"..
"    float z2 = 0.0;\n"..
"    float sinRat = sin(rotation);\n"..
"    float cosRat = cos(rotation);\n"..
"    tmp_pos.y=(y1-y2)*cosRat-(z1-z2)*sinRat+y2;\n"..
"    tmp_pos.z=(z1-z2)*cosRat+(y1-y2)*sinRat+z2;\n"..
"    tmp_pos.y = tmp_pos.y - height/2.0*(1.0-cosRat);\n"..
"    tmp_pos += vec4(offx, offy, 0.0, 0.0);\n"..
"    gl_Position = CC_MVPMatrix * tmp_pos;\n"..
"    v_texCoord = vec2(a_texCoord.x, a_texCoord.y);\n"..
"}\n";

local lTRVertSource = 
"attribute vec2 a_position;\n"..
"attribute vec2 a_texCoord;\n"..
"uniform float ratio; \n"..
"uniform float radius; \n"..
"uniform float width;\n"..
"uniform float height;\n"..
"uniform float offx;\n"..
"uniform float offy;\n"..
"uniform float rotation;\n"..
"varying vec2 v_texCoord;\n"..

"void main()\n"..
"{\n"..
"    vec4 tmp_pos = vec4(a_position.x, a_position.y, 0.0, 1.0);\n"..
"    float halfPeri = radius * 3.14159; \n"..
"    float hr = width * ratio;\n"..
"    if(hr > 0.0 && hr <= halfPeri){\n"..
"         if(tmp_pos.x < hr){\n"..
"               float rad = hr/ 3.14159;\n"..
"               float arc = (hr-tmp_pos.x)/rad;\n"..
"               tmp_pos.x = hr - sin(arc)*rad;\n"..
"               tmp_pos.z = rad * (1.0-cos(arc)); \n"..
"          }\n"..
"   }\n"..
"   if(hr > halfPeri){\n"..
"        float straight = (hr - halfPeri)/2.0;\n"..
"        if(tmp_pos.x < straight){\n"..
"            tmp_pos.x = hr  - tmp_pos.x;\n"..
"            tmp_pos.z = radius * 2.0; \n"..
"        }\n"..
"        else if(tmp_pos.x < (straight + halfPeri)) {\n"..
"            float dy = halfPeri - (tmp_pos.x - straight);\n"..
"            float arc = dy/radius;\n"..
"            tmp_pos.x = hr - straight - sin(arc)*radius;\n"..
"            tmp_pos.z = radius * (1.0-cos(arc)); \n"..
"        }\n"..
"    }\n"..
"    float x1 = tmp_pos.x;\n"..
"    float z1 = tmp_pos.z;\n"..
"    float x2 = width;\n"..
"    float z2 = 0.0;\n"..
"    float sinRat = sin(rotation);\n"..
"    float cosRat = cos(rotation);\n"..
"    tmp_pos.x=(x1-x2)*cosRat-(z1-z2)*sinRat+x2;\n"..
"    tmp_pos.z=(z1-z2)*cosRat+(x1-x2)*sinRat+z2;\n"..
"    tmp_pos.x = tmp_pos.x - width/2.0*(1.0-cosRat);\n"..
"    tmp_pos += vec4(offx, offy, 0.0, 0.0);\n"..
"    gl_Position = CC_MVPMatrix * tmp_pos;\n"..
"    v_texCoord = vec2(a_texCoord.x, a_texCoord.y);\n"..
"}\n";

local rTLVertSource = 
"attribute vec2 a_position;\n"..
"attribute vec2 a_texCoord;\n"..
"uniform float ratio; \n"..
"uniform float radius; \n"..
"uniform float width;\n"..
"uniform float height;\n"..
"uniform float offx;\n"..
"uniform float offy;\n"..
"uniform float rotation;\n"..
"varying vec2 v_texCoord;\n"..

"void main()\n"..
"{\n"..
"    vec4 tmp_pos = vec4(width - a_position.x, a_position.y, 0.0, 1.0);\n"..
"    float halfPeri = radius * 3.14159; \n"..
"    float hr = width * ratio;\n"..
"    if(hr > 0.0 && hr <= halfPeri){\n"..
"         if(tmp_pos.x < hr){\n"..
"               float rad = hr/ 3.14159;\n"..
"               float arc = (hr-tmp_pos.x)/rad;\n"..
"               tmp_pos.x = hr - sin(arc)*rad;\n"..
"               tmp_pos.z = rad * (1.0-cos(arc)); \n"..
"          }\n"..
"   }\n"..
"   if(hr > halfPeri){\n"..
"        float straight = (hr - halfPeri)/2.0;\n"..
"        if(tmp_pos.x < straight){\n"..
"            tmp_pos.x = hr  - tmp_pos.x;\n"..
"            tmp_pos.z = radius * 2.0; \n"..
"        }\n"..
"        else if(tmp_pos.x < (straight + halfPeri)) {\n"..
"            float dy = halfPeri - (tmp_pos.x - straight);\n"..
"            float arc = dy/radius;\n"..
"            tmp_pos.x = hr - straight - sin(arc)*radius;\n"..
"            tmp_pos.z = radius * (1.0-cos(arc)); \n"..
"        }\n"..
"    }\n"..
"    float x1 = tmp_pos.x;\n"..
"    float z1 = tmp_pos.z;\n"..
"    float x2 = width;\n"..
"    float z2 = 0.0;\n"..
"    float sinRat = sin(rotation);\n"..
"    float cosRat = cos(rotation);\n"..
"    tmp_pos.x=(x1-x2)*cosRat-(z1-z2)*sinRat+x2;\n"..
"    tmp_pos.z=(z1-z2)*cosRat+(x1-x2)*sinRat+z2;\n"..
"    tmp_pos.x = tmp_pos.x - width/2.0*(1.0-cosRat);\n"..
"    tmp_pos.x = width - tmp_pos.x;\n"..
"    tmp_pos += vec4(offx, offy, 0.0, 0.0);\n"..
"    gl_Position = CC_MVPMatrix * tmp_pos;\n"..
"    v_texCoord = vec2(a_texCoord.x, a_texCoord.y);\n"..
"}\n";

local smoothVertSource = 
"attribute vec2 a_position;\n"..
"attribute vec2 a_texCoord;\n"..
"uniform float width;\n"..
"uniform float height;\n"..
"uniform float offx;\n"..
"uniform float offy;\n"..
"uniform float rotation;\n"..
"varying vec2 v_texCoord;\n"..

"void main()\n"..
"{\n"..
"    vec4 tmp_pos = vec4(0.0, 0.0, 0.0, 0.0);;\n"..
"    tmp_pos = vec4(a_position.x, a_position.y, 0.0, 1.0);\n"..
"    float cl = height/5.0;\n"..
"    float sl = (height - cl)/2.0;\n"..
"    float radii = (cl/rotation)/2.0;\n"..
"    float sinRot = sin(rotation);\n"..
"    float cosRot = cos(rotation);\n"..
"    float distance = radii*sinRot;\n"..
"    float centerY = height/2.0;\n"..
"    float poxY1 = centerY - distance;\n"..
"    float poxY2 = centerY + distance;\n"..
"    float posZ = sl*sinRot;\n"..
"    if(tmp_pos.y <= sl){\n"..
"       float length = sl - tmp_pos.y;\n"..
"       tmp_pos.y = poxY1 - length*cosRot;\n"..
"       tmp_pos.z = posZ - length*sinRot;\n"..
"    }\n"..
"    else if(tmp_pos.y < (sl+cl)){\n"..
"       float el = tmp_pos.y - sl;\n"..
"       float rotation2 = -el/radii;\n"..
"       float x1 = poxY1;\n"..
"       float y1 = posZ;\n"..
"       float x2 = centerY;\n"..
"       float y2 = posZ - radii*cosRot;\n"..
"       float sinRot2 = sin(rotation2);\n"..
"       float cosRot2 = cos(rotation2);\n"..
"       tmp_pos.y=(x1-x2)*cosRot2-(y1-y2)*sinRot2+x2;\n"..
"       tmp_pos.z=(y1-y2)*cosRot2+(x1-x2)*sinRot2+y2;\n"..
"    }\n"..
"    else if(tmp_pos.y <= height){\n"..
"        float length = tmp_pos.y - cl - sl;\n"..
"        tmp_pos.y = poxY2 + length*cosRot;\n"..
"        tmp_pos.z = posZ - length*sinRot;\n"..
"    }\n"..
"    tmp_pos += vec4(offx, offy, 0.0, 0.0);\n"..
"    gl_Position = CC_MVPMatrix * tmp_pos;\n"..
"    v_texCoord = vec2(a_texCoord.x, 1.0 - a_texCoord.y);\n"..
"}\n"

local lTRSmoothVertSource = 
"attribute vec2 a_position;\n"..
"attribute vec2 a_texCoord;\n"..
"uniform float width;\n"..
"uniform float height;\n"..
"uniform float offx;\n"..
"uniform float offy;\n"..
"uniform float rotation;\n"..
"varying vec2 v_texCoord;\n"..

"void main()\n"..
"{\n"..
"    vec4 tmp_pos = vec4(a_position.x, a_position.y, 0.0, 1.0);\n"..
"    float cl = width/5.0;\n"..
"    float sl = (width - cl)/2.0;\n"..
"    float radii = (cl/rotation)/2.0;\n"..
"    float sinRot = sin(rotation);\n"..
"    float cosRot = cos(rotation);\n"..
"    float distance = radii*sinRot;\n"..
"    float centerX = width/2.0;\n"..
"    float posX1 = centerX - distance;\n"..
"    float posX2 = centerX + distance;\n"..
"    float posZ = sl*sinRot;\n"..
"    if(tmp_pos.x <= sl){\n"..
"       float length = sl - tmp_pos.x;\n"..
"       tmp_pos.x = posX1 - length*cosRot;\n"..
"       tmp_pos.z = posZ - length*sinRot;\n"..
"    }\n"..
"    else if(tmp_pos.x < (sl+cl)){\n"..
"       float el = tmp_pos.x - sl;\n"..
"       float rotation2 = -el/radii;\n"..
"       float x1 = posX1;\n"..
"       float y1 = posZ;\n"..
"       float x2 = centerX;\n"..
"       float y2 = posZ - radii*cosRot;\n"..
"       float sinRot2 = sin(rotation2);\n"..
"       float cosRot2 = cos(rotation2);\n"..
"       tmp_pos.x=(x1-x2)*cosRot2-(y1-y2)*sinRot2+x2;\n"..
"       tmp_pos.z=(y1-y2)*cosRot2+(x1-x2)*sinRot2+y2;\n"..
"    }\n"..
"    else if(tmp_pos.x <= width){\n"..
"        float length = tmp_pos.x - cl - sl;\n"..
"        tmp_pos.x = posX2 + length*cosRot;\n"..
"        tmp_pos.z = posZ - length*sinRot;\n"..
"    }\n"..
"    tmp_pos += vec4(offx, offy, 0.0, 0.0);\n"..
"    gl_Position = CC_MVPMatrix * tmp_pos;\n"..
"    v_texCoord = vec2(a_texCoord.x, 1.0 - a_texCoord.y);\n"..
"}\n";

local endVertSource = 
"attribute vec2 a_position;\n"..
"attribute vec2 a_texCoord;\n"..
"uniform float offx;\n"..
"uniform float offy;\n"..
"varying vec2 v_texCoord;\n"..

"void main()\n"..
"{\n"..
"    vec4 tmp_pos = vec4(0.0, 0.0, 0.0, 0.0);;\n"..
"    tmp_pos = vec4(a_position.x, a_position.y, 0.0, 1.0);\n"..
"    tmp_pos += vec4(offx, offy, 0.0, 0.0);\n"..
"    gl_Position = CC_MVPMatrix * tmp_pos;\n"..
"    v_texCoord = vec2(a_texCoord.x, 1.0 - a_texCoord.y);\n"..
"}\n"

local strFragSource =
"varying vec2 v_texCoord;\n"..
"void main()\n"..
"{\n"..
    "//TODO, 这里可以做些片段着色特效\n"..
    "gl_FragColor = texture2D(CC_Texture0, v_texCoord);\n"..
"}\n"

local RubCardLayer_Pai = 3.141592
local RubCardLayer_State_Move = 1
local RubCardLayer_State_Smooth = 2
local RubCardLayer_RotationFrame = 10
local RubCardLayer_RotationAnger = RubCardLayer_Pai/3
local RubCardLayer_SmoothFrame = 10
local RubCardLayer_SmoothAnger = RubCardLayer_Pai/6

local RubCardLayer_Dir_du = 0 --上下搓牌
local RubCardLayer_Dir_lr = 1 --左右搓牌
local RubCardLayer_Dir_rl = 2 --右左搓牌
local RubCardLayer_Dir_No = 3 --不搓牌

local RubCardLayer = {}

local function EJExtendUserData(luaCls, cObj)
    local t = tolua.getpeer(cObj)
    if not t then
        t = {}
        tolua.setpeer(cObj, t)
    end
    setmetatable(t, luaCls)
    return cObj 
end

function RubCardLayer:create(szBack, szFont, posX, posY, endCallBack)
    local layer = EJExtendUserData(RubCardLayer, cc.Layer:create())
    self.__index = self
    layer:__init(szBack, szFont, posX, posY, endCallBack)
    return layer
end

function RubCardLayer:__init(szBack, szFont, posX, posY, endCallBack)
    self.divNum = 20
    self.posX = posX
    self.posY = posY
    self.szBack = szBack
    self.szFont = szFont
    self.endCallBack = endCallBack
    local scale = 1
    self.scale = scale
    self.state = RubCardLayer_State_Move
    self.dirState = RubCardLayer_Dir_No

    local glNode = gl.glNodeCreate()
    self.glNode = glNode
    self:addChild(glNode)

    self:createSprites()

    self.udBackBufferInfo = self:__initTexAndPos(true, false);
    self.udFrontBufferInfo = self:__initTexAndPos(false, false);
    self.lrBackBufferInfo = self:__initTexAndPos(true, true);
    self.lrFrontBufferInfo = self:__initTexAndPos(false, true);
    self:__createPrograms()

    self:__registerTouchEvent()

    self.ratioVal = 0

    -- OpenGL绘制函数
    local function draw(transform, transformUpdated)
        if self.state == RubCardLayer_State_Move then
            self:__drawByMoveProgram(0)
        elseif self.state == RubCardLayer_State_Smooth then
            if self.smoothFrame == nil then
                self.smoothFrame = 1
            end
            if self.smoothFrame <= RubCardLayer_RotationFrame then
                self:__drawByMoveProgram(-RubCardLayer_RotationAnger*self.smoothFrame/RubCardLayer_RotationFrame)
            elseif self.smoothFrame < (RubCardLayer_RotationFrame+RubCardLayer_SmoothFrame) then
                local scale = (self.smoothFrame - RubCardLayer_RotationFrame)/RubCardLayer_SmoothFrame
                self:__drawBySmoothProgram(math.max(0.01,RubCardLayer_SmoothAnger*(1-scale)))
            else
                if self.endCallBack then
                    self.endCallBack()
                    self.endCallBack = nil
                end
                self:__drawByEndProgram()
            end
            self.smoothFrame = self.smoothFrame + 1
        end
    end
    glNode:registerScriptDrawHandler(draw)
end

function RubCardLayer:createSprites()
    local backSprite = cc.Sprite:create(self.szBack)
    self.backSprite = backSprite
    backSprite:retain()

    local frontSprite = cc.Sprite:create(self.szFont)
    self.frontSprite = frontSprite
    frontSprite:retain()

    local pokerSize = backSprite:getContentSize();
    self.pokerWidth = pokerSize.height
    self.pokerHeight = pokerSize.width

    self.offx = self.posX - self.pokerWidth/2;
    self.offy = self.posY - self.pokerHeight/2;
    self.backSpriteId = backSprite:getTexture():getName()
    self.frontSpriteId = frontSprite:getTexture():getName()

    self.touchStartY = self.posY - self.pokerHeight/2;
    self.touchStartLRX = self.posX - self.pokerWidth/2;
    self.touchStartRLX = self.posX + self.pokerWidth/2;

    self.udRadiusVal = self.pokerHeight/10;
    self.lrRadiusVal = self.pokerWidth/10;
end

function RubCardLayer:__createPrograms()
    local function __createProgram(vertSource, isUpDown)
        local glProgram = cc.GLProgram:createWithByteArrays(vertSource, strFragSource)
        glProgram:retain()
        glProgram:updateUniforms()
        if isUpDown == 1 then
            glProgram.backBufferInfo = self.udBackBufferInfo
            glProgram.frontBufferInfo = self.udFrontBufferInfo
        elseif isUpDown == 2 then
            glProgram.backBufferInfo = self.lrBackBufferInfo
            glProgram.frontBufferInfo = self.lrFrontBufferInfo
        end
        return glProgram
    end
    self.moveGlProgram = __createProgram(moveVertSource, 1)
    self.lTRGlProgram = __createProgram(lTRVertSource , 2)
    self.rTLGlProgram = __createProgram(rTLVertSource, 2)
    self.smoothGlProgram = __createProgram(smoothVertSource, 3)
    self.lTRSmoothGlProgram = __createProgram(lTRSmoothVertSource, 3)
    self.endGlProgram = __createProgram(endVertSource, 3)
end

function RubCardLayer:__initTexAndPos(isBack,isLeftRight)
    local nDiv = self.divNum
    local verts = {}
    local texs = {}
    local dh = self.pokerHeight/nDiv
    local dw = self.pokerWidth
    if isLeftRight then
        dh = self.pokerHeight
        dw = self.pokerWidth/nDiv
    end
    for c = 1,nDiv do
        local x = 0
        local y = (c-1)*dh
        if isLeftRight then
            x = (c-1)*dw
            y = 0
        end
        local quad = nil
        if isBack then
            quad = {x, y, x+dw, y, x, y+dh, x+dw, y, x+dw, y+dh, x, y+dh}
        else
            quad = {x, y, x, y+dh, x+dw, y, x+dw, y, x, y+dh, x+dw, y+dh}
        end
        for i,v in ipairs(quad) do
            table.insert(verts, v)
        end
        for i=1,6 do
            local quadX = quad[i*2-1]
            local quadY = quad[i*2]
            local numX = 1 - quadY/self.pokerHeight
            local numY = quadX/self.pokerWidth
            table.insert(texs, math.max(0,numX));
            table.insert(texs, math.max(0,numY));
        end
    end

    local posBuffer = gl.createBuffer()
    gl.bindBuffer(gl.ARRAY_BUFFER, posBuffer)
    gl.bufferData(gl.ARRAY_BUFFER, table.getn(verts), verts, gl.STATIC_DRAW)
    gl.bindBuffer(gl.ARRAY_BUFFER, 0)
    self.posTexNum = table.getn(verts)/2

    local texBuffer = gl.createBuffer()
    gl.bindBuffer(gl.ARRAY_BUFFER, texBuffer)
    gl.bufferData(gl.ARRAY_BUFFER, table.getn(texs), texs, gl.STATIC_DRAW)
    gl.bindBuffer(gl.ARRAY_BUFFER, 0)
    return {posBuffer.buffer_id, texBuffer.buffer_id}
end

function RubCardLayer:remove()
    local function callBack()
        self:removeFromParent()
    end
    local callFunc = cc.CallFunc:create(callBack)
    local delay = cc.DelayTime:create(0.01)
    local sequence = cc.Sequence:create(delay, callFunc)
    self:runAction(sequence)
end

function RubCardLayer:__drawByMoveProgram(rotation)
    local glProgram = self.moveGlProgram
    local radiusVal = self.udRadiusVal
    if self.dirState == RubCardLayer_Dir_lr then
        glProgram = self.lTRGlProgram
        radiusVal = self.lrRadiusVal
    elseif self.dirState == RubCardLayer_Dir_rl then
        glProgram = self.rTLGlProgram
        radiusVal = self.lrRadiusVal
    end
    gl.enable(gl.CULL_FACE)
    glProgram:use()
    glProgram:setUniformsForBuiltins()

    local rotationLc = gl.getUniformLocation(glProgram:getProgram(), "rotation")
    glProgram:setUniformLocationF32(rotationLc, rotation)
    local ratio = gl.getUniformLocation(glProgram:getProgram(), "ratio")
    glProgram:setUniformLocationF32(ratio, self.ratioVal)
    local radius = gl.getUniformLocation(glProgram:getProgram(), "radius")
    glProgram:setUniformLocationF32(radius, radiusVal)
    local offx = gl.getUniformLocation(glProgram:getProgram(), "offx")
    glProgram:setUniformLocationF32(offx, self.offx)
    local offy = gl.getUniformLocation(glProgram:getProgram(), "offy")
    glProgram:setUniformLocationF32(offy, self.offy)
    local height = gl.getUniformLocation(glProgram:getProgram(), "height")
    glProgram:setUniformLocationF32(height, self.pokerHeight)
    local width = gl.getUniformLocation(glProgram:getProgram(), "width")
    glProgram:setUniformLocationF32(width, self.pokerWidth)
    gl.bindTexture(gl.TEXTURE_2D, self.backSpriteId);
    self:__drawArrays(glProgram.backBufferInfo[1], glProgram.backBufferInfo[2]);
    gl.bindTexture(gl.TEXTURE_2D, self.frontSpriteId);
    self:__drawArrays(glProgram.frontBufferInfo[1], glProgram.frontBufferInfo[2]);
    gl.disable(gl.CULL_FACE);
end

function RubCardLayer:__drawBySmoothProgram(rotation)
    local glProgram = self.smoothGlProgram
    local buffInfo = self.udFrontBufferInfo
    if self.dirState ~= RubCardLayer_Dir_du then
        glProgram = self.lTRSmoothGlProgram
        buffInfo = self.lrFrontBufferInfo
    end
    glProgram:use()
    glProgram:setUniformsForBuiltins()

    gl._bindTexture(gl.TEXTURE_2D, self.frontSpriteId)
    local rotationLc = gl.getUniformLocation(glProgram:getProgram(), "rotation")
    glProgram:setUniformLocationF32(rotationLc, rotation)
    local offx = gl.getUniformLocation(glProgram:getProgram(), "offx")
    glProgram:setUniformLocationF32(offx, self.offx)
    local offy = gl.getUniformLocation(glProgram:getProgram(), "offy")
    glProgram:setUniformLocationF32(offy, self.offy)
    local height = gl.getUniformLocation(glProgram:getProgram(), "height")
    glProgram:setUniformLocationF32(height, self.pokerHeight)
    local width = gl.getUniformLocation(glProgram:getProgram(), "width")
    glProgram:setUniformLocationF32(width, self.pokerWidth)
    self:__drawArrays(buffInfo[1],buffInfo[2])
end

function RubCardLayer:__drawByEndProgram()
    local glProgram = self.endGlProgram
    glProgram:use()
    glProgram:setUniformsForBuiltins()
    gl._bindTexture(gl.TEXTURE_2D, self.frontSpriteId)
    local offx = gl.getUniformLocation(glProgram:getProgram(), "offx")
    glProgram:setUniformLocationF32(offx, self.offx)
    local offy = gl.getUniformLocation(glProgram:getProgram(), "offy")
    glProgram:setUniformLocationF32(offy, self.offy)
    self:__drawArrays(self.udFrontBufferInfo[1], self.udFrontBufferInfo[2])
end

function RubCardLayer:__drawArrays(pos, tex)
    gl.glEnableVertexAttribs(bit._or(cc.VERTEX_ATTRIB_FLAG_TEX_COORDS, cc.VERTEX_ATTRIB_FLAG_POSITION))
    gl.bindBuffer(gl.ARRAY_BUFFER, pos)
    gl.vertexAttribPointer(cc.VERTEX_ATTRIB_POSITION,2,gl.FLOAT,false,0,0)
    gl.bindBuffer(gl.ARRAY_BUFFER, tex)
    gl.vertexAttribPointer(cc.VERTEX_ATTRIB_TEX_COORD,2,gl.FLOAT,false,0,0)
    gl.drawArrays(gl.TRIANGLES, 0, self.posTexNum)
    gl.bindBuffer(gl.ARRAY_BUFFER, 0)
end

function RubCardLayer:__registerTouchEvent()
    local function __deleteBuff(buffInfo)
        gl._deleteBuffer(buffInfo[1])
        gl._deleteBuffer(buffInfo[2])
    end
    local function onNodeEvent(event)
        if "exit" == event then
            __deleteBuff(self.udBackBufferInfo)
            __deleteBuff(self.udFrontBufferInfo)
            __deleteBuff(self.lrBackBufferInfo)
            __deleteBuff(self.lrFrontBufferInfo)
            self.moveGlProgram:release()
            self.lTRGlProgram:release()
            self.rTLGlProgram:release()
            self.smoothGlProgram:release()
            self.lTRSmoothGlProgram:release()
            self.endGlProgram:release()
            self.backSprite:release()
            self.frontSprite:release()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    local function touchBegin(touch, event)
        local location = touch:getLocation()
        if location.x > self.touchStartLRX and location.x < self.touchStartRLX and location.y > (self.touchStartY - 50) and location.y < (self.touchStartY + 120) then
            self.dirState = RubCardLayer_Dir_du
        elseif location.y > self.touchStartY and location.y < (self.touchStartY+self.pokerHeight) and location.x > (self.touchStartLRX - 50) and location.x < (self.touchStartLRX + 120) then
            self.dirState = RubCardLayer_Dir_lr
        elseif location.y > self.touchStartY and location.y < (self.touchStartY+self.pokerHeight) and location.x > (self.touchStartRLX - 120) and location.x < (self.touchStartRLX + 50) then
            self.dirState = RubCardLayer_Dir_rl
        else
            self.dirState = RubCardLayer_Dir_No
        end
        return true
    end
    local function touchMove(touch, event)
        local location = touch:getLocation()
        if self.dirState == RubCardLayer_Dir_du then
            self.ratioVal = (location.y-self.touchStartY)/self.pokerHeight;
        elseif self.dirState == RubCardLayer_Dir_lr then
            self.ratioVal = (location.x-self.touchStartLRX)/self.pokerWidth;
        elseif self.dirState == RubCardLayer_Dir_rl then
            self.ratioVal = (self.touchStartRLX-location.x)/self.pokerWidth;
        end
        self.ratioVal = math.max(0, self.ratioVal);
        self.ratioVal = math.min(1, self.ratioVal);
        return true
    end
    local function touchEnd(touch, event)
        if self.ratioVal >= 0.9 then
            self.state = RubCardLayer_State_Smooth
        else
            self.ratioVal = 0
            self.dirState = RubCardLayer_Dir_du
        end
        return true
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(touchBegin, cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(touchMove, cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(touchEnd, cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

return RubCardLayer
