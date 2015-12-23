-- Copyright (C) 2015 Tomoyuki Fujimori <moyu@dromozoa.com>
--
-- This file is part of dromozoa-image.
--
-- dromozoa-image is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- dromozoa-image is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with dromozoa-image.  If not, see <http://www.gnu.org/licenses/>.

local pixel = require "dromozoa.image.pixel"
local pixel1 = require "dromozoa.image.pixel1"
local pixel2 = require "dromozoa.image.pixel2"
local pixel3 = require "dromozoa.image.pixel3"
local pixel4 = require "dromozoa.image.pixel4"

local class = {}

function class.new(header, pixels)
  return { "dromozoa-image", header, pixels }
end

function class:width()
  return self[2].width
end

function class:height()
  return self[2].height
end

function class:channels()
  return self[2].channels
end

function class:min()
  return self[2].min
end

function class:max()
  return self[2].max
end

function class:pixels()
  return self[3]
end

function class:pixel()
  local channels = self:channels()
  if channels == 1 then
    return pixel1(1, self:width(), 1, self:height(), self:max(), self:pixels()):reset(1, 1)
  elseif channels == 2 then
    return pixel2(1, self:width(), 1, self:height(), self:max(), self:pixels()):reset(1, 1)
  elseif channels == 3 then
    return pixel3(1, self:width(), 1, self:height(), self:max(), self:pixels()):reset(1, 1)
  elseif channels == 4 then
    return pixel4(1, self:width(), 1, self:height(), self:max(), self:pixels()):reset(1, 1)
  end
  return pixel(self)
end

function class:each()
  return coroutine.wrap(function ()
    local pixel = self:pixel()
    repeat
      coroutine.yield(pixel)
    until pixel:next() == nil
  end)
end

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function (_, header, pixels)
    return setmetatable(class.new(header, pixels), metatable)
  end;
})
