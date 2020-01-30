local C = class("HhdzJumpAnimView")

function C:ctor()
    self:reset()
end

function C:reset()
    -- 最小的动画单元集合
    self.anims = {}
end

-- 最小的单体动画和时间
function C:addOneUnitAction(target, anim, time, callback)

    local index = #self.anims + 1
    local anim = transition.sequence({
        anim,
        CCCallFunc:create(function()
            if callback then
                callback()
            end
        end)
    });

    assert(target, "error: target is nil")
    table.insert(self.anims, {target=target, anim=anim, time=time})
end

-- 第一个参数是调用createFrameAnim的函数，注意是函数，不是返回的sprite，而且注意函数里面应该是once，这样才会自己移除
-- 形如： local createAnimFunc = function() local sprite = UITools.createFrameAnim(params), layer:addChild(sprite) end 
function C:addOneUnitFrameAnim(createAnimFunc, time)
    -- cool: 插入到ccdelay 的callback里，这样后面的action才能seq起来
    local frame = transition.sequence({
        CCDelayTime:create(0.1),
        CCCallFunc:create(createAnimFunc)
    });
    local seq = transition.sequence({
        frame, 
        CCDelayTime:create(time),
        nil})

    table.insert(self.anims, {target=display.newSprite(), anim=seq, time=time})
end

function C:createFinAnim(anims)
    local res
    for i = 1, #anims do
        local v = anims[i]
        local target, anim = v.target, v.anim
            if target then
                target:setVisible(true)
                -- 加速模拟马上完成， 而且，在前面的必须先完成，这里通过i来提高加速倍速模拟先完成
                local anim = CCSpeed:create(anim, 10*(#anims-i+1))
                target:runAction(anim)
            end
    end
    return res
end

-- 使用delay
function C:createUnfinAnim(anims)
    local res
    local delayTime = 0
    for i = 1, #anims do
        local v = anims[i]
        local target, anim = v.target, v.anim
        
        if i == 1 then
            -- print("unfin anim start " .. tostring(i))
            target:setVisible(true)
            target:runAction(anim)
        else
            local seq = transition.sequence({CCDelayTime:create(delayTime), CCCallFunc:create(function() target:setVisible(true) end)})
            anim = transition.sequence({seq, anim, CCCallFunc:create(function() end )})
            target:runAction(anim)
        end

        delayTime = delayTime + v.time
    end 


    return res
end

-- 核心接口
function C:jumpAt(curTime)
    local finishedAnim, unfinishedAnim = self:sliceAnims(curTime)
    print("finishedAnim len " .. tostring(#finishedAnim) .. ", unfinishedAnim len " .. tostring(#unfinishedAnim))
    self:createFinAnim(finishedAnim)
    self:createUnfinAnim(unfinishedAnim)
end

function C:sliceAnims(curTime)
    local finishedAnim = {}
    local unfinishedAnim = {}
    local finishedTime = 0

    -- 因为是严格按照turns / unit来执行动画的只要累加到时间等于这个time值即可
    for _, v in ipairs(self.anims) do
        local anim, time = v.anim, v.time
        if finishedTime < curTime then
            finishedTime = finishedTime + time
            -- 注意，插入的都是引用，所以不能在这里改值，比如时间
            table.insert(finishedAnim, v)
        else
            table.insert(unfinishedAnim, v)
        end
    end
    return finishedAnim, unfinishedAnim
end

function C:getCompleteTime()
    local time = 0
    for k, v in pairs(self.anims) do
        time = time + v.time
    end
    return time 
end

return C













