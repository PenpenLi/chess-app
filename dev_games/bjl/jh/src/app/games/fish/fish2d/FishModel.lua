-- region FisModel.lua
-- Date
-- 单个鱼的数据结构
-- 此文件由[BabeLua]插件自动生成

local FisModel = class("FisModel", { })

function FisModel:ctor()
    self.id_ = 0
    self.live_ = 1
    self.type_ = 0  --类型
    self.item_ = 0  --特效 如果是闪电鱼 红鱼 此项代表鱼类型
    self.rotation_ = 0
    self.size_ = { width = 0, height = 0 }
    self.position_ = cc.p(-400, 0)

    self.path_id_ = 0  --路径id
    self.path_type_ = 0  --路径类型
    self.path_delay_ = 0  --路径延长
    self.path_offset_ = cc.p(0,0)
    self.elapsed_ = 0

    self.speed_ = 1
    self.move_action_id_ = 0

    self.node_ = null
    self.shadow_ = null
    self.effect_ = null
end

return FisModel
-- endregion
