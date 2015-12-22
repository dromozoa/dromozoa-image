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

function class:index(x, y)
  local header = self[2]
  return x + (y - 1) * header.width
end

function class:get(x, y)
  local header = self[2]
  local pixels = self[3]
  local channels = header.channels
  local i = ((x - 1) + (y - 1) * header.width) * channels + 1
  if channels == 1 then
    return pixels[i]
  elseif channels == 2 then
    return pixels[i], pixels[i + 1]
  elseif channels == 3 then
    return pixels[i], pixels[i + 1], pixels[i + 2]
  elseif channels == 4 then
    return pixels[i], pixels[i + 1], pixels[i + 2], pixels[i + 3]
  else
    error("invalid channels")
  end
end

function class:set(x, y, a, b, c, d)
  local header = self[2]
  local pixels = self[3]
  local channels = header.channels
  local i = ((x - 1) + (y - 1) * header.width) * channels + 1
  if channels == 1 then
    pixels[i] = a
  elseif channels == 2 then
    pixels[i] = a
    pixels[i + 1] = b
  elseif channels == 3 then
    pixels[i] = a
    pixels[i + 1] = b
    pixels[i + 2] = c
  elseif channels == 4 then
    pixels[i] = a
    pixels[i + 1] = b
    pixels[i + 2] = c
    pixels[i + 3] = d
  else
    error("invalid channels")
  end
  return self
end

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function (_, header, pixels)
    return setmetatable(class.new(header, pixels), metatable)
  end;
})
