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

local image = require "dromozoa.image"

local filename = ...
local handle = assert(io.open(filename, "rb"))
local img = image.read(handle)
handle:close()

local width = img:width()
local height = img:height()

local min = img:min()
local max = img:max()
local m = 6 / (max - min + 1)
for p in img:each(1, width, 1, height) do
  local R = (p.R - min) * m R = R - R % 1
  local G = (p.G - min) * m G = G - G % 1
  local B = (p.B - min) * m B = B - B % 1
  local v = 16 + R * 36 + G * 6 + B
  io.write(("\27[48;5;%dm  "):format(v))
  if p.x == width then
    io.write("\27[0m\n")
  end
end
