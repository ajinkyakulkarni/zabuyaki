--
-- Date: 04.04.2016
--

local class = require "lib/middleclass"

local Player = class('Player', Character)

local function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
            x2 < x1+w1 and
            y1 < y2+h2 and
            y2 < y1+h1
end

local function nop() --[[print "nop"]] end

function Player:initialize(name, sprite, input, x, y, f)
    Character.initialize(self, name, sprite, input, x, y, f)
    self.type = "player"
end

function Player:isAlive()
    if (self.player_select_mode == 0 and credits > 0 and self.state == "useCredit")
            or (self.player_select_mode >= 1 and self.player_select_mode < 4)
    then
        return true
    elseif self.player_select_mode >= 4 then
        -- Did not use continue
        return false
    end
    return self.hp + self.lives > 0
end

function Player:drawShadow(l,t,w,h)
    if not self.isDisabled and CheckCollision(l, t, w, h, self.x-45, self.y-10, 90, 20) then
        if self.cool_down_death < 2 then
            love.graphics.setColor(0, 0, 0, 255 * math.sin(self.cool_down_death)) --4th is the shadow transparency
        else
            love.graphics.setColor(0, 0, 0, 255) --4th is the shadow transparency
        end
        local spr = self.sprite
        local sc = spr.def.animations[spr.cur_anim][spr.cur_frame]
        local shadowAngle = -stage.shadowAngle * spr.flip_h
        love.graphics.draw (
            image_bank[spr.def.sprite_sheet], --The image
            sc.q, --Current frame of the current animation
            self.x + self.shake.x, self.y - 2 + self.z/6,
            0,
            spr.flip_h,
            -stage.shadowHeight,
            sc.ox, sc.oy,
            shadowAngle
        )
    end
end

function Player:onHurt()
    -- hurt = {source, damage, velx,vely,x,y,z}
    local h = self.hurt
    if not h then
        return
    end
    if h.source.victims[self] then  -- if I had dmg from this src already
        dp("MISS + not Clear HURT due victims list of "..h.source.name)
        return
    end
    if h.type == "shockWave" then
        self.hurt = nil --free hurt data
        return
    end
    --Block "fall" attack if isMovable false
    if not self.isMovable and h.type == "fall" then
        h.type = "high"
    end
    h.source.victims[self] = true
    self:release_grabbed()
    h.damage = h.damage or 100  --TODO debug if u forgot
    dp(h.source.name .. " damaged "..self.name.." by "..h.damage)
    if h.type ~= "shockWave" then
        -- show enemy bar for other attacks
        h.source.victim_infoBar = self.infoBar:setAttacker(h.source)
        self.victim_infoBar = h.source.infoBar:setAttacker(self)
    end
    -- Score
    h.source:addScore( h.damage * 10 )
    self.killer_id = h.source
    self:onShake(1, 0, 0.03, 0.3)   --shake a character

    mainCamera:onShake(0, 1, 0.03, 0.3)	--shake the screen for Players only

    self:decreaseHp(h.damage)
    if h.type == "simple" then
        self.hurt = nil --free hurt data
        return
    end

    self:playHitSfx(h.damage)
    self.n_combo = 1	--if u get hit reset combo chain

    self.face = -h.source.face	--turn face to the attacker
    --self.horizontal = h.horizontal  --

    self.hurt = nil --free hurt data

    --"simple", "blow-vertical", "blow-diagonal", "blow-horizontal", "blow-away"
    --"high", "low", "fall"(replaced by blows)
    if h.type == "high" then
        if self.hp > 0 and self.z <= 0 then
            self:showHitMarks(h.damage, 40)
            self:setState(self.hurtHigh)
            return
        end
        self.velx = h.velx --use fall speed from the agument
        --then it does to "fall dead"
    elseif h.type == "low" then
        if self.hp > 0 and self.z <= 0 then
            self:showHitMarks(h.damage, 16)
            self:setState(self.hurtLow)
            return
        end
        self.velx = h.velx --use fall speed from the agument
        --then it does to "fall dead"
    elseif h.type == "grabKO" then
        --when u throw a grabbed one
        self.velx = self.velocity_throw_x
    elseif h.type == "fall" then
        --use fall speed from the agument
        self.velx = h.velx
        --it cannot be too short
        if self.velx < self.velocity_fall_x / 2 then
            self.velx = self.velocity_fall_x / 2 + self.velocity_fall_add_x
        end
    elseif h.type == "shockWave" then
        if h.source.x < self.x then
            h.horizontal = 1
        else
            h.horizontal = -1
        end
        self.face = -h.horizontal	--turn face to the epicenter
    else
        error("OnHurt - unknown h.type = "..h.type)
    end
    dpo(self, self.state)
    --finish calcs before the fall state
    self:showHitMarks(h.damage, 40)
    -- calc falling traectorym speed, direction
    self.z = self.z + 1
    self.velz = self.velocity_fall_z * self.velocity_jump_speed
    if self.hp <= 0 then -- dead body flies further
        if self.velx < self.velocity_fall_x then
            self.velx = self.velocity_fall_x + self.velocity_fall_dead_add_x
        else
            self.velx = self.velx + self.velocity_fall_dead_add_x
        end
    elseif self.velx < self.velocity_fall_x then --alive bodies
        self.velx = self.velocity_fall_x
    end
    self.horizontal = h.horizontal
    self.isGrabbed = false
    if not self.isMovable and self.hp <=0 then
        self.velx = 0
        self:setState(self.dead)
    else
        self:setState(self.fall)
    end
