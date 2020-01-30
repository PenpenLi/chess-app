--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
--对象池

local ObjectPool = class("ObjectPool")

function ObjectPool:ctor(createFunction,name)
  self.pools = {}
--  self.poolsUsing = {}

  self.CreateFunction = createFunction
  self.name = name
end

function ObjectPool:createObject()
   local object = nil
   local poolNum = #self.pools
   if poolNum > 25 then
       self:clearObject(10)
   end
--   print("ObjectPool:createObject poolNum: ",poolNum,self.name)
   if poolNum > 0 then
       object = table.remove(self.pools)
   end
   if object == nil then
       object = self.CreateFunction()
       object:retain()
   end
--   if object ~= nil then
--       table.insert(self.poolsUsing,object)
--   end
   object:setVisible(true)
   --
   object.pool = self
   object.recycleToPool = function ()
       self:destroyObject(object)
   end

   return object
end

function ObjectPool:destroyObject(object)
   if object == nil then
       return
   end
  -- print("ObjectPool:destroyObject name: ",self.name)
--   table.removebyvalue(self.poolsUsing,object,false)

   table.insert(self.pools,object)
   object:stopAllActions()
   object:removeFromParent(false)
   object:setVisible(false)
end

function ObjectPool:clearObject(retainCount)
    local num = #self.pools
    print("ObjectPool:clearObject name, num: ",self.name,num)
    if num <= retainCount then
        return
    end
    for i=retainCount,num do
       local object = table.remove(self.pools)
       if object then
           object:release()
       end
    end  
end

return ObjectPool

--endregion
