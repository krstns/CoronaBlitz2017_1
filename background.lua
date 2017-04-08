--
-- Created by IntelliJ IDEA.
-- User: krystian
-- Date: 07/04/17
-- Time: 22:40
--

local M = {}

local math = math

local options =  {
    width = 32,
    height = 32,
    numFrames = 120
}

local imageSheet = graphics.newImageSheet( "background.png", options )

M.create = function(bgWidth, bgHeight)

    local bg = display.newGroup()

    -- floor
    for x = 0, math.ceil(bgWidth / (32 * 3)) do
        for y = 0, math.ceil(bgHeight / (32 * 3)) do
            local tile = M.generateTile()
            tile.x = -bgWidth * 0.5 + x * 32 * 3
            tile.y = -bgHeight * 0.5 + y * 32 * 3
            bg:insert(tile)
        end
    end

    -- invisible walls
    local left = -bgWidth * 0.5 + 200
    local right = bgWidth * 0.5 - 200
    local top = -bgHeight * 0.5 + 200
    local bottom = bgHeight * 0.5 - 200

    local walls = display.newLine(bg, left, top, left, bottom, right, bottom, right, top, left, top)
    walls.isVisible = false
    physics.addBody(walls, { type = "static" })

    return bg

end

M.generateTile = function()
    local tile = display.newImage(imageSheet, 80)
    tile:scale(3, 3)

    return tile
end


return M

