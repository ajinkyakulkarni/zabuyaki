local class = require "lib/middleclass"
local Stopper = class("Stopper", Unit)

local function nop() end

function Stopper:initialize(name, f)
    --f options {}: shapeType, shapeArgs, hp, score, shader, color,isMovable, sfxDead, func, face, horizontal, weight, sfxOnHit, sfxOnBreak
    if not f then
        f = { shapeType = "rectangle", shapeArgs = { 0, 0, 20, 100 } }
    end
    local x, y = f.shapeArgs[1] or 0, f.shapeArgs[2] or 0
    local width, height = f.shapeArgs[3] or 20, f.shapeArgs[4] or 240
    Unit.initialize(self, name, nil, nil, x, y, f)
    self.name = name or "Unknown Stopper"
    self.type = "stopper"
    self.vertical, self.horizontal, self.face = 1, f.horizontal or 1, f.face or 1 --movement and face directions
    self.isHittable = false
    self.isDisabled = false
    self.isMovable = f.isMovable or false
    self.width = width
    self.height = height
    self.infoBar = nil

    self:setState(self.stand)
end

function Stopper:moveTo(x, y)
    self.shape:moveTo(x, y)
    self.x, self.y = x, y
end

function Stopper:updateSprite(dt)
end

function Stopper:setSprite(anim)
end

function Stopper:drawSprite(l,t,w,h)
--    love.graphics.setColor(255, 255, 255, 150)
--    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end

function Stopper:drawShadow(l,t,w,h)
end

function Stopper:updateAI(dt)
end

function Stopper:onHurt()
end

Stopper.stand = {name = "stand", start = nop, exit = nop, update = nop, draw = nop}

return Stopper