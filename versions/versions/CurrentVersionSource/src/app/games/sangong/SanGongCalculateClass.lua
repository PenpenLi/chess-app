local C = class("SanGongCalculateClass")

C.node = nil
C.numberLabel1 = nil
C.numberLabel2 = nil
C.numberLabel3 = nil
C.sumLabel = nil
C.sum = 0

function C:ctor( node )
	self.node = node
	self:initUI()
end

function C:initUI()
	if self.node == nil then
		return
	end
	self.numberLabel1 = self.node:getChildByName("label_1")
	self.numberLabel2 = self.node:getChildByName("label_2")
	self.numberLabel3 = self.node:getChildByName("label_3")
	self.sumLabel = self.node:getChildByName("sum_label")
end

function C:setVisible( visible )
	self.node:setVisible( visible )
	self.numberLabel1:setString("")
	self.numberLabel2:setString("")
	self.numberLabel3:setString("")
	self.sumLabel:setString("")
	self.sum = 0
end

function C:addNumber( num )
	self.sum = self.sum + num
	self.numberLabel3:setString( self.numberLabel2:getString() )
	self.numberLabel2:setString( self.numberLabel1:getString() )
	self.numberLabel1:setString( tostring(num) )
	self.sumLabel:setString( tostring(self.sum) )
end

function C:setNumber( num1, num2, num3 )
	self.numberLabel1:setString("")
	self.numberLabel2:setString("")
	self.numberLabel3:setString("")
	self.sumLabel:setString("")
	self.sum = 0
	if num1 and num1 > 0 then
		self.sum = self.sum + num1
		self.numberLabel1:setString(tostring(num1))
	end
	if num2 and num2 > 0 then
		self.sum = self.sum + num2
		self.numberLabel2:setString(tostring(num2))
	end
	if num3 and num3 > 0 then
		self.sum = self.sum + num3
		self.numberLabel3:setString(tostring(num3))
	end
	if self.sum ~= 0 then
		self.sumLabel:setString(tostring(self.sum))
	end
end

return C