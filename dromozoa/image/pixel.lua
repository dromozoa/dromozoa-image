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

local pixel1 = require "dromozoa.image.pixel1"
local pixel2 = require "dromozoa.image.pixel2"
local pixel3 = require "dromozoa.image.pixel3"
local pixel4 = require "dromozoa.image.pixel4"

return function (channels, min_x, max_x, min_y, max_y, max, pixels)
  if channels == 1 then
    return pixel1(min_x, max_x, min_y, max_y, max, pixels)
  elseif channels == 2 then
    return pixel2(min_x, max_x, min_y, max_y, max, pixels)
  elseif channels == 3 then
    return pixel3(min_x, max_x, min_y, max_y, max, pixels)
  elseif channels == 4 then
    return pixel4(min_x, max_x, min_y, max_y, max, pixels)
  end
end
