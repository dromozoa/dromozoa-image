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

local img = image.read_pnm([[
P3
2 2
255
255 255 255
255 0 0
0 255 0
0 0 255
]])
img:write_png(assert(io.open("test.png", "wb"))):close()

local handle = assert(io.open("test.png"))
local img = image.read(handle)
handle:close()

assert(img:width() == 2)
assert(img:height() == 2)
local p = img:pixel()
assert(p.R == 255)
assert(p.G == 255)
assert(p.B == 255)
assert(p.A == 255)
p:next()
assert(p.R == 255)
assert(p.G == 0)
assert(p.B == 0)
assert(p.A == 255)
p:next()
assert(p.R == 0)
assert(p.G == 255)
assert(p.B == 0)
assert(p.A == 255)
p:next()
assert(p.R == 0)
assert(p.G == 0)
assert(p.B == 255)
assert(p.A == 255)
