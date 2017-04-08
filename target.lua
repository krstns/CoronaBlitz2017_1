--
-- Created by IntelliJ IDEA.
-- User: krystian
-- Date: 07/04/17
-- Time: 23:46
--

local M = {}

local math = math

M.create = function()

    -- create target animations from a sprite
    local sheetOptions = {
        width = 32,
        height = 32,
        numFrames = 96,
    }
    local target = graphics.newImageSheet("target.png", sheetOptions)

    -- target animations
    local targetAnimations = {
        {
            name = "fire",
            start = 49,
            count = 3,
            time = 300,
            loopCount = 0,
            loopDirection = "bounce"
        },
        {
            name = "ice",
            start = 52,
            count = 3,
            time = 300,
            loopCount = 0,
            loopDirection = "bounce"
        }
    }

    local type = math.random() > 0.5 and "fire" or "ice"

    -- initial values

    local target = display.newSprite(target, targetAnimations)
    target:scale(3, 3)
    target:setSequence(type)
    target.objectName = "target_" .. type
    target:play()


    -- add physics to target
    physics.addBody(target, {
        box= {
            halfWidth = target.contentWidth * 0.25,
            halfHeight = target.contentHeight * 0.15,
            y = target.contentHeight * 0.2,
            x = 0
        },
        isSensor = true
    })

    return target
end


return M

