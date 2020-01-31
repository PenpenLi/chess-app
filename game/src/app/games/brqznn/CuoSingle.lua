--搓牌单张
-- 顶点着色器
local strVertSource = 
[[
attribute vec4 a_position;
attribute vec2 a_texCoord;
attribute vec4 a_color;

uniform float ratio; 
uniform float radius; 
uniform float width;
uniform float finish; 

uniform float offx;
uniform float offy;

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

void main()
{
	
	vec4 tmp_pos = a_position;
	
	tmp_pos = vec4(tmp_pos.x, -tmp_pos.y, tmp_pos.z, tmp_pos.w);

	if(finish > 0.0) {
		tmp_pos = vec4(tmp_pos.x,-width - tmp_pos.y, tmp_pos.z, tmp_pos.w);     
	}else {		
		float halfPeri = radius *3.1415; 
		float hr = halfPeri*ratio ;
        float dis=-width+hr; 
		if(tmp_pos.y < dis) {
			float dy = -tmp_pos.y+dis;
			float arc = dy/radius;
			tmp_pos.y = dis - sin(arc)*radius;
			tmp_pos.z = radius * (1.0-cos(arc))*0.5; 
		}
	}
	
	tmp_pos += vec4(offx, offy, 0.0, 0.0);

	gl_Position = CC_MVPMatrix * tmp_pos;
	v_fragmentColor = a_color;
	v_texCoord = a_texCoord;
}
]]
--tmp_pos = vec4(tmp_pos.y, -tmp_pos.x, tmp_pos.z, tmp_pos.w);
-- 片段着色器
local strFragSource = 
[[
    varying vec4 v_fragmentColor;
    varying vec2 v_texCoord;

    void main()
    {
        gl_FragColor = texture2D(CC_Texture0, v_texCoord);
    }
]]

local GameOxCuoSingle =class("GameOxCuoSingle")

function GameOxCuoSingle:ctor(node)

    self.node=node

    self.hasCuo=false

    -- 先存储纹理到本地，不知道为什么直接获取不到 pp:newImage(); 
    -- local node1 = cc.Node:create()
    -- local front =display.newSprite("common/images/card_bg.png")
    -- front:getTexture():setAntiAliasTexParameters()
    -- node1:setPosition(80,90)
    -- node1:addChild(front)
    -- node1:setCascadeOpacityEnabled(true)
    -- local pp = cc.RenderTexture:create(456, 694, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888);
    -- pp:begin();
    -- node1:visit();
    -- pp:endToLua();
    -- local writablePath = cc.FileUtils:getInstance():getWritablePath()
    -- pp:saveToFile(writablePath..'oxcuopai.png', cc.IMAGE_FORMAT_PNG)

    local arr = {}
    arr[1]=cc.DelayTime:create(0.1)
    arr[2]=cc.CallFunc:create(function()
        self:init()
    end)
    self.node:runAction(cc.Sequence:create(arr))
end


-- 通过图片取得纹理id bol=正面
function GameOxCuoSingle:getTextureAndRange(bol)
    local director = cc.Director:getInstance()
    local textureCache = director:getTextureCache()

    if bol then     
        --local writablePath =cc.FileUtils:getInstance():getWritablePath()
        local temp = textureCache:addImage(GAME_BRQZNN_IMAGES_RES.."beimian_3.png")
        local id = temp:getName()
        local rect = temp:getContentSize()
        local ll, rr, tt, bb = 0, 1, 0, 1
        return id, { ll, rr, tt, bb }, { rect.width, rect.height }
    end
        
    local temp = textureCache:addImage(GAME_BRQZNN_IMAGES_RES.."bg_back.png")
    local id = temp:getName()
    local rect = temp:getContentSize()
	local ll, rr, tt, bb = 0, 1, 0, 1
    return id, { ll, rr, tt, bb }, { rect.width, rect.height }
end

