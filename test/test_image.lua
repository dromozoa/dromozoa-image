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
local image = require "dromozoa.image"

for channels = 1, 4 do
  local img = image({
    width = 64;
    height = 64;
    channels = channels;
    min = 0;
    max = 255;
  })
  for p in img:each() do
    local x = p.x - 31.5
    local y = p.y - 31.5
    local r = math.sqrt(x * x + y * y)
    local v = r / 32
    if 10 < r and r < 11 then
      p:rgb(0, 0, 255):alpha(255)
    elseif 20 < r and r < 21 then
      p:rgb(0, 255, 0):alpha(255)
    elseif 30 < r and r < 31 then
      p:rgb(255, 0, 0):alpha(255)
    else
      p:gray(127):alpha(255)
    end
  end
  for p in img:each() do
    assert(p.A == 255)
  end
  img:write_tga(assert(io.open(("test%d.tga"):format(channels), "wb"))):close()
  -- print(json.encode(img))
end

local img = image({
  width = 2;
  height = 1;
  channels = 3;
  min = 0;
  max = 65535;
})
local p = img:pixel()
p:rgb(0, 255, 256)
p:next()
p:rgb(4095, 4096, 65535)
img:write_tga(assert(io.open("test.tga", "wb"))):close()

local handle = assert(io.open("test.tga", "rb"))
local img = image.read_tga(handle)
handle:close()
assert(img:width() == 2)
assert(img:height() == 1)
assert(img:channels() == 4)
assert(img:min() == 0)
assert(img:max() == 255)

local p = img:pixel()
assert(p.R == 0)
assert(p.G == 0)
assert(p.B == 1)
p:next()
assert(p.R == 15)
assert(p.G == 16)
assert(p.B == 255)

local img = image.read_pnm([[
P2
2 1
15
0 15
]])
img:write_pam(assert(io.open("test.pam", "wb"))):close()
img:write_tga(assert(io.open("test.tga", "wb"))):close()

for i in sequence():push("test.pam", "test.tga"):each() do
  local img = image.read_file(i)
  local p = img:pixel()
  assert(p.Y == img:min())
  p:next()
  assert(p.Y == img:max())
end
