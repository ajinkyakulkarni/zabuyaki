﻿--    compoPic.lua
--    Copyright Don Miguel, 2016
--	draws a big picture that consists of many pieces

local class = require "lib/middleclass"

local function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
--	print(x1,y1,w1,h1, x2,y2,w2,h2)
	return x1 < x2+w2 and
	x2 < x1+w1 and
	y1 < y2+h2 and
	y2 < y1+h1
end

local CompoundPicture = class('CompoundPicture')

function CompoundPicture:initialize(name, width, height)
	self.name = name
	self.width = width
    self.height = height
	self.pics = {}
	print(name..' '..self.width..'x'..self.height..' compoundPicture created')
end

--[[
love.graphics.draw (
    image_bank[spr.sprite.sprite_sheet], --The image
    --Current frame of the current animation
    spr.sprite.animations[spr.curr_anim][spr.curr_frame],
    x,
    y,
    spr.rotation,
    spr.size_scale * spr.flip_h,
    spr.size_scale * spr.flip_v,
    spr.sprite.offsets[spr.curr_anim][spr.curr_frame][1],
    spr.sprite.offsets[spr.curr_anim][spr.curr_frame][2]
)]]

function CompoundPicture:add(sprite_sheet, quad, x, y, px, py, sx, sy, func)
    local _,_,w,h = quad:getViewport()
	table.insert(self.pics, {sprite_sheet = sprite_sheet, quad = quad, w = w, h = h, x = x or 0, y = y or 0, px = px or 1, py = py or 1, sx = sx or 0, sy = sy or 0, update = func})
	print('rect '..self.pics[#self.pics].x ..' '..self.pics[#self.pics].y
		..' P:'..self.pics[#self.pics].px ..','..self.pics[#self.pics].py
		..' S:'..self.pics[#self.pics].sx ..','..self.pics[#self.pics].sy
		..' added to '..self.name)
end

function CompoundPicture:remove(rect)
--TODO add check fr w h color
	for i=1, #self.pics do
		if self.pics[i].x == rect.x and
		self.pics[i].y == rect.y and
		self.pics[i].w == rect.w and
		self.pics[i].h == rect.h
		then
			table.remove (self.pics, i)
			return
		end
	end
end

function CompoundPicture:getRect(i)
	if i then
        --local _,_,w,h = self.pics[i].quad:getViewport()
		return self.pics[i].x, self.pics[i].y, self.pics[i].w, self.pics[i].h
	end
	-- Whole Picture rect
	return 0, 0, self.width, self.height
end

function CompoundPicture:update(dt)
	local p
	for i=1, #self.pics do
		p = self.pics[i]
		--scroll horizontally e.g. clouds
		if p.sx and p.sx ~= 0 then
			p.x = p.x + (p.sx * dt)
			if p.sx > 0 then
				if p.x > self.width then
					p.x = -p.w
				end
			else
				if p.x + p.w < 0 then
					p.x = self.width
				end
			end
		end
		--scroll vertically
		if p.sy and p.sy ~= 0 then
			p.y = p.y + (p.sy * dt)
			if p.sy > 0 then
				if p.y > self.height then
					p.y = -p.h
				end
			else
				if p.y + p.h < 0 then
					p.y = self.height
				end
			end
		end
	end
end

function CompoundPicture:drawAll()
	love.graphics.setColor(200, 130, 0)
	for i=1, #self.pics do
		--love.graphics.rectangle("fill", self:getRect(i) )
	end
end

function CompoundPicture:draw(l,t,w,h)
	love.graphics.setColor(0,200, 130)
	for i=1, #self.pics do
--		print( CheckCollision( l,t,w,h, self:getRect(i) ) )
		if CheckCollision( l,t,w,h, self:getRect(i) ) then
			--love.graphics.rectangle("fill", self:getRect(i) )
            love.graphics.draw (self.pics[i].sprite_sheet,
                self.pics[i].quad,
                self.pics[i].x,
                self.pics[i].y
            )
			--love.graphics.rectangle("fill", self:getRect(i) )
			--print('ok, i draw ',self:getRect(i))
		end
	end
end

return CompoundPicture