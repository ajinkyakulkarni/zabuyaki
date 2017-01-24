﻿-- Select Sprite for Sprite Editor
spriteSelectState = {}

local time = 0
local screen_width = 640
local screen_height = 480
local menu_item_h = 40
local menu_y_offset = 200 - menu_item_h
local menu_x_offset = 0
local hint_y_offset = 80
local title_y_offset = 24
local left_item_offset  = 6
local top_item_offset  = 6
local item_width_margin = left_item_offset * 2
local item_height_margin = top_item_offset * 2 - 2

local sprite = nil
local heroes = {
    {
        name = "RICK",
        shaders = { nil, shaders.rick[2], shaders.rick[3] },
        sprite_instance = "src/def/char/rick.lua",
    },
    {
        name = "KISA",
        shaders = { nil, shaders.kisa[2], shaders.kisa[3] },
        sprite_instance = "src/def/char/kisa.lua",
    },
    {
        name = "CHAI",
        shaders = { nil, shaders.chai[2], shaders.chai[3] },
        sprite_instance = "src/def/char/chai.lua",
    },
    {
        name = "GOPPER",
        shaders = { nil, shaders.gopper[2], shaders.gopper[3], shaders.gopper[4], shaders.gopper[5] },
        sprite_instance = "src/def/char/gopper.lua",
    },
    {
        name = "NIKO",
        shaders = { nil, shaders.niko[2], shaders.niko[3] },
        sprite_instance = "src/def/char/niko.lua",
    },
    {
        name = "SATOFF",
        shaders = { nil, shaders.satoff[2], shaders.satoff[3], shaders.satoff[4] },
        sprite_instance = "src/def/char/satoff.lua",
    },
    {
        name = "CAN",
        shaders = { nil, shaders.trashcan[2] },
        sprite_instance = "src/def/stage/object/can.lua",
    },
    {
        name = "SIGN",
        shaders = { },
        sprite_instance = "src/def/stage/object/sign.lua",
    },
}

local weapons = {
    {
        name = "BAT",
        shaders = { },
        sprite_instance = "src/def/misc/bat.lua",
    }
}

local txt_options_logo = love.graphics.newText( gfx.font.kimberley, "SELECT CHAR/OBJ" )
local txt_items = {"FRAME POSITIONING", "WEAPON POSITIONING", "BACK"}

local function fillMenu(txt_items, txt_hints)
    local m = {}
    local max_item_width, max_item_x = 8, 0
    if not txt_hints then
        txt_hints = {}
    end
    for i = 1, #txt_items do
        local w = gfx.font.arcade4:getWidth(txt_items[i])
        if w > max_item_width then
            max_item_x = menu_x_offset + screen_width / 2 - w / 2
            max_item_width = w
        end
    end
    for i = 1, #txt_items do
        local w = gfx.font.arcade4:getWidth(txt_items[i])
        m[#m + 1] = {
            item = txt_items[i],
            hint = txt_hints[i] or "",
            x = menu_x_offset + screen_width / 2 - w / 2,
            y = menu_y_offset + i * menu_item_h,
            rect_x = max_item_x,
            w = max_item_width,
            h = gfx.font.arcade4:getHeight(txt_items[i]),
            wx = (screen_width - gfx.font.arcade4:getWidth(txt_hints[i] or "")) / 2,
            wy = screen_height - hint_y_offset,
            n = 1
        }
    end
    return m
end

local function calcMenuItem(menu, i)
    assert(menu and menu[i], "menu item error")
    local m = menu[i]
    m.w = gfx.font.arcade4:getWidth(m.item)
    m.h = gfx.font.arcade4:getHeight(m.item)
    m.wy = screen_height - hint_y_offset
    m.x = menu_x_offset + screen_width / 2 - m.w / 2
    m.y = menu_y_offset + i * menu_item_h
    m.rect_x = menu_x_offset + screen_width / 2 - m.w / 2
    m.wx = (screen_width - gfx.font.arcade4:getWidth(m.hint)) / 2
end

local menu = fillMenu(txt_items, txt_hints)

local menu_state, old_menu_state = 1, 1
local mouse_x, mouse_y, old_mouse_y = 0, 0, 0

function spriteSelectState:enter()
    mouse_x, mouse_y = 0,0
    --TEsound.stop("music")
    -- Prevent double press at start (e.g. auto confirmation)
    Control1.attack:update()
    Control1.jump:update()
    Control1.start:update()
    Control1.back:update()
    love.graphics.setLineWidth( 2 )
    self:wheelmoved(0, 0)   --pick 1st sprite to draw
end

--Only P1 can use menu / options
local function player_input(controls)
    if controls.jump:pressed() or controls.back:pressed() then
        sfx.play("sfx","menu_cancel")
        return Gamestate.pop()
    elseif controls.attack:pressed() or controls.start:pressed() then
        return spriteSelectState:confirm( mouse_x, mouse_y, 1)
    end
    if controls.horizontal:pressed(-1)then
        spriteSelectState:wheelmoved(0, -1)
    elseif controls.horizontal:pressed(1)then
        spriteSelectState:wheelmoved(0, 1)
    elseif controls.vertical:pressed(-1) then
        menu_state = menu_state - 1
    elseif controls.vertical:pressed(1) then
        menu_state = menu_state + 1
    end
    if menu_state < 1 then
        menu_state = #menu
    end
    if menu_state > #menu then
        menu_state = 1
    end
