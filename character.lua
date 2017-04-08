--
-- Created by IntelliJ IDEA.
-- User: krystian
-- Date: 07/04/17
-- Time: 19:48
--

local M = {}

local math = math

M.create = function()
    -- create character animations from a sprite
    local sheetOptions = {
        width = 32,
        height = 32,
        numFrames = 12,
    }
    local character = graphics.newImageSheet("character.png", sheetOptions)

    -- walk animations
    local character_walk = {
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

    local character = display.newSprite(character, character_walk)
    character:scale(3, 3)
    character.x, character.y = display.contentWidth * 0.5, display.contentHeight * 0.5
    character:setSequence(direction)
    character.objectName = "character"



    -- add physics to character
    physics.addBody(character, {
        box= {
            halfWidth = character.contentWidth * 0.25,
            halfHeight = character.contentHeight * 0.2,
            y = character.contentHeight * 0.3,
            x = 0
        },
--        isSensor = true
    })

    --
    -- Character functions
    --

    -- character movement, called by joystick
    character.move = function(joystick, x, y)
        if x == 0 and y == 0 then
            -- joystick was deactivated, stop character
            character:setLinearVelocity(0, 0)
            character:pause()
            return
        end

        local xdirection = x > 0 and "right" or "left"
        local ydirection = y > 0 and "down" or "up"

        local newDirection = math.abs(x) > math.abs(y) and xdirection or ydirection
        if (newDirection ~= direction) then
            direction = newDirection
            character:setSequence(direction)
            character:play()
        elseif not isPlaying then
            -- if the characteration was idle, start it
            character:play()
        end

        character:setLinearVelocity(x, y)
    end


    return character
end


return M