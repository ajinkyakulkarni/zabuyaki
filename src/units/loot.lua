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

function Loot:initialize(name, gfx, x, y, f)
    --f options {}: shapeType, shapeArgs, hp, score, shader, color, sfxOnHit, sfxDead, func
    if not f then
        f = {}
    end
    Unit.initialize(self, name, nil, nil, x, y, f)
    self.draw = Loot.draw
    self.sprite = gfx.sprite
    self.q = gfx.q
    self.ox = gfx.ox
    self.oy = gfx.oy

    self.note = f.note or "???"
    self.pickupSfx = f.pickupSfx
    self.type = "loot"
    self.x, self.y, self.z = x, y, 20
    self.height = 17
    self.vertical, self.horizontal, self.face = 1, 1, 1 --movement and face directions
    self.isHittable = false
    self.isDisabled = false
    self.bounced = 0

    self.infoBar = InfoBar:new(self)

    self.id = GLOBAL_UNIT_ID --to stop Y coord sprites flickering
    GLOBAL_UNIT_ID = GLOBAL_UNIT_ID + 1
end

function Loot:addShape()
    Unit.addShape(self, "circle", { self.x, self.y, 7.5 })
end

function Loot:drawShadow(l,t,w,h)
    --TODO adjust sprite dimensions
    if not self.isDisabled and CheckCollision(l, t, w, h, self.x-16, self.y-10, 32, 20) then
        love.graphics.setColor(0, 0, 0, 255) --4th is the shadow transparency
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

--function Loot:update(dt)
--    if self.isDisabled then
--        return
--    end
--    --custom code here. e.g. for triggers / keys
--end

function Loot:updateAI(dt)
    if self.isDisabled then
        return
    end
    --    Unit.updateAI(self, dt)
--     print("updateAI "..self.type.." "..self.name)
    if self.z > 0 then
        self.z = self.z + dt * self.velz
        self.velz = self.velz - self.gravity * dt
        if self.z <= 0 then
            if self.velz < -100 and self.bounced < 1 then    --bounce up after fall (not )
                if self.velz < -300 then
                    self.velz = -300
                end
                self.z = 0.01
                self.velz = -self.velz/2
                --sfx.play("sfx" .. self.id, self.sfx.onBreak or "fall", 1 - self.bounced * 0.2, self.bounced_pitch - self.bounced * 0.2)
                self.bounced = self.bounced + 1
                --landing dust clouds
                local psystem = PA_DUST_FALLING:clone()
                psystem:setAreaSpread( "uniform", 4, 1 )
                psystem:setLinearAcceleration(-50, -10, 50, -20) -- Random movement in all directions.
                psystem:emit(3)
                stage.objects:add(Effect:new(psystem, self.x, self.y+3))
                return
            else
                --final fall (no bouncing)
                self.z = 0
                self.velz = 0
                --sfx.play("sfx"..self.id,"fall", 0.5, self.bounced_pitch - self.bounced * 0.2)
                return
            end
        end
    end
end

function Loot:get(taker)
    dp(taker.name .. " got "..self.name.." HP+ ".. self.hp .. ", $+ " .. self.score)
    if self.func then    --run custom function if there is
        self:func(taker)
    end
    sfx.play("sfx"..self.id, self.pickupSfx)
    taker:addHp(self.hp)
    taker:addScore(self.score)
    self.isDisabled = true
    stage.world:remove(self.shape)  --stage.world = global collision shapes pool
    self.shape = nil
    --self.y = GLOBAL_SETTING.OFFSCREEN --keep in the stage for proper save/load
end

return Loot
