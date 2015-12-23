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

local sequence = require "dromozoa.commons.sequence"
local magick_reader = require "dromozoa.image.magick_reader"
local pixel = require "dromozoa.image.pixel"
local pnm_reader = require "dromozoa.image.pnm_reader"
local sips_reader = require "dromozoa.image.sips_reader"
local sips_writer = require "dromozoa.image.sips_writer"
local tga_reader = require "dromozoa.image.tga_reader"
local tga_writer = require "dromozoa.image.tga_writer"

local class = {}

local reader
if sips_reader.support then
  reader = sips_reader
elseif magick_reader.support then
  reader = magick_reader
end

local writer
if sips_writer.support then
  writer = sips_writer
-- elseif magick_writer.support then
--   writer = magick_writer
end

function class.read_pnm(this)
  return pnm_reader(this):apply()
end

function class.read_tga(this)
  return tga_reader(this):apply()
end

function class.read(this)
  return reader(this):apply()
end

function class.new(header, pixels)
  if pixels == nil then
    pixels = sequence()
  end
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
  return pixel(header.channels, header.width, min_x, max_x, min_y, max_y, header.max, self[3]):reset(min_x, min_y)
end

function class:each(min_x, max_x, min_y, max_y)
  return coroutine.wrap(function ()
    local pixel = self:pixel(min_x, max_x, min_y, max_y)
    repeat
      coroutine.yield(pixel)
    until pixel:next() == nil
  end)
end

function class:write_tga(out)
  return tga_writer(self, out):apply()
end

function class:write_png(out)
  return writer(self, out):apply("png")
end

pnm_reader.super = class
tga_reader.super = class

sips_reader.super = class
sips_writer.super = class

magick_reader.super = class

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function (_, header, pixels)
    return setmetatable(class.new(header, pixels), metatable)
  end;
})