-- 创建3D牌面，所需的顶点和纹理数据, size:宽高, texRange:纹理范围, bFront:是否正面
function GameOxCuoSingle:initCardVertex(size, texRange, bFront)
	local nDiv = 100 --将宽分成100份
	
	local verts = {} --位置坐标
	local texs = {} --纹理坐标
	local dh = size.height
	local dw = size.width/nDiv
    
	--计算顶点位置
	for c = 1, nDiv do 
		local x, y = (c-1)*dw, 0
		local quad = {}
		if bFront then
			quad = {x, y, x+dw, y, x, y+dh, x+dw, y, x+dw, y+dh, x, y+dh}
		else
			quad = {x, y, x, y+dh, x+dw, y, x+dw, y, x, y+dh, x+dw, y+dh}
		end
		for _, v in ipairs(quad) do table.insert(verts, v) end
	end

	local bXTex = true --是否当前在计算横坐标纹理坐标，
	for _, v in ipairs(verts) do 
		if bXTex then
			if bFront then
				table.insert(texs, v/size.width * (texRange[2] - texRange[1]) + texRange[1])
			else
				table.insert(texs, v/size.width * (texRange[1] - texRange[2]) + texRange[2])
			end
		else
			if bFront then
				table.insert(texs, (1-v/size.height) * (texRange[4] - texRange[3]) + texRange[3])
			else
				table.insert(texs, v/size.height * (texRange[3] - texRange[4]) + texRange[4])
			end
		end
		bXTex = not bXTex
	end

	local res = {}
	local tmp = {verts, texs}
	for _, v in ipairs(tmp) do 
		local buffid = gl.createBuffer()
		gl.bindBuffer(gl.ARRAY_BUFFER, buffid)
		gl.bufferData(gl.ARRAY_BUFFER, table.getn(v), v, gl.STATIC_DRAW)
		gl.bindBuffer(gl.ARRAY_BUFFER, 0)
		table.insert(res, buffid)
	end
	return res, #verts
end

