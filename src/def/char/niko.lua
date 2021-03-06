local spriteSheet = "res/img/char/niko.png"
local imageWidth,imageHeight = LoadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end
local comboKick = function(slf, cont)
    slf:checkAndAttack(
        { x = 29, y = 22, width = 26, damage = 7, velocity = slf.vel_x, sfx = "air" },
        cont
    )
end
local comboPunch = function(slf, cont)
    slf:checkAndAttack(
        { x = 29, y = 31, width = 26, damage = 9, type = "knockDown", velocity = slf.vel_x, sfx = "air" },
        cont
    )
end
local jumpAttack = function(slf, cont)
    slf:checkAndAttack(
        { x = 15, y = 20, width = 22, height = 45, damage = 14, type = "knockDown", velocity = slf.vel_x },
        cont
    )
end
local grabShake = function(slf, cont)
    if slf.hold and slf.hold.target then
        slf.hold.target:onShake(0.5, 0, 0.01, 1)
    end
end

return {
    serializationVersion = 0.42, -- The version of this serialization process

    spriteSheet = spriteSheet, -- The path to the spritesheet
    spriteName = "niko", -- The name of the sprite

    delay = 0.2,	--default delay for all animations
    fallsOnRespawn = true, --alter respawn clouds
    --The list with all the frames mapped to their respective animations
    --  each one can be accessed like this:
    --  mySprite.animations["idle"][1], or even
    animations = {
        icon  = {
            { q = q(39, 14, 37, 17) }
        },
        intro = {
            { q = q(114,73,38,58), ox = 21, oy = 57 }, --duck
            delay = 5
        },
        intro2 = {
            { q = q(2,397,39,65), ox = 23, oy = 64 }, --intro 1
            { q = q(43,398,39,64), ox = 23, oy = 63, delay = 0.13 }, --intro 2
            { q = q(84,399,39,63), ox = 23, oy = 62 }, --intro 3
            { q = q(43,398,39,64), ox = 23, oy = 63, delay = 0.05 }, --intro 2
            loop = true,
            delay = 0.16
        },
        stand = {
            -- q = Love.graphics.newQuad( x, y, width, height, imageWidth, imageHeight),
            -- ox,oy pivots offsets from the top left corner of the quad
            -- delay = 0.1, func = fun
            { q = q(2,2,36,64), ox = 21, oy = 63 }, --stand 1
            { q = q(40,3,36,63), ox = 21, oy = 62 }, --stand 2
            { q = q(78,4,36,62), ox = 21, oy = 61 }, --stand 3
            { q = q(40,3,36,63), ox = 21, oy = 62 }, --stand 2
            loop = true,
            delay = 0.175
        },
        standHold = {
            { q = q(2,464,45,63), ox = 18, oy = 62 }, --stand hold 1
            { q = q(49,465,45,62), ox = 18, oy = 61 }, --stand hold 2
            { q = q(96,466,45,61), ox = 18, oy = 60 }, --stand hold 3
            { q = q(49,465,45,62), ox = 18, oy = 61 }, --stand hold 2
            loop = true,
            delay = 0.175
        },
        walk = {
            { q = q(116,2,36,64), ox = 21, oy = 63 }, --walk 1
            { q = q(2,2,36,64), ox = 21, oy = 63 }, --stand 1
            { q = q(154,3,38,63), ox = 21, oy = 62 }, --walk 2
            { q = q(2,2,36,64), ox = 21, oy = 63 }, --stand 1
            loop = true,
            delay = 0.175
        },
        walkHold = {
            { q = q(125,399,45,63), ox = 18, oy = 62 }, --walk hold 1
            { q = q(49,465,45,62), ox = 18, oy = 61 }, --stand hold 2
            { q = q(143,466,45,61), ox = 18, oy = 60 }, --walk hold 2
            { q = q(49,465,45,62), ox = 18, oy = 61 }, --stand hold 2
            loop = true,
            delay = 0.175
        },
        jump = {
            { q = q(2,264,57,66), ox = 21, oy = 65 }, --jump
            delay = 5
        },
        respawn = {
            { q = q(2,264,57,66), ox = 21, oy = 65, delay = 5 }, --jump
            { q = q(55,217,75,44), ox = 45, oy = 33 }, --lying down
            { q = q(132,209,55,52), ox = 31, oy = 51 }, --getting up
            { q = q(114,73,38,58), ox = 21, oy = 57 }, --duck
            delay = 0.2
        },
        duck = {
            { q = q(114,73,38,58), ox = 21, oy = 57 }, --duck
            delay = 0.06
        },
        pickup = {
            { q = q(114,73,38,58), ox = 21, oy = 57 }, --duck
            delay = 0.28
        },
        combo1 = {
            { q = q(2,332,40,63), ox = 19, oy = 62 }, --kick 1
            { q = q(44,332,60,63), ox = 18, oy = 62, func = comboKick, delay = 0.23 }, --kick 2
            { q = q(2,332,40,63), ox = 19, oy = 62, delay = 0.015 }, --kick 1
            delay = 0.01
        },
        combo2 = {
            { q = q(2,332,40,63), ox = 19, oy = 62 }, --kick 1
            { q = q(44,332,60,63), ox = 18, oy = 62, func = comboKick, delay = 0.23 }, --kick 2
            { q = q(2,332,40,63), ox = 19, oy = 62, delay = 0.015 }, --kick 1
            delay = 0.01
        },
        combo3 = {
            { q = q(50,68,62,63), ox = 21, oy = 62, func = comboPunch, delay = 0.2 }, --punch 2
            { q = q(2,68,46,63), ox = 21, oy = 62 }, --punch 1
            delay = 0.01
        },
        fall = {
            { q = q(2,199,51,62), ox = 28, oy = 61 }, --falling
            delay = 5
        },
        thrown = {
            --rx = oy / 2, ry = -ox for this rotation
            { q = q(2,199,51,62), ox = 28, oy = 61, rotate = -1.57, rx = 30, ry = -25}, --falling
            delay = 5
        },
        getup = {
            { q = q(55,217,75,44), ox = 45, oy = 33, delay = 0.2 }, --lying down
            { q = q(132,209,55,52), ox = 31, oy = 51 }, --getting up
            { q = q(114,73,38,58), ox = 21, oy = 57 }, --duck
            delay = 0.3
        },
        fallen = {
            { q = q(55,217,75,44), ox = 45, oy = 33 }, --lying down
            delay = 65
        },
        hurtHigh = {
            { q = q(2,133,41,64), ox = 26, oy = 63 }, --hurt high 1
            { q = q(45,133,46,64), ox = 31, oy = 63, delay = 0.2 }, --hurt high 2
            { q = q(2,133,41,64), ox = 26, oy = 63, delay = 0.05 }, --hurt high 1
            delay = 0.02
        },
        hurtLow = {
            { q = q(93,134,40,63), ox = 22, oy = 62, delay = 0.03 }, --hurt low 1
            { q = q(135,136,44,61), ox = 23, oy = 60 }, --hurt low 2
            { q = q(93,134,40,63), ox = 22, oy = 62, delay = 0.1 }, --hurt low 1
            delay = 0.3
        },
        jumpAttackForward = {
            { q = q(61,265,56,63), ox = 31, oy = 64 }, --jump attack forward 1
            { q = q(119,263,64,67), ox = 39, oy = 66, funcCont = jumpAttack, delay = 5 }, --jump attack forward 2
            delay = 0.12
        },
        jumpAttackStraight = {
            { q = q(61,265,56,63), ox = 31, oy = 64 }, --jump attack forward 1
            { q = q(119,263,64,67), ox = 39, oy = 66, funcCont = jumpAttack, delay = 5 }, --jump attack forward 2
            delay = 0.12
        },
        grab = {
            { q = q(2,529,45,63), ox = 18, oy = 62 }, --grab
        },
        grabAttack1 = {
            { q = q(49,530,52,62), ox = 24, oy = 61, delay = 0.05 }, --grab attack 1
            { q = q(2,594,60,60), ox = 32, oy = 59, delay = 0.2, func = grabShake }, --grab attack 2
            { q = q(49,530,52,62), ox = 24, oy = 61, delay = 0.2 }, --grab attack 1
            { q = q(2,594,60,60), ox = 32, oy = 59, delay = 0.1 }, --grab attack 2
            { q = q(64,594,60,60), ox = 32, oy = 59, delay = 0.1 }, --grab attack 2b
            { q = q(64,594,60,60), ox = 33, oy = 59 }, --grab attack 2b (shifted 1px to the left)
            { q = q(64,594,60,60), ox = 32, oy = 59 }, --grab attack 2b
            { q = q(64,594,60,60), ox = 33, oy = 59 }, --grab attack 2b (shifted 1px to the left)
            { q = q(126,594,60,60), ox = 32, oy = 59 }, --grab attack 2c
            { q = q(126,594,60,60), ox = 33, oy = 59 }, --grab attack 2c (shifted 1px to the left)
            { q = q(126,594,60,60), ox = 32, oy = 59, func = function(slf) slf:releaseGrabbed() end }, --grab attack 2c
            { q = q(126,594,60,60), ox = 33, oy = 59 }, --grab attack 2c (shifted 1px to the left)
            { q = q(64,594,60,60), ox = 32, oy = 59, delay = 0.05 }, --grab attack 2b
            { q = q(2,594,60,60), ox = 32, oy = 59, delay = 0.05 }, --grab attack 2
            { q = q(49,530,52,62), ox = 24, oy = 61, delay = 0.083 }, --grab attack 1
            delay = 0.02
        },
        grabbedFront = {
            { q = q(2,133,41,64), ox = 26, oy = 63 }, --hurt high 1
            { q = q(45,133,46,64), ox = 31, oy = 63 }, --hurt high 2
            delay = 0.1
        },
        grabbedBack = {
            { q = q(93,134,40,63), ox = 22, oy = 62  }, --hurt low 1
            { q = q(135,136,44,61), ox = 23, oy = 60 }, --hurt low 2
            delay = 0.1
        },
        grabbedFrames = {
            --default order should be kept: hurtLow2,hurtHigh2, \, /, upsideDown, laying
            { q = q(135,136,44,61), ox = 23, oy = 60 }, --hurt low 2
            { q = q(45,133,46,64), ox = 31, oy = 63, delay = 0.2 }, --hurt high 2
            { q = q(2,199,51,62), ox = 28, oy = 61 }, --falling
            { q = q(135,136,44,61), ox = 16, oy = 44, rotate = -1.57, rx = 22, ry = -30 }, --hurt low 2
            { q = q(135,136,44,61), ox = 23, oy = 60, flipV = -1 }, --hurt low 2
            { q = q(55,217,75,44), ox = 45, oy = 33 }, --lying down
            delay = 100
        },
    }
}
