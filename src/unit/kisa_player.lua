--
-- Date: 21.06.2016
--

local class = require "lib/middleclass"

local Kisa = class('Kisa', Character)

local function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
            x2 < x1+w1 and
            y1 < y2+h2 and
            y2 < y1+h1
end

local function nop() --[[print "nop"]] end

function Kisa:initialize(name, sprite, input, x, y, f)
    Character.initialize(self, name, sprite, input, x, y, f)
    self.type = "player"
    self.max_hp = 100
    self.hp = self.max_hp
    self.infoBar = InfoBar:new(self)
    self.victim_infoBar = nil

    self.velocity_walk = 110
    self.velocity_walk_y = 55
    self.velocity_run = 160
    self.velocity_run_y = 27
    self.velocity_dash = 150 --speed of the character
    self.velocity_dash_fall = 180 --speed caused by dash to others fall
    self.friction_dash = self.velocity_dash
    self.velocity_grab_throw_x = 220 --my throwing speed
    self.velocity_grab_throw_z = 200 --my throwing speed
    self.my_thrown_body_damage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrown_land_damage = 20  --dmg I suffer on landing from the thrown-fall
    --Character default sfx
	self.sfx.jump = "kisa_jump"
    self.sfx.throw = "kisa_throw"
    self.sfx.jump_attack = "kisa_attack"
    self.sfx.dash = "kisa_attack"
    self.sfx.step = "kisa_step"
    self.sfx.dead = "kisa_death"
end

function Kisa:combo_start()
    self.isHittable = true
    --	print (self.name.." - combo start")
    self.cool_down = 0.2
end
function Kisa:combo_update(dt)
    self:setState(self.stand)
    return
end
Kisa.combo = {name = "combo", start = Kisa.combo_start, exit = nop, update = Kisa.combo_update, draw = Character.default_draw}

return Kisa