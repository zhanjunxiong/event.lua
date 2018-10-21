local util = require "util"
local model = require "model"
local object = import "module.object"
local sceneConst = import "module.scene.scene_const"

cAICharactor = object.cObject:inherit("aiCharactor")


function cAICharactor:ctor(sceneObj)
	self.owner = sceneObj
	self.userAmount = 0
end

function cAICharactor:onCreate()
end

function cAICharactor:onDestroy()

end

function cAICharactor:searchEnemy()
	local enemyList = self.owner:getViewer(sceneConst.eSCENEOBJ_TYPE.FIGHTER)
	if not next(enemyList) then
		return
	end

	local pos = self.owner.pos
	local minDt
	local enemyUid
	for _,enemy in pairs(enemyList) do
		local dt = util.dot2dot(pos[1],pos[2],enemy.pos)
		if not minDt or minDt > dt then
			minDt = dt
			enemyUid = enemy.uid
		end
	end

	return enemyUid
end

function cAICharactor:haveEnemy()
	return self.userAmount ~= 0
end

function cAICharactor:randomPatrolPos()
	local bornPos = self.owner.bornPos
	return util.random_in_circle(bornPos[1],bornPos[2], self.owner.patrolRange)
end

function cAICharactor:moveToTarget(targetUid)

	local targetObj = model.fetch_fighter_with_uid(targetUid)

	local angle = targetObj:getAngleFrom(self.owner)

	local fx, fz = util.move_torward(targetObj.pos[1], targetObj.pos[2], angle, 10)

	local path = {}
	table.insert(path,{self.owner.pos[1],self.owner.pos[2]})
	table.insert(path,{fx,fz})

	local moveCtrl = self.owner.moveCtrl
	if not moveCtrl:onServerMoveStart(path) then
		return false
	end
	return true
end

function cAICharactor:moveToPos(pos)
	local path = {}
	table.insert(path,{self.owner.pos[1],self.owner.pos[2]})
	table.insert(path,{pos[1],pos[2]})

	local moveCtrl = self.owner.moveCtrl
	if not moveCtrl:onServerMoveStart(path) then
		return false
	end
	return true
end

function cAICharactor:canAttack(targetObj)

end

function cAICharactor:isOutOfRange()
	if util.dot2dot(self.owner.pos[1],self.owner.pos[2],self.owner.bornPos[1],self.owner.bornPos[2]) >= 100 then
		return true
	end
	return false
end

function cAICharactor:onUserEnter(sceneObj)
	self.userAmount = self.userAmount + 1
end

function cAICharactor:onUserLeave(sceneObj)
	self.userAmount = self.userAmount - 1
end