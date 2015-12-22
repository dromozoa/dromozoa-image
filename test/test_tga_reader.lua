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

local json = require "dromozoa.commons.json"
local sequence = require "dromozoa.commons.sequence"
local tga_reader = require "dromozoa.image.tga_reader"

local width = 17
local height = 23

local function f(x, y, channels)
  if channels == 1 then
    return 0xfe, 0xfe, 0xfe, 0xff
  elseif channels == 2 then
    return 0xfe, 0xfe, 0xfe, 0xef
  end

  return 0xfe, 0xed, 0xfa, 0xce
end

local function g(x, y)
  local a = x * 255 / (width - 1) a = a - a % 1
  local b = y * 255 / (height - 1) b = b - b %1
  return a, b, 255 - a, 255 - b
end

for filename in sequence.each(arg) do
  print(filename)
  local mode, channels = filename:match("([fg])([1-4])")
  channels = tonumber(channels)
  local fn
  if mode == "f" then
    fn = f
  elseif mode == "g" then
    fn = g
  end
  if mode ~= nil then
    local handle = assert(io.open(filename, "rb"))
    local img = tga_reader(handle):apply()
    handle:close()
    local header = img[2]
    print(json.encode(header))
    assert(header.width == width)
    assert(header.height == height)
    assert(header.channels >= channels)
    assert(header.min == 0)
    assert(header.max == 255)
    -- for y = 0, height - 1 do
    --   for x = 0, width - 1 do
    --     local a, b, c, d = fn(x, y, channels, header.channels)
    --   end
    -- end
  end
end
