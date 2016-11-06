--
-- Date: 29.03.2016
--
local class = require "lib/middleclass"

local Loot = class("Loot", Unit)

local function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
            x2 < x1+w1 and
            y1 < y2+h2 and
            y2 < y1+h1
end

function Loot:initialize(name, note, gfx, hp, score, func, x, y, shader, color)
    self.sprite = gfx.sprite
    self.q = gfx.q
    self.ox = gfx.ox
    self.oy = gfx.oy

    self.name = name or "Unknown Loot"
    self.note = note or "???"
    self.type = "loot"
    self.hp = hp
    self.score = score
    self.func = func
    self.x, self.y, self.z = x, y, 0
    self.height = 17
    self.vertical, self.horizontal, self.face = 1, 1, 1 --movement and face directions
    self.color = color or { 255, 255, 255, 255 }
    self.shader = shader
    self.isHittable = false
    self.isDisabled = false

    self.infoBar = InfoBar:new(self)

    self.id = GLOBAL_UNIT_ID --to stop Y coord sprites flickering
    GLOBAL_UNIT_ID = GLOBAL_UNIT_ID + 1
end

function Loot:drawShadow(l,t,w,h)
    --TODO adjust sprite dimensions
    if not self.isDisabled and CheckCollision(l, t, w, h, self.x-16, self.y-10, 32, 20) then
        love.graphics.setColor(0, 0, 0, 100) --4th is the shadow transparency
        love.graphics.draw (
            self.sprite, --The image
            self.q, --Current frame of the current animation
            self.x, self.y - 2 + self.z/6,
            0, --spr.rotation
            1, -0.3, --spr.size_scale * spr.flip_h, spr.size_scale * spr.flip_v,
            self.ox, self.oy
        )
    end
end

function Loot:draw(l,t,w,h)
    --TODO adjust sprite dimensions.
    if not self.isDisabled and CheckCollision(l, t, w, h, self.x-20, self.y-40, 40, 40) then
        love.graphics.setColor( unpack( self.color ) )
        love.graphics.draw (
            self.sprite, --The image
            self.q, --Current frame of the current animation
            self.x, self.y - self.z,
            0, --spr.rotation
            1, 1, --spr.size_scale * spr.flip_h, spr.size_scale * spr.flip_v,
            self.ox, self.oy
        )
    end
end

function Loot:onHurt()
end

function Loot:update(dt)
    if self.isDisabled then
        return
    end
    --custom code here. e.g. for triggers / keys
end

function Loot:updateAI(dt)
    --    Unit.updateAI(self, dt)
--     print("updateAI "..self.type.." "..self.name)
end

function Loot:get(taker)
    dp(taker.name .. " got "..self.name.." HP+ ".. self.hp .. ", $+ " .. self.score)
    if self.func then    --run custom function if there is
        self:func(taker)
    end
    if self.name == "Apple" then
        sfx.play("sfx"..self.id,"pickup_apple")
    elseif self.name == "Chicken" then
        sfx.play("sfx"..self.id,"pickup_chicken")
    else
        sfx.play("sfx"..self.id,"pickup_beef")
    end
    taker:addHp(self.hp)
    taker:addScore(self.score)
    self.isDisabled = true
    stage.world:remove(self)  --world = global bump var
    --self.y = GLOBAL_SETTING.OFFSCREEN --keep in the stage for proper save/load
end

return Loot