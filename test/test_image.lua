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
  -- print(json.encode(img))
end
