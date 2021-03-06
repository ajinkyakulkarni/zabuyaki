local class = require "lib/middleclass"
local Chai = class('Chai', Player)

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision

function Chai:initialize(name, sprite, input, x, y, f)
    Player.initialize(self, name, sprite, input, x, y, f)
end

function Chai:initAttributes()
    self.moves = { -- list of allowed moves
        run = true, sideStep = true, pickup = true,
        jump = true, jumpAttackForward = true, jumpAttackLight = true, jumpAttackRun = true, jumpAttackStraight = true,
        grab = true, grabSwap = true, grabAttack = true, holdAttack = true, dashHold = true,
        shoveUp = true, shoveDown = true, shoveBack = true, shoveForward = true,
        dashAttack = true, offensiveSpecial = true, defensiveSpecial = true,
        -- technically present for all
        stand = true, walk = true, combo = true, slide = true, fall = true, getup = true, duck = true,
    }
    self.velocityWalk_x = 100
    self.velocityWalk_y = 50
    self.velocityWalkHold_x = 80
    self.velocityWalkHold_y = 40
    self.velocityRun_x = 150
    self.velocityRun_y = 25
    self.velocityDash = 150 --speed of the character
    self.velocityDashFall = 180 --speed caused by dash to others fall
    self.frictionDash = self.velocityDash
    self.velocityTeep_x = 150 --horizontal speed of the teep slide
    self.velocityTeep_y = 120 --vertical speed of the teep slide
    --    self.velocityShove_x = 220 --my throwing speed
    --    self.velocityShove_z = 200 --my throwing speed
    --    self.velocityShoveHorizontal = 1.3 -- +30% for horizontal throws
    self.velocitySlide = 200 --horizontal speed of the slide kick
    self.velocitySlide_y = 20 --vertical speed of the slide kick
    self.myThrownBodyDamage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrownFallDamage = 20  --dmg I suffer on landing from the thrown-fall
    -- default sfx
    self.sfx.jump = "chaiJump"
    self.sfx.throw = "chaiThrow"
    self.sfx.jumpAttack = "chaiAttack"
    self.sfx.dashAttack = "chaiAttack"
    self.sfx.step = "chaiStep"
    self.sfx.dead = "chaiDeath"
end

function Chai:dashAttackStart()
    self.isHittable = true
    self.horizontal = self.face
    dpo(self, self.state)
    --	dp(self.name.." - dashAttack start")
    self:setSprite("dashAttack")
    self.vel_x = self.velocityDash * self.velocityJumpSpeed
    self.vel_z = self.velocityJump * self.velocityJumpSpeed
    self.z = 0.1
    sfx.play("sfx"..self.id, self.sfx.dashAttack)
    self:showEffect("jumpStart")
end
function Chai:dashAttackUpdate(dt)
    if self.sprite.isFinished then
        self:setState(self.fall)
        return
    end
    if self.z > 0 then
        self:calcFreeFall(dt)
        if self.vel_z > 0 then
            if self.vel_x > 0 then
                self.vel_x = self.vel_x - (self.velocityDash * dt)
            else
                self.vel_x = 0
            end
        end
    else
        self.vel_z = 0
        self.z = 0
        sfx.play("sfx"..self.id, self.sfx.step)
        self:setState(self.duck)
        return
    end
    self:calcMovement(dt, true)
end
Chai.dashAttack = {name = "dashAttack", start = Chai.dashAttackStart, exit = nop, update = Chai.dashAttackUpdate, draw = Character.defaultDraw }

function Chai:shoveForwardStart()
    self.isHittable = false
    local g = self.hold
    local t = g.target
    self:moveStatesInit()
    t.isHittable = false    --protect grabbed enemy from hits
    self:setSprite("shoveForward")
    dp(self.name.." shoveForward someone.")
end
function Chai:shoveForwardUpdate(dt)
    self:moveStatesApply()
    if self.sprite.isFinished then
        self.cooldown = 0.2
        self:setState(self.stand)
        return
    end
    self:calcMovement(dt, true, nil)
end
Chai.shoveForward = {name = "shoveForward", start = Chai.shoveForwardStart, exit = nop, update = Chai.shoveForwardUpdate, draw = Character.defaultDraw}

function Chai:shoveBackStart()
    self.isHittable = false
    local g = self.hold
    local t = g.target
    self:moveStatesInit()
    t.isHittable = false    --protect grabbed enemy from hits
    self:setSprite("shoveBack")
    dp(self.name.." shoveBack someone.")
end
function Chai:shoveBackUpdate(dt)
    self:moveStatesApply()
    if self.sprite.isFinished then
        self.cooldown = 0.2
        self:setState(self.stand)
        return
    end
    self:calcMovement(dt, true, nil)
end
Chai.shoveBack = {name = "shoveBack", start = Chai.shoveBackStart, exit = nop, update = Chai.shoveBackUpdate, draw = Character.defaultDraw}

function Chai:defensiveSpecialStart()
    self.isHittable = false
    self.z = 0
    self.jumpType = 0
    self:setSprite("defensiveSpecial")
    sfx.play("voice"..self.id, self.sfx.dashAttack)
    self.cooldown = 0.2
end
function Chai:defensiveSpecialUpdate(dt)
    if self.jumpType == 1 then
        self.vel_z = self.velocityJump * self.velocityJumpSpeed
        self.z = 0.1
        self.jumpType = 0
    elseif self.jumpType == 2 then
        self.vel_z = -self.velocityJump * self.velocityJumpSpeed / 2
        self.jumpType = 0
    end
    if self.z > 32 then
        self.z = 32
    end
    if self.z > 0 then
        self:calcFreeFall(dt)
        if self.z < 0 then
            self.z = 0
        end
    end
    if self.particles then
        self.particles.z = self.z + 2 -- because we show the effect 2px down the unit
    end
    if self.sprite.isFinished then
        self.particles = nil
        self:setState(self.stand)
        return
    end
    self:calcMovement(dt, true)
end
Chai.defensiveSpecial = {name = "defensiveSpecial", start = Chai.defensiveSpecialStart, exit = nop, update = Chai.defensiveSpecialUpdate, draw = Character.defaultDraw }

return Chai