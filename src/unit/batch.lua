-- enemy batch / spawning que

local class = require "lib/middleclass"
local Batch = class('Batch')

--[[
{
    delay = seconds,
    left_stopper =
    right_stopper =
    units = {
        { unit = ,
          spawned = false
        }
    }
]]
function Batch:ps(t)
    print("BATCH #"..self.n.." State:"..self.state.." "..(t or ""))
end

function Batch:initialize(stage, batches)
    self.stage = stage
    self.time = 0
    self.n = 1 --1st batch
    self.batches = batches
    print("Stage has #",#batches,"batches of enemy")
    if self:load() then
        self.state = "spawn"
        -- left_stopper, right_stopper
    else
        -- the last batch is done
        self.state = "done"
    end
end

function Batch:load()
    local n = self.n
    if n > #self.batches then
        return false
    end
    print("load Batch #",n)
    local b = self.batches[n]
    self.left_stopper = b.left_stopper or 0
    self.right_stopper = b.right_stopper or 320

    for i = 1, #b.units do
        local u = b.units[i]
        u.isSpawned = false
        --print("units in batch:",u.unit.name)
    end
    return true
end

function Batch:spawn(dt)
    local b = self.batches[self.n]
    --move left_stopper, right_stopper
    local centerX, dist, minx, maxx = self.stage.centerX, self.stage.dist, self.stage.minx, self.stage.maxx
    --print(centerX, minx, maxx, dist )
    local lx, rx = self.stage.left_stopper.x, self.stage.right_stopper.x    --current in the stage
    --print("LX"..lx.."->"..self.left_stopper..", RX "..rx.." -> "..self.right_stopper, minx, maxx )
    if lx < self.left_stopper
        and minx > self.left_stopper + 320
    then
        lx = self.left_stopper
    end
    if rx < self.right_stopper then
        rx = rx + dt * 300 -- speed of the right Stopper movement > char's run
    end
    --rx = math.min( self.right_stopper, lx + 320 + 160 - 50 )    --max possible dist between players
    if lx ~= self.stage.left_stopper.x or rx ~= self.stage.right_stopper.x then
        self.stage:moveStoppers(lx, rx)
    end

    if self.time < b.delay then --delay before the whole batch
        return false
    end

    local all_spawned = true
    local all_dead = true
    for i = 1, #b.units do
        local u = b.units[i]
        if not u.isSpawned then
            if self.time - b.delay >= u.delay then --delay before the unit's spawn
                --TODO spawn
                print("spawn ", u.unit.name, u.unit.type, u.unit.hp, self.time)
                --add to stage / bump
                --self:ps(" enSpawn Unit #"..i)
                self.stage.objects:add(u.unit)
                u.isSpawned = true
                if u.state == "intro" then
                    u.unit:setState(u.unit.intro)
                elseif u.state == "stand" then
                    u.unit:setState(u.unit.intro)
                    u.unit:setSprite("stand")
                elseif u.state == "walk" then
                    u.unit:pickAttackTarget("close")
                    u.unit:setState(u.unit.stand)
                end
            end
            all_spawned = false
            all_dead = false --not yet spawned = alive
        else
            if u.unit.hp > 0 and u.unit.type == "enemy" then --alive enemy
                all_dead = false
            end
        end
    end
    if all_spawned then
        --??
    end
    if all_dead then
        self.state = "next"
        self.time = 0
    end
    --print("all spawned", all_spawned, "all dead", all_dead)
    return true
end

function Batch:update(dt)
    self.time = self.time + dt
--    self:ps()
    if self.state == "spawn" then
        self:spawn(dt)
        return
    elseif self.state == "next" then
--        self:ps()
        self.n = self.n + 1
        if self:load() then
            self.state = "spawn"
            self.time = 0
            self:ps()
        else
            self.state = "done"
            self.time = 0
            self:ps()
        end
        return
    elseif self.state == "done" then
--        self:ps()
        return
    end
end

return Batch