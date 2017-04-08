display.setStatusBar(display.HiddenStatusBar)

local stage = display:getCurrentStage()
local math = math

-- some factories
local timeBarFactory = require("timeBar")
local characterFactory = require("character")
local enemyFactory = require("enemy")
local targetFactory = require("target")
local backgroundFactory = require("background")


-- some settings
local cameraBorder = display.contentWidth * 0.2
local initialEnemies = 20
local newEnemiesSpawn = 3
local bgWidth = display.contentWidth * 5
local bgHeight = display.contentHeight * 3
local decreaseTargetsTime = 20000 -- time after which we will decrease the target number
local initialTargets = 30
local minTargets = 5
local targetTimeExtension = 6000

-- setup physics
local physics = require("physics")
physics.start()
--physics.setDrawMode("hybrid")
physics.setGravity(0, 0)
physics.pause()

--
-- setup joystick
--
local factory = require("controller.virtual_controller_factory")
local controller = factory:newController()

local js1
local character

local function setupController(displayGroup)
    local js1Properties = {
        nToCRatio = 0.5,
        radius = 60,
        x = display.contentWidth - 200,
        y = display.contentHeight - 100,
        restingXValue = 0,
        restingYValue = 0,
        rangeX = 200,
        rangeY = 200,
        touchHandler = {
            onTouch = function(joystick, x, y)
                if character then
                    character.move(joystick, x, y)
                end
            end
        }
    }

    local js1Name = "js1"
    js1 = controller:addJoystick(js1Name, js1Properties)

    controller:displayController(displayGroup)
end

-- level group
local level = display.newGroup()


--
-- create gui layer
--
local gui = display.newGroup()
local timeBar = timeBarFactory.create(gui)
timeBar.x, timeBar.y = display.contentWidth * 0.5, 30
gui.isVisible = false

--
-- Setup background
--
local bg = backgroundFactory.create(bgWidth, bgHeight)
level:insert(bg)


--
-- initialize joystick
--
setupController(gui)


local targets = display.newGroup()
level:insert(targets)

local enemies = display.newGroup()
level:insert(enemies)


local function newGame()
    physics.start()

    timer.performWithDelay(100, function()

        --
        -- Setup character
        --
        character = characterFactory.create()
        level:insert(character)

        character.collision = function(self, event)
            if (event.phase ~= "began") then
                return
            end

            local collisionType = event.other.objectName
            print("collision began with " .. event.other.objectName)

            if (collisionType == "target_fire" or collisionType == "target_ice") then
                event.other:removeSelf()
                timeBar.addTime(targetTimeExtension)

            elseif (collisionType == "enemy") then
                Runtime:dispatchEvent({
                    name = "gameOver"
                })
            end
        end
        character:addEventListener("collision")

        --
        -- Setup targets
        --
        for i = 1, initialTargets do
            local target = targetFactory.create("ice")
            target.x = math.random(-bgWidth * 0.3, bgWidth * 0.3)
            target.y = math.random(-bgHeight * 0.3, bgHeight * 0.3)
            targets:insert(target)
        end


        --
        -- Setup enemies
        --
        for i = 1, initialEnemies do
            local enemy = enemyFactory.create()
            enemy.x = math.random(-bgWidth * 0.3, bgWidth * 0.3)
            enemy.y = math.random(-bgHeight * 0.3, bgHeight * 0.3)
            enemies:insert(enemy)
        end

        -- start timer
        timeBar.newGame()
    end)
end


--
-- Setup fog of war
--
local fowMask = graphics.newMask("fow_mask.png")
level:setMask(fowMask)
level.maskScaleX = 3
level.maskScaleY = 3

--
-- Setup camera to follow character when it is close to the edge of the screen
--
Runtime:addEventListener("enterFrame", function()
    if character then
        local charX = stage.x + character.x
        local charY = stage.y + character.y

        if (charX < cameraBorder) then
            stage.x = stage.x + cameraBorder - charX
        elseif (charX > display.contentWidth - cameraBorder) then
            stage.x = stage.x - charX + display.contentWidth - cameraBorder
        end

        if (charY < cameraBorder) then
            stage.y = stage.y + cameraBorder - charY
        elseif (charY > display.contentHeight - cameraBorder) then
            stage.y = stage.y - charY + display.contentHeight - cameraBorder
        end

        -- position fow mask over character
        level.maskX = character.x
        level.maskY = character.y
    else
        level.maskX = -500
        level.maskY = -500
    end

    -- make sure GUI is always positioned right
    gui.x = stage.x * -1
    gui.y = stage.y * -1
end)

Runtime:addEventListener("spawnEnemy", function()
    for i = 1, newEnemiesSpawn do
        local enemy = enemyFactory.create()
        enemy.x = math.random(-bgWidth * 0.45, bgWidth * 0.45)
        enemy.y = math.random(-bgHeight * 0.45, bgHeight * 0.45)
        level:insert(enemy)
    end
end)

Runtime:addEventListener("spawnTarget", function()
    local numberOfTargets = initialTargets - math.floor(system.getTimer() / decreaseTargetsTime)
    if (numberOfTargets > targets.numChildren) then
        for i = targets.numChildren, numberOfTargets do
            local target = targetFactory.create("fire")
            target.x = math.random(-bgWidth * 0.45, bgWidth * 0.45)
            target.y = math.random(-bgHeight * 0.45, bgHeight * 0.45)
            level:insert(target)
        end
    end
end)

--
-- Start game button
--

local startGameButton = display.newText("NEW GAME", display.contentWidth * 0.5, display.contentHeight * 0.5 - 200, native.systemFont, 64)
startGameButton:addEventListener("tap", function()
    gui.isVisible = true

    timer.performWithDelay(100, function()
        newGame()
        startGameButton:removeSelf()
        startGameButton = nil
    end)
end)

--
-- Game Over screen
--
local function showGameOverScreen()
    local gos = display.newGroup()
    local gameOverScreen = display.newRect(gos, display.contentWidth * 0.5, display.contentHeight * 0.5, 400, 400)
    local gameOverText = display.newText(gos, "You scored " .. timeBar.getScore(), display.contentWidth * 0.5, display.contentHeight * 0.4, native.systemFont, 40)
    gameOverText:setTextColor(0, 0, 0)

    local newGameText = display.newText(gos, "NEW GAME", display.contentWidth * 0.5, display.contentHeight * 0.65, native.systemFont, 40)
    newGameText:addEventListener("tap", function()
        timer.performWithDelay(100, function()
            gos:removeSelf()
            gos = nil
            newGame()
        end)
    end)
    newGameText:setTextColor(0, 0, 0)

end

--
-- Game over listener
--

Runtime:addEventListener("gameOver", function(event)
    print("GAME OVER!")
    physics.pause()


    character:removeSelf()
    character = nil

    stage.x, stage.y = 0, 0


    timer.performWithDelay(100, function()
        showGameOverScreen()


        for i = enemies.numChildren, 1, -1 do
            display.remove(enemies[i])
        end

        for i = targets.numChildren, 1, -1 do
            display.remove(targets[i])
        end
    end)
end)