end

local players_list = {RICK = 1, KISA = 2, CHAI = 3, GOPPER = 4, NIKO = 5, SATOFF = 6}
function Player:useCredit_start()
    self.isHittable = false
    self.lives = self.lives - 1
    if self.lives > 0 then
        dp(self.name.." used 1 life to respawn")
        self:setState(self.respawn)
        return
    end
    self.can_attack = false
    self.cool_down = 10
    -- Player select
    self.player_select_mode = 0
    self.player_select_cur = players_list[self.name]
    --print("self.player_select_cur",self.player_select_cur)
end
function Player:useCredit_update(dt)
    if self.isDisabled then
        return
    end
    if not self.b.attack:isDown() then
        self.can_attack = true
    end

    if self.player_select_mode == 0 then
        -- 10 seconds to choose
        self.cool_down = self.cool_down - dt
        if credits <= 0 or self.cool_down <= 0 then
            -- n credits -> game over
            self.player_select_mode = 4
            return
        end
        -- wait press to use credit
        -- add countdown 9 .. 0 -> Game Over
        if self.b.attack:isDown() and self.can_attack then
            dp(self.name.." used 1 Credit to respawn")
            credits = credits - 1
            self:addScore(1) -- like CAPCM
            sfx.play("sfx","menu_select")
            self.cool_down = 1 -- delay before respawn
            self.player_select_mode = 1
        end
    elseif self.player_select_mode == 1 then
        -- wait 1 sec before player select
        if self.cool_down > 0 then
            -- wait before respawn / char select
            self.cool_down = self.cool_down - dt
            if self.cool_down <= 0 then
                self.can_attack = false
                self.cool_down = 100    --TODO debug. return to 10
                self.player_select_mode = 2
            end
        end
    elseif self.player_select_mode == 2 then
        -- Select Player
        -- 10 sec countdown before auto confirm
        if (self.b.attack:isDown() and self.can_attack)
                or self.cool_down <= 0
        then
            self.cool_down = 0
            self.player_select_mode = 3
            sfx.play("sfx","menu_select")
            local id = self.id
            player1 = HEROES[self.player_select_cur].hero:new(self.name,
                GetSpriteInstance(HEROES[self.player_select_cur].sprite_instance),
                self.b,
                self.x, self.y,
                self.shader,
                {255,255,255, 255})
            player1.id = id
            return
        else
            self.cool_down = self.cool_down - dt
        end
        ---
        if self.b.horizontal:pressed(-1) or self.b.vertical:pressed(-1)
                or self.b.horizontal:pressed(1) or self.b.vertical:pressed(1)
        then
            if self.b.horizontal:pressed(-1) or self.b.vertical:pressed(-1) then
                self.player_select_cur = self.player_select_cur - 1
            else
                self.player_select_cur = self.player_select_cur + 1
            end
            if GLOBAL_SETTING.DEBUG then
                if self.player_select_cur > players_list.SATOFF then
                    self.player_select_cur = 1
                end
                if self.player_select_cur < 1 then
                    self.player_select_cur = players_list.SATOFF
                end
            else
                if self.player_select_cur > players_list.CHAI then
                    self.player_select_cur = 1
                end
                if self.player_select_cur < 1 then
                    self.player_select_cur = players_list.CHAI
                end
            end
            sfx.play("sfx","menu_move")
            self:onShake(1, 0, 0.03, 0.3)   --shake name + face icon
            self.name = HEROES[self.player_select_cur][1].name
            self.shader = HEROES[self.player_select_cur][1].shader
            self.sprite = GetSpriteInstance(HEROES[self.player_select_cur].sprite_instance)
            self:setSprite("stand")
            self.infoBar = InfoBar:new(self)
        end
    elseif self.player_select_mode == 3 then
        -- Spawn selecterd player
        self.lives = GLOBAL_SETTING.MAX_LIVES
        self:setState(self.respawn)
        return
    elseif self.player_select_mode == 4 then
        -- Game Over
    end
end
Player.useCredit = {name = "useCredit", start = Player.useCredit_start, exit = nop, update = Player.useCredit_update, draw = Unit.default_draw}

function Player:respawn_start()
    self.isHittable = false
    dpo(self, self.state)
    self:setSprite("respawn")
    self.cool_down_death = 3 --seconds to remove
    self.hp = self.max_hp
    self.bounced = 0
    self.velz = 0
    self.z = math.random( 235, 245 )
end
function Player:respawn_update(dt)
    --    print (self.name.." - respawn update", self.z, self.sprite.cur_frame, self.sprite.elapsed_time)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    if self.z > 0 then
        self.z = self.z + dt * self.velz
        self.velz = self.velz - self.gravity * dt * self.velocity_jump_speed
    elseif self.bounced == 0 then
        self.player_select_mode = 0 -- remove player select text
        self.velz = 0
        self.z = 0
        sfx.play("sfx"..self.id, self.sfx.step)
        if self.sprite.cur_frame == 1 then
            self.sprite.elapsed_time = 10 -- seconds. skip to pickup 2 frame
        end
        self:checkAndAttack(0,0, 320 * 2, 240 * 2, 0, "shockWave", 0)
        self.bounced = 1
    end
    --self.victim_infoBar = nil   -- remove enemy bar under yours
    self:checkCollisionAndMove(dt)
end
Player.respawn = {name = "respawn", start = Player.respawn_start, exit = nop, update = Player.respawn_update, draw = Unit.default_draw}

function Player:dead_start()
    self.isHittable = false
    --print (self.name.." - dead start")
    self:setSprite("fallen")
    dp(self.name.." is dead.")
    self.hp = 0
    self.hurt = nil
    self:release_grabbed()
    if self.z <= 0 then
        self.z = 0
    end
    --self:onShake(1, 0, 0.1, 0.7)
    sfx.play("voice"..self.id, self.sfx.dead)
    if self.killer_id then
        self.killer_id:addScore( self.score_bonus )
    end
    if self.func then   -- custom function on death
    self:func(self)
    end
end
function Player:dead_update(dt)
    if self.isDisabled then
        return
    end
    --dp(self.name .. " - dead update", dt)
    if self.cool_down_death <= 0 then
        self:setState(self.useCredit)
        return
    else
        self.cool_down_death = self.cool_down_death - dt
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end
Player.dead = {name = "dead", start = Player.dead_start, exit = nop, update = Player.dead_update, draw = Unit.default_draw}

return Player