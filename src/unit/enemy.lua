local class = require "lib/middleclass"
local Enemy = class('Enemy', Character)

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision

function Enemy:initialize(name, sprite, input, x, y, f)
    Character.initialize(self, name, sprite, input, x, y, f)
    self.type = "enemy"
    self.cooldownComboMax = 2 -- max delay to connect combo hits
    self.maxAiPoll_1 = 0.5
    self.AiPoll_1 = self.maxAiPoll_1
    self.maxAiPoll_2 = 5
    self.AiPoll_2 = self.maxAiPoll_2
    self.maxAiPoll_3 = 11
    self.AiPoll_3 = self.maxAiPoll_3
    self.whichPlayerAttack = "random" -- random far close weak healthy fast slow
    self.wakeupRange = 100 --instantly wakeup if the player is close
    self.wakeupDelay = 3
    self.delayedWakeupRange = 150 --wakeup after wakeupDelay if the player is close
end

function Enemy:checkCollisionAndMove(dt)
    local stepx = self.vel_x * dt * self.horizontal
    local stepy = self.vel_y * dt * self.vertical
    local actualX, actualY, cols, len, x, y
    if self.state == "walk" or self.state == "run"
    then --enemy uses tween movement
        x = self.tx
        y = self.ty
    else
        x = self.x
        y = self.y
    end
    self.shape:moveTo(x + stepx, y + stepy)
    if self.z <= 0 then
        for other, separatingVector in pairs(stage.world:collisions(self.shape)) do
            local o = other.obj
            if o.type == "wall"
                    or (o.type == "obstacle" and o.z <= 0)
            then
                self.shape:move(separatingVector.x, separatingVector.y)
                --other:move( separatingVector.x/2,  separatingVector.y/2)
            end
        end
    else
        for other, separatingVector in pairs(stage.world:collisions(self.shape)) do
            local o = other.obj
            if o.type == "wall"
            then
                self.shape:move(separatingVector.x, separatingVector.y)
            end
        end
    end
    local cx,cy = self.shape:center()
    self.x = cx
    self.y = cy
end

function Enemy:updateAI(dt)
    if self.isDisabled then
        return
    end
    Character.updateAI(self, dt)
end

function Enemy:onFriendlyAttack()
    local h = self.isHurt
    if not h then
        return
    end
    if self.type == h.source.type and not h.isThrown then
        self.isHurt = nil   --enemy doesn't attack enemy
    else
        h.damage = h.damage or 0
    end
end

function Enemy:decreaseHp(damage)
    self.hp = self.hp - damage
    if self.hp <= 0 then
        self.hp = self.maxHp + self.hp
        self.lives = self.lives - 1
        if self.lives <= 0 then
            self.hp = 0
        else
            self.infoBar.hp = self.maxHp -- prevent green fill up
            self.infoBar.old_hp = self.maxHp
        end
    end
end

function Enemy:introStart()
    self.isHittable = true
    self:setSprite("intro")
end
function Enemy:introUpdate(dt)
    self:calcMovement(dt, true, nil)
end
Enemy.intro = { name = "intro", start = Enemy.introStart, exit = nop, update = Enemy.introUpdate, draw = Character.defaultDraw }

function Enemy:deadStart()
    self.isHittable = false
    self:setSprite("fallen")
    dp(self.name.." is dead.")
    self.hp = 0
    self.isHurt = nil
    self:releaseGrabbed()
    if self.z <= 0 then
        self.z = 0
    end
    sfx.play("voice"..self.id, self.sfx.dead)
end
function Enemy:deadUpdate(dt)
    if self.isDisabled then
        return
    end
    --dp(self.name .. " - dead update", dt)
    if self.cooldownDeath <= 0 then
        self.isDisabled = true
        self.isHittable = false
        -- dont remove dead body from the stage for proper save/load
        stage.world:remove(self.shape)  --stage.world = global collision shapes pool
        --self.y = GLOBAL_SETTING.OFFSCREEN
        return
    else
        self.cooldownDeath = self.cooldownDeath - dt
    end
    --self:calcMovement(dt, true)
end
Enemy.dead = {name = "dead", start = Character.deadStart, exit = nop, update = Character.deadUpdate, draw = Character.defaultDraw}

function Enemy:getDistanceToClosestPlayer()
    local p = {}
    for i = 1, GLOBAL_SETTING.MAX_PLAYERS do
        local player = getRegisteredPlayer(i)
        if player and not player.isDisabled and player:isAlive() then
            p[#p +1] = {player = player, points = 0 }
        end
    end
    for i = 1, #p do
        p[i].points = dist(self.x, self.y, p[i].player.x, p[i].player.y)
    end
    table.sort(p, function(a,b)
        return a.points < b.points
    end )
    if #p < 1 then
        return 900
    end
    return p[1].points
end

local next_to_pick_targetId = 1
---
-- @param how - "random" far close weak healthy fast slow
--
function Enemy:pickAttackTarget(how)
    local p = {}
    for i = 1, GLOBAL_SETTING.MAX_PLAYERS do
        local player = getRegisteredPlayer(i)
        if player and not player.isDisabled and player:isAlive() then
            p[#p +1] = {player = player, points = 0 }
        end
    end
    if #p < 1 then
        return nil
    end
    how = how or self.whichPlayerAttack
    for i = 1, #p do
        if how == "close" then
            p[i].points = -dist(self.x, self.y, p[i].player.x, p[i].player.y)
        elseif how == "far" then
            p[i].points = dist(self.x, self.y, p[i].player.x, p[i].player.y)
        elseif how == "weak" then
            if p[i].player.hp > 0 and not p[i].player.isDisabled  then
                p[i].points = -p[i].player.hp + math.random()
            else
                p[i].points = -1000
            end
        elseif how == "healthy" then
            if p[i].player.hp > 0 and not p[i].player.isDisabled then
                p[i].points = p[i].player.hp + math.random()
            else
                p[i].points = math.random()
            end
        elseif how == "slow" then
            p[i].points = -p[i].player.velocityWalk_x + math.random()
        elseif how == "fast" then
            p[i].points = p[i].player.velocityWalk_x + math.random()
        else -- "random"
            if not p[i].player.isDisabled then
                p[i].points = math.random()
            else
                p[i].points = -1000
            end
        end
    end

    table.sort(p, function(a,b)
            return a.points > b.points
    end )

    if #p < 1 then
        self.target = nil
    else
        self.target = p[1].player
    end
    return self.target
end

function Enemy:faceToTarget(x, y)
    -- Facing towards the target
    if self.z <= 0
            and self.isHittable
            and not self.isGrabbed
            and self.state ~= "run"
            and self.state ~= "dashAttack"
    then
        if not self.target and not x then
            self.face = rand1()
        elseif x or self.target.x < self.x then
            self.face = -1
        else
            self.face = 1
        end
        self.horizontal = self.face
    end
end

function Enemy:jumpStart()
    self.isHittable = true
    dpo(self, self.state)
    self:setSprite("jump")
    self.vel_z = self.velocityJump * self.velocityJumpSpeed
    self.z = 0.1
    self.bounced = 0
    self.bouncedPitch = 1 + 0.05 * love.math.random(-4,4)
    if self.lastState == "run" then
        -- jump higher from run
        self.vel_z = (self.velocityJump + self.velocityJumpRunBoost_z) * self.velocityJumpSpeed
    end
    self.vertical = 0
    sfx.play("voice"..self.id, self.sfx.jump)
end
Enemy.jump = {name = "jump", start = Enemy.jumpStart, exit = nop, update = Character.jumpUpdate, draw = Character.defaultDraw }

return Enemy
