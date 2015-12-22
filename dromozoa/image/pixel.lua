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

function class.new(image, x, y)
  return class.reset({
    image = image;
  }, x, y)
end

function class:reset(x, y)
  if x == nil then
    x = 1
  end
  if y == nil then
    y = 1
  end
  local image = self.image
  local width = image:width()
  local channels = image:channels()
  local j = (x + width * (y - 1)) * channels
  self.x = x
  self.y = y
  self.i = j - channels + 1
  self.j = j
  return self
end

function class:next()
  local image = self.image
  local width = image:width()
  local height = image:height()
  local channels = image:channels()
  local x = self.x + 1
  local y = self.y
  local i = self.i + channels
  local j = self.j + channels
  if x > width then
    x = 1
    y = y + 1
  end
  if y > height then
    self.x = nil
    self.y = nil
    self.i = nil
    self.j = nil
    return nil
  else
    self.x = x
    self.y = y
    self.i = i
    self.j = j
    return self
  end
end

local metatable = {}

function metatable:__index(key)
  if key == "R" then
    local image = self.image
    return image:pixels()[self.i]
  elseif key == "G" then
    local image = self.image
    if image:channels() > 2 then
      return image:pixels()[self.i + 1]
    else
      return image:pixels()[self.i]
    end
  elseif key == "B" then
    local image = self.image
    if image:channels() > 2 then
      return image:pixels()[self.i + 2]
    else
      return image:pixels()[self.i]
    end
  elseif key == "A" then
    local image = self.image
    if image:channels() % 2 == 0 then
      return image:pixels()[self.j]
    else
      return 255
    end
  elseif key == "Y" then
    local image = self.image
    if image:channels() > 2 then
      local pixels = image:pixels()
      local i = self.i
      local R = pixels[i]
      local G = pixels[i + 1]
      local B = pixels[i + 2]
      return 0.299 * R + 0.587 * G + 0.114 * B
    else
      return image:pixels()[self.i]
    end
  else
    return class[key]
  end
end

return setmetatable(class, {
  __call = function (_, image, x, y)
    return setmetatable(class.new(image, x, y), metatable)
  end;
})