end

function spriteSelectState:update(dt)
    time = time + dt
    if menu_state ~= old_menu_state then
        sfx.play("sfx","menu_move")
        old_menu_state = menu_state
        self:showCurrentSprite()
    end

    if sprite then
        UpdateSpriteInstance(sprite, dt)
    end

    player_input(Control1)
end

function spriteSelectState:draw()
    push:apply("start")
    love.graphics.setFont(gfx.font.arcade4)
    for i = 1,#menu do
        local m = menu[i]
        if i == 1 then
            if #heroes[m.n].shaders > 0 then
                m.item = heroes[m.n].name.." - "..#heroes[m.n].shaders.." shaders"
            else
                m.item = heroes[m.n].name.." - no shaders"
            end
            m.hint = ""..heroes[m.n].sprite_instance
        elseif i == 2 then
            if m.n > #weapons then  --TODO plug while dont have any wep
                m.n = #weapons
            end
            if m.n == 0 then
                m.item = "N/A"
                m.hint = "NO WEAPONS"
            else
                m.item = "WEAPON #"..m.n.." "..weapons[m.n].name
                m.hint = "..."
            end
        end
        calcMenuItem(menu, i)
        if i == old_menu_state then
            love.graphics.setColor(255, 255, 255, 255)
            love.graphics.print(m.hint, m.wx, m.wy)
            love.graphics.setColor(0, 0, 0, 80)
            love.graphics.rectangle("fill", m.rect_x - left_item_offset, m.y - top_item_offset, m.w + item_width_margin, m.h + item_height_margin, 4,4,1)
            love.graphics.setColor(255,200,40, 255)
            love.graphics.rectangle("line", m.rect_x - left_item_offset, m.y - top_item_offset, m.w + item_width_margin, m.h + item_height_margin, 4,4,1)
        end
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.print(m.item, m.x, m.y )

        if GLOBAL_SETTING.MOUSE_ENABLED and mouse_y ~= old_mouse_y and
                CheckPointCollision(mouse_x, mouse_y, m.rect_x - left_item_offset, m.y - top_item_offset, m.w + item_width_margin, m.h + item_height_margin )
        then
            old_mouse_y = mouse_y
            menu_state = i
        end
    end
    --header
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(txt_options_logo, (screen_width - txt_options_logo:getWidth()) / 2, title_y_offset)

    --sprite
    love.graphics.setColor(255, 255, 255, 255)
--    if cur_players_hero_set.shader then
--        love.graphics.setShader(cur_players_hero_set.shader)
--    end
    if sprite then
        DrawSpriteInstance(sprite, screen_width / 2, menu_y_offset + menu_item_h / 2)
    end
--    if cur_players_hero_set.shader then
--        love.graphics.setShader()
--    end
    show_debug_indicator()
    push:apply("end")
end

function spriteSelectState:confirm( x, y, button, istouch )
    if (button == 1 and menu_state == #menu) or button == 2 then
        sfx.play("sfx","menu_cancel")
        TEsound.stop("music")
        TEsound.volume("music", GLOBAL_SETTING.BGM_VOLUME)
        return Gamestate.pop()
    end
    if button == 1 then
        if menu_state == 1 then
            sfx.play("sfx","menu_select")
            return Gamestate.push(spriteEditorState, heroes[menu[menu_state].n], weapons[menu[2].n])
        elseif menu_state == 2 then
            if weapons[menu[menu_state].n] then
                sfx.play("sfx","menu_select")
                return Gamestate.push(spriteEditorState, weapons[menu[menu_state].n])
            else
                sfx.play("sfx","menu_cancel")
            end
        end
    end
end

function spriteSelectState:mousepressed( x, y, button, istouch )
    if not GLOBAL_SETTING.MOUSE_ENABLED then
        return
    end
    spriteSelectState:confirm( x, y, button, istouch )
end

function spriteSelectState:mousemoved( x, y, dx, dy)
    if not GLOBAL_SETTING.MOUSE_ENABLED then
        return
    end
    mouse_x, mouse_y = x, y
end

function spriteSelectState:showCurrentSprite()
    if menu_state == 1 then
        sprite = GetSpriteInstance(heroes[menu[menu_state].n].sprite_instance)
        --sprite.size_scale = 2
        SetSpriteAnimation(sprite,"stand")

    elseif menu_state == 2 then
        if weapons[menu[menu_state].n] then
            sprite = GetSpriteInstance(weapons[menu[menu_state].n].sprite_instance)
            --sprite.size_scale = 2
            SetSpriteAnimation(sprite,"stand")
        else
            sprite = nil
        end
    end
end

function spriteSelectState:wheelmoved(x, y)
    local i = 0
    if y > 0 then
        i = 1
    elseif y < 0 then
        i = -1
    end
    menu[menu_state].n = menu[menu_state].n + i
    if menu_state == 1 then
        if menu[menu_state].n < 1 then
            menu[menu_state].n = #heroes
        end
        if menu[menu_state].n > #heroes then
            menu[menu_state].n = 1
        end
        self:showCurrentSprite()

    elseif menu_state == 2 then
        if menu[menu_state].n < 0 then
            menu[menu_state].n = #weapons
        end
        if menu[menu_state].n > #weapons then
            menu[menu_state].n = 0
        end
        self:showCurrentSprite()
    end
    if menu_state ~= #menu then
        sfx.play("sfx","menu_move")
    end
end
