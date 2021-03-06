arcadeState = {}

local time = 0
local screenWidth = 640
local screenHeight = 480
local gameOverText = love.graphics.newText( gfx.font.kimberley, "GAME OVER" )
local function drawGameOver()
    love.graphics.setColor(55, 55, 55, 255)
    love.graphics.draw(gameOverText, (screenWidth - gameOverText:getWidth()) / 2 + 1, (screenHeight - gameOverText:getHeight()) / 2 + 1 )
    love.graphics.draw(gameOverText, (screenWidth - gameOverText:getWidth()) / 2 - 1, (screenHeight - gameOverText:getHeight()) / 2 + 1 )
    love.graphics.draw(gameOverText, (screenWidth - gameOverText:getWidth()) / 2 + 1, (screenHeight - gameOverText:getHeight()) / 2 - 1 )
    love.graphics.draw(gameOverText, (screenWidth - gameOverText:getWidth()) / 2 - 1, (screenHeight - gameOverText:getHeight()) / 2 - 1 )
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(gameOverText, (screenWidth - gameOverText:getWidth()) / 2, (screenHeight - gameOverText:getHeight()) / 2 )
end
local isAlive
local gameOverDelay = 0

SELECT_NEW_PLAYER = {} --{id, player}

function arcadeState:init()
end

function arcadeState:resume()
    gameOverDelay = 0
    love.graphics.setLineWidth( 1 )
    --restore BGM music volume
    TEsound.volume("sfx", GLOBAL_SETTING.SFX_VOLUME)
    TEsound.volume("music", GLOBAL_SETTING.BGM_VOLUME)
end

function arcadeState:enter(_, players)
    credits = GLOBAL_SETTING.MAX_CREDITS
    --load stage
    stage = Stage1:new(players)
    gameOverDelay = 0
    love.graphics.setLineWidth( 1 )
    --start BGM
    TEsound.stop("music")
    TEsound.playLooping(bgm.stage1, "music")

    TEsound.volume("sfx", GLOBAL_SETTING.SFX_VOLUME)
    TEsound.volume("music", GLOBAL_SETTING.BGM_VOLUME)
end

function arcadeState:update(dt)
    if GLOBAL_SETTING.DEBUG and GLOBAL_SETTING.SLOW_MO > 0 then
        if slowMoCounter == 0 then
            time = time + dt
            clearDebugBoxes()
        else
            return
        end
    else
        time = time + dt
        clearDebugBoxes()
    end
    if GLOBAL_SETTING.PROFILER_ENABLED then
        Prof:attach()
    end
    stage:update(dt)
    if GLOBAL_SETTING.PROFILER_ENABLED then
        Prof:detach()
    end

    --Respawn selected players
    checkPlayersRespawn(stage)

    if stage.mode == "normal" then
        isAlive = areThereAlivePlayers()
    else
        isAlive = true
    end

    if not isAlive then
        gameOverDelay = gameOverDelay + dt
        if gameOverDelay > 4
                and (Control1.back:pressed() or
                Control1.attack:pressed() or
                Control1.jump:pressed()) then
            return Gamestate.switch(titleState)
        end
    else
        -- Screenshot Pause
        if Control1.screenshot:pressed() then
            return Gamestate.push(screenshotState)
        end
    end
    -- PAUSE (only for P1)
    if Control1.back:pressed() then
        return Gamestate.push(pauseState)
    end
    watchDebugVariables()
end

function arcadeState:draw()
    mainCamera:draw(function(l, t, w, h)
        -- draw camera stuff here
        love.graphics.setColor(255, 255, 255, 255)
        stage:draw(l,t,w,h)
        showDebugBoxes() -- debug draw collision boxes
    end)
    love.graphics.setCanvas()
    push:start()
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(canvas[1], 0,0, nil, display.final.scale) --bg
    love.graphics.setColor(255, 255, 255, GLOBAL_SETTING.SHADOW_OPACITY)
    love.graphics.draw(canvas[2], 0,0, nil, display.final.scale) --shadows
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(canvas[3], 0,0, nil, display.final.scale) --sprites + fg
    love.graphics.setBlendMode("alpha")
    if stage.mode == "normal" then
        drawPlayersBars()
    end
    showDebugControls()
    showDebugIndicator()
    if not isAlive then
        drawGameOver()
    end
    stage:displayTime(screenWidth, screenHeight)
    -- Profiler Pie Graph
    if GLOBAL_SETTING.PROFILER_ENABLED and ProfOn then
        Prof:draw({50})
    end
    -- FPS (in ms) graph
    if GLOBAL_SETTING.FPSRATE_ENABLED then
        framerateGraph.draw()
    end
    push:finish()
end

function arcadeState:keypressed(key, unicode)
    checkDebugKeys(key)
end

function arcadeState:wheelmoved( dx, dy )
end