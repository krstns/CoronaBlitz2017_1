--
-- Created by IntelliJ IDEA.
-- User: krystian
-- Date: 07/04/17
-- Time: 19:52
--

local M = {}

local math = math

M.create = function(speed, directionDuration)
    local speed = speed or 120 --pts per second
    local directionDuration = directionDuration or 5000 -- how long in 1 direction

    -- create enemy animations from a sprite
    local sheetOptions = {
        width = 32,
        height = 32,
        numFrames = 12,
    }
    local enemy = graphics.newImageSheet("enemy.png", sheetOptions)

    -- walk animations
    local enemy_walk = {
        {
            name = "down",
            start = 1,
            count = 3,
            time = 300,
            loopCount = 0,
            loopDirection = "bounce"
        },
        {
            name = "left",
            start = 4,
            count = 3,
            time = 300,
            loopCount = 0,
            loopDirection = "bounce"
        },
        {
            name = "right",
            start = 7,
            count = 3,
            time = 300,
            loopCount = 0,
            loopDirection = "bounce"
        },
        {
            name = "up",
            start = 10,
            count = 3,
            time = 300,
            loopCount = 0,
            loopDirection = "bounce"
        }
    }

    -- initial values
    local direction = "right"
    local isPlaying = false

    local enemy = display.newSprite(enemy, enemy_walk)
    enemy:scale(3, 3)
    enemy:setSequence(direction)
    enemy.objectName = "enemy"


    -- add physics to enemy
    physics.addBody(enemy, {
        box= {
            halfWidth = enemy.contentWidth * 0.25,
            halfHeight = enemy.contentHeight * 0.2,
            y = enemy.contentHeight * 0.3,
            x = 0
        },
        isSensor = true
    })

    --
    -- Enemy functions
    --

    -- enemy movement, called by joystick
    enemy.move = function(x, y)
        if x == 0 and y == 0 then
            -- joystick was deactivated, stop enemy
            enemy:setLinearVelocity(0, 0)
            enemy:pause()
            return
        end

        local xdirection = x > 0 and "right" or "left"
        local ydirection = y > 0 and "down" or "up"

        local newDirection = math.abs(x) > math.abs(y) and xdirection or ydirection
        if (newDirection ~= direction) then
            direction = newDirection
            enemy:setSequence(direction)
            enemy:play()
        elseif not isPlaying then
            -- if the enemyation was idle, start it
            enemy:play()
        end

        enemy:setLinearVelocity(x, y)
    end

    --
    -- patrol ability
    --
    local lastDirectionChange = system.getTimer() - directionDuration
    local changeX = 0
    local changeY = 0
    enemy.enterFrame = function()
        if (not enemy.parent) then
            -- game finished, remove listener
            Runtime:removeEventListener("enterFrame", enemy)
            return
        end

        -- check if direction needs to change
        if (system.getTimer() - lastDirectionChange > directionDuration) then
            local angle = math.random(360)
            local length = (directionDuration / 1000) * speed
            changeX = (enemy.x + length * math.cos(math.rad(angle))) / (directionDuration / 1000) / 60
            changeY = (enemy.y + length * math.sin(math.rad(angle))) / (directionDuration / 1000) / 60
            lastDirectionChange = system.getTimer()
        end

        enemy.move(changeY, changeY)

    end
    Runtime:addEventListener("enterFrame", enemy)


    return enemy
end


return M