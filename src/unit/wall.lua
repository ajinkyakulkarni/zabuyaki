local class = require "lib/middleclass"
local Wall = class("Wall", Unit)

local function nop() end

function Wall:initialize(name, f)
    --f options {}: shapeType, shapeArgs, hp, score, shader, color,isMovable, sfxDead, func, face, horizontal, weight, sfxOnHit, sfxOnBreak
    if not f then
        f = { shapeType = "circle", shapeArgs = { 0, 0, 10 } }
    end
    local x, y = f.shapeArgs[1] or 0, f.shapeArgs[2] or 0
    Unit.initialize(self, name, nil, nil, x, y, f)
    self.name = name or "Unknown Wall"
    self.type = "wall"
    self.vertical, self.horizontal, self.face = 1, f.horizontal or 1, f.face or 1 --movement and face directions
    self.isHittable = false
    self.isDisabled = false
    self.isMovable = f.isMovable --on death sfx

    self.infoBar = nil

    --self:addShape(f.shapeType or "rectangle", f.shapeArgs)

    self:setState(self.stand)
end

function Wall:setOnStage(stage)
    stage.objects:add(self)
end

function Wall:updateSprite(dt)
end

function Wall:setSprite(anim)
end

function Wall:drawSprite(l,t,w,h)
end

function Wall:drawShadow(l,t,w,h)
end

function Wall:updateAI(dt)
end

function Wall:onHurt()
end

Wall.stand = {name = "stand", start = nop, exit = nop, update = nop, draw = nop}

return Wall