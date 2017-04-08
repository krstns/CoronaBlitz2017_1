--
-- Created by IntelliJ IDEA.
-- User: krystian
-- Date: 07/04/17
-- Time: 20:20
--

local M = {}

-- create new time bar
M.create = function(guiLayer)
    local timeBar = display.newGroup()
    timeBar.isVisible = false

    local bg = display.newRect(timeBar, 0, 0, display.contentWidth - 100, 20)
    local frame = display.newRect(timeBar, 0, 0, display.contentWidth - 102, 18)
    frame:setFillColor(0, 0, 0)

    local fgWidth = display.contentWidth - 104
    local fg = display.newRect(timeBar, fgWidth * -0.5, 0, fgWidth, 16)
    fg.anchorX = 0

    local score = 0
    local scoreText = display.newText(timeBar, score, 0, 50, native.systemFont, 32)

    guiLayer:insert(timeBar)


    local baseTime = 20000 -- 20 sec
    local currentTime = baseTime

    --
    -- time bar functions
    --
    timeBar.addTime = function(timeToAdd)
        currentTime = currentTime + timeToAdd
        if (currentTime > baseTime) then
            currentTime = baseTime
        end

        timeBar.resetTimer()

        score = score + 1
        scoreText.text = score
    end

    timeBar.resetTimer = function()
        if (not timeBar) then
            return
        end

        if (timeBar.timeBarTimer) then
            transition.cancel(timeBar.timeBarTimer)
            timeBar.timeBarTimer = nil
        end

        fg.xScale = (currentTime / baseTime)
        timeBar.timeBarTimer = transition.to(fg, { xScale = 0.0025, time = currentTime, onComplete = timeBar.timeUp })
    end

    timeBar.timeUp = function()
        Runtime:dispatchEvent({
            name = "gameOver",
        })
    end

    timeBar.getScore = function()
        return score
    end

    timeBar.cleanup = function()
        if (timeBar.timeBarTimer) then
            transition.cancel(timeBar.timeBarTimer)
            timeBar.timeBarTimer = nil
        end

        timeBar.isVisible = false
    end
    Runtime:addEventListener("gameOver", timeBar.cleanup)

    timeBar.newGame = function()
        currentTime = baseTime
        score = 0
        scoreText.text = score

        timeBar.resetTimer()
        timeBar.isVisible = true
    end

    return timeBar
end


return M