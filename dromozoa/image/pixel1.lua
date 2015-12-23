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

local class = {}

function class.new(min_x, max_x, min_y, max_y, max, pixels)
  return {
    min_x = min_x;
    max_x = max_x;
    width = max_x - min_x + 1;
    min_y = min_y;
    max_y = max_y;
    max = max;
    pixels = pixels;
  }
end

function class:reset(x, y)
  self.x = x
  self.y = y
  self.i = x + self.width * (y - 1)
  return self
end

function class:next()
  local x = self.x
  if x < self.max_x then
    self.x = x + 1
    self.i = self.i + 1
  else
    local y = self.y
    if y < self.max_y then
      return self:reset(self.min_x, y + 1)
    else
      self.x = nil
      self.y = nil
      self.i = nil
      return nil
    end
  end
end

local metatable = {}

function metatable:__index(key)
  if key == "R" then
    return self.pixels[self.i]
  elseif key == "G" then
    return self.pixels[self.i]
  elseif key == "B" then
    return self.pixels[self.i]
  elseif key == "A" then
    return self.max
  elseif key == "Y" then
    return self.pixels[self.i]
  else
    return class[key]
  end
end

return setmetatable(class, {
  __call = function (_, min_x, max_x, min_y, max_y, max, pixels)
    return setmetatable(class.new(min_x, max_x, min_y, max_y, max, pixels), metatable)
  end;
})
