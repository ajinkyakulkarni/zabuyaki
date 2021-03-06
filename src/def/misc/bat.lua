-- Copyright (c) .2017 SineDie
local spriteSheet = "res/img/misc/loot.png"
local imageWidth, imageHeight = LoadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end

return {
    serializationVersion = 0.42, -- The version of this serialization process
    spriteSheet = spriteSheet, -- The path to the spritesheet
    spriteName = "bat", -- The name of the sprite
    delay = 5.20,	--default delay for all animations
    animations = {
        icon  = {
            { q = q(2,23,38,11) } -- default 38x17
        },
        stand = {
            { q = q(2,23,55,11), ox = 27, oy = 10 } --on the ground
        },
        angle0 = {
            { q = q(2,23,55,11), ox = 12, oy = 5 }  --a0 -
        },
        angle22 = {
            { q = q(2,36,54,28), ox = 13, oy = 9 } --a22 \-
        },
        angle45 = {
            { q = q(2,66,44,44), ox = 12, oy = 13 } --a45 \+
        }
    }
} --return (end of file)
