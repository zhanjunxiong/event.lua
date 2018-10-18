local event = require "event"
local mongo = require "mongo"
local model = require "model"
local helper = require "helper"
local idBuilder = import "module.id_builder"
local startup = import "server.startup"
local clientMgr = import "module.client_manager"
local fighter = import "module.scene.fighter"
local monster = import "module.scene.monster"
local sceneServer = import "module.scene.scene_server"
local itemFactory = import "module.agent.item.item_factory"
local itemContainer = import "module.agent.item.item_container"
local worldServer = import "module.world.world_server"
local scene = import "module.scene.scene"
local skillAPI = import "module.scene.skill.skill_api"
local bullet = import "module.scene.bullet"
-- sceneServer:createScene(1001,1)

-- local userData = table.tostring({uid = 1,pos = {1,1}})
-- sceneServer:enterScene(userData,1,{1,1},false) 

-- local scene = sceneServer:getScene(1)

-- for i = 1,1 do
-- 	local inst = monster.cMonster:new(2,1,1)
-- 	scene:enter(inst,1,1)
-- end
--

local mongodb_channel = mongo:inherit()
function mongodb_channel:disconnect()
	os.exit(1)
end

local db_channel,reason = event.connect(env.mongodb,4,true,mongodb_channel)
if not db_channel then
	print(string.format("%s connect db:%s faield:%s",env.name,env.mongodb,reason))
	os.exit()
end


event.fork(function ()
	env.distId = 1
	startup.run(1,env.distId,false,env.mongodb)
	idBuilder:init(env.serverId,1)
	local container = itemContainer.cItemContainer:load(nil,db_channel,"user",{userUid = 5})
	if not container then
		container = itemContainer.cItemContainer:new()
	end

	-- container:insertItemByCid(100,1)
	-- container:deleteItemByCid(100,5)
	-- container:insertItemByCid(1000,1)
	-- container:insertItemByCid(2000,1)
	container:save(db_channel,"user",{userUid = 5})
	-- table.print(container)

	worldServer:enter(1,1)
	worldServer:leave(1)

	local sceneInst = scene.cScene:new()
	sceneInst:onCreate(1001,1)
	local monsterObj0 = sceneInst:spawnMonster(1,{100,100},{1,0})
	
	local monsterObj = sceneInst:spawnMonster(1,{100,100},{1,0})

	-- monsterObj.moveCtrl:onServerMoveStart({{monsterObj.pos[1],monsterObj.pos[2]},{200,200},{220,200}})

	-- skillAPI:useSkill(monsterObj,1)

	for i = 1,1024 * 10 do
		local bulletObj = bullet.cBullet:new()
		bulletObj:onCreate(1,{math.random(1,1000),math.random(1,1000)},50,monsterObj0)

		bulletObj:setLockTarget(monsterObj)
		bulletObj:enterScene(sceneInst,math.random(1,1000),math.random(1,1000))
	end

	while true do
		event.sleep(2)
		print(collectgarbage("collect"))
		helper.free()
		print(collectgarbage("count"),helper.allocated() / 1024)
		class.countObject("bullet")

	end
end)

