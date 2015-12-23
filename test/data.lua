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
local magick_reader = require "dromozoa.image.magick_reader"
local pnm_reader = require "dromozoa.image.pnm_reader"
local sips_reader = require "dromozoa.image.sips_reader"
local tga_reader = require "dromozoa.image.tga_reader"

local width = 17
local height = 23

local function f(x, y, channels)
  if channels == 1 then
    return 0xfe, 0xfe, 0xfe, 0xff
  elseif channels == 2 then
    return 0xfe, 0xfe, 0xfe, 0xed
  elseif channels == 3 then
    return 0xfe, 0xed, 0xfa, 0xff
  elseif channels == 4 then
    return 0xfe, 0xed, 0xfa, 0xce
  end
end

local function g(x, y, channels)
  local a = (x - 1) * 255 / (width - 1) a = a - a % 1
  local b = (y - 1) * 255 / (height - 1) b = b - b %1
  if channels == 1 then
    return a, a, a, 255
  elseif channels == 2 then
    return a, a, a, b
  elseif channels == 3 then
    return a, b, 255 - a, 255
  elseif channels == 4 then
    return a, b, 255 - a, 255 - b
  end
end

for filename in sequence.each(arg) do
  local reader
  if filename:find("%.p.m$") then
    reader = pnm_reader
  elseif filename:find("%.tga$") then
    reader = tga_reader
  elseif sips_reader.support then
    reader = sips_reader
  elseif magick_reader.support then
    reader = magick_reader
  end

  local mode, channels = filename:match("([fg])([1-4])")
  channels = tonumber(channels)
  local fn
  if mode == "f" then
    fn = f
  elseif mode == "g" then
    fn = g
  end

  local handle = assert(io.open(filename, "rb"))
  local img = reader(handle):apply()
  handle:close()
  local header = img[2]
  assert(img:width() == width)
  assert(img:height() == height)
  assert(img:channels() >= channels)
  assert(img:min() == 0)
  assert(img:max() == 255)
  for p in img:each() do
    local R, G, B, A = fn(p.x, p.y, channels)
    assert(p.R == R)
    assert(p.G == G)
    assert(p.B == B)
    assert(p.A == A)
  end
end
