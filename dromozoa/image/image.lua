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

function class:pixel(min_x, max_x, min_y, max_y)
  local header = self[2]
  if min_x == nil then
    min_x = 1
  end
  if max_x == nil then
    max_x = header.width
  end
  if min_y == nil then
    min_y = 1
  end
  if max_y == nil then
    max_y = header.height
  end
  return pixel(header.channels, min_x, max_x, min_y, max_y, header.max, self[3]):reset(min_x, min_y)
end

function class:each(min_x, max_x, min_y, max_y)
  return coroutine.wrap(function ()
    local pixel = self:pixel(min_x, max_x, min_y, max_y)
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
