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

local uint16 = require "dromozoa.commons.uint16"

local class = {}

function class.new(this, that)
  return {
    this = this;
    that = that;
  }
end

function class:apply()
  local this = self.this
  local that = self.that

  local image_width = this:width()
  local image_height = this:height()

  if image_width > 65535 then
    error("image_width too big")
  end
  if image_height > 65535 then
    error("image_height too big")
  end

  -- id length
  that:write("\0")
  -- color map type (no color map)
  that:write("\0")
  -- image type (uncompressed, true color image)
  that:write("\2")
  -- first entry index
  that:write("\0\0")
  -- color map length
  that:write("\0\0")
  -- color map entry size
  that:write("\0")
  -- x-origin of image
  that:write("\0\0")
  -- y-origin of image
  that:write("\0\0")
  -- image width
  that:write(uint16.char(image_width, "<"))
  -- image height
  that:write(uint16.char(image_height, "<"))
  -- pixel depth
  that:write("\32")
  -- image descriptor (alpha channel bits, top to bottom)
  that:write("\40")

  local min = this:min()
  local max = this:max()
  local m = max - min
  if m == 255 then
    for p in this:each() do
      local R = p.R - min
      local G = p.G - min
      local B = p.B - min
      local A = p.A - min
      that:write(string.char(B - B % 1, G - G % 1, R - R % 1, A - A % 1))
    end
  else
    if m < 255 then
      m = 255 / m
    else
      m = 256 / (m + 1)
    end
    for p in this:each() do
      local R = (p.R - min) * m
      local G = (p.G - min) * m
      local B = (p.B - min) * m
      local A = (p.A - min) * m
      that:write(string.char(B - B % 1, G - G % 1, R - R % 1, A - A % 1))
    end
  end

  return that
end

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function (_, this, that)
    return setmetatable(class.new(this, that), metatable)
  end;
})