-- 创建搓牌效果层
function GameOxCuoSingle:init()
	local scale =1.0
    
	-- 取得屏幕宽高
	local Director = cc.Director:getInstance()
	local WinSize = Director:getWinSize()

	-- 创建广角60度，视口宽高比是屏幕宽高比，近平面1.0，远平面1000.0，的视景体
	local camera = cc.Camera:createPerspective(45, WinSize.width/WinSize.height, 1, 1000)
	camera:setCameraFlag(cc.CameraFlag.USER2)
	--设置摄像机的绘制顺序，越大的深度越绘制的靠上，所以默认摄像机默认是0，其他摄像机默认是1, 这句很重要！！
	camera:setDepth(1)
	camera:setPosition3D(cc.vec3(0, 0, 10))
	camera:lookAt(cc.vec3(0, 0, 0), cc.vec3(0, 1, 0))
	-- 创建用于OpenGL绘制的节点
	local glNode = gl.glNodeCreate()
	local glProgram = cc.GLProgram:createWithByteArrays(strVertSource, strFragSource)    
	glProgram:retain()
	glProgram:updateUniforms()
    self.glNode=glNode

	-- 创建搓牌图层
	local layer = cc.Layer:create()
	layer:setCameraMask(cc.CameraFlag.USER2)
	layer:addChild(glNode)
	layer:addChild(camera)
    self.node:addChild(layer)
	-- 退出时，释放glProgram程序
	local function onNodeEvent(event)
		if "exit" == event then
			glProgram:release()
		end
	end
	layer:registerScriptHandler(onNodeEvent)

	local posNow = cc.p(0, 0)
 	--创建触摸回调
	local function touchBegin(touch, event)
		posNow = touch:getLocation()
        if self.hasCuo then return false end

		return true
	end
	local function touchMove(touch, event)
		local location = touch:getLocation()
		local dy = location.y - posNow.y
        --修改搓牌灵敏度
		self.ratioVal = cc.clampf(self.ratioVal + dy/150.0, 0.0, 111.9) --最大程度默认0.9
       
		posNow = location
		return true
	end
	local function touchEnd(touch, event)
        if self.ratioVal<=1.56 then
            self:autoClose()
        end
		return true
	end
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(touchBegin, cc.Handler.EVENT_TOUCH_BEGAN )
	listener:registerScriptHandler(touchMove, cc.Handler.EVENT_TOUCH_MOVED )
	listener:registerScriptHandler(touchEnd, cc.Handler.EVENT_TOUCH_ENDED )
	local eventDispatcher = layer:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)
     --游戏主循环
    local scheduler = cc.Director:getInstance():getScheduler()  
	self.schedulerID = scheduler:scheduleScriptFunc(function()
			self:update()
		end,0.016,false) 

	--创建牌的背面
	local id1, texRange1, sz1 = self:getTextureAndRange(false)
	local msh1, nVerts1 = self:initCardVertex(cc.size(sz1[1] * scale, sz1[2] * scale), texRange1, true)
	--创建牌的正面
	local id2, texRange2, sz2 = self:getTextureAndRange(true)
	local msh2, nVerts2 = self:initCardVertex(cc.size(sz2[1] * scale, sz2[2] * scale), texRange2, false)

	--搓牌的程度控制， 搓牌类似于通过一个圆柱滚动将牌粘着起来的效果。下面的参数就是滚动程度和圆柱半径
	self.ratioVal = 0.0
	self.radiusVal = sz1[1]*scale/math.pi*0.5;

	--牌的渲染信息 
	local cardMesh = {{id1, msh1, nVerts1}, {id2, msh2, nVerts2}}
	-- OpenGL绘制函数
	local function draw(transform, transformUpdated)
		gl.enable(gl.CULL_FACE)
		glProgram:use()
		glProgram:setUniformsForBuiltins()

		for _, v in ipairs(cardMesh) do 
			gl._bindTexture(gl.TEXTURE_2D, v[1])

			-- 传入搓牌程度到着色器中，进行位置计算
			local ratio = gl.getUniformLocation(glProgram:getProgram(), "ratio")
			glProgram:setUniformLocationF32(ratio, self.ratioVal)
			local radius = gl.getUniformLocation(glProgram:getProgram(), "radius")
           
             glProgram:setUniformLocationF32(radius, self.radiusVal)
            

			-- 偏移牌，使得居中
			local offx = gl.getUniformLocation(glProgram:getProgram(), "offx")
			glProgram:setUniformLocationF32(offx, WinSize.width/2 - sz1[2]/2*scale)

			local offy = gl.getUniformLocation(glProgram:getProgram(), "offy")
			
            if self.ratioVal>1.7 and not self.hasCuo then
                local finish = gl.getUniformLocation(glProgram:getProgram(), "finish")
                glProgram:setUniformLocationF32(finish, 1.0)
                self:onCuoFinished()
            end

           
            glProgram:setUniformLocationF32(offy, WinSize.height/2-50 + sz1[1]/2*scale)
            

			local width = gl.getUniformLocation(glProgram:getProgram(), "width")
			glProgram:setUniformLocationF32(width, sz1[1]*scale)

			-- local height = gl.getUniformLocation(glProgram:getProgram(), "height")
			-- glProgram:setUniformLocationF32(height, sz1[1]*scale)

			gl.glEnableVertexAttribs(bit._or(cc.VERTEX_ATTRIB_FLAG_TEX_COORDS, cc.VERTEX_ATTRIB_FLAG_POSITION))
			gl.bindBuffer(gl.ARRAY_BUFFER, v[2][1])
			gl.vertexAttribPointer(cc.VERTEX_ATTRIB_POSITION,2,gl.FLOAT,false,0,0)
			gl.bindBuffer(gl.ARRAY_BUFFER, v[2][2])
			gl.vertexAttribPointer(cc.VERTEX_ATTRIB_TEX_COORD,2,gl.FLOAT,false,0,0)
			gl.drawArrays(gl.TRIANGLES, 0, 800)
			gl.bindBuffer(gl.ARRAY_BUFFER, 0)
		end
	end
    glNode:registerScriptDrawHandler(draw)
end

local autoClose=false
function GameOxCuoSingle.autoClose()
    autoClose=true
end

function GameOxCuoSingle:onCuoFinished()
    self.hasCuo=true
    printInfo(">>>>>>>>>>>>onCuoFinished>>>>>>>>>>>>")
end

function GameOxCuoSingle:update() 
   if autoClose then
        self.ratioVal=self.ratioVal-0.04
        if self.ratioVal<0 then
            self.ratioVal=0
            autoClose=false
        end
   end
end

return GameOxCuoSingle