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

local magick_reader = require "dromozoa.image.magick_reader"
local pnm_reader = require "dromozoa.image.pnm_reader"
local sips_reader = require "dromozoa.image.sips_reader"
local tga_reader = require "dromozoa.image.tga_reader"

local class = {}

if sips_reader.support then
  class.reader = sips_reader
elseif magick_reader.support then
  class.reader = magick_reader
end

function class.read_pnm(this)
  return pnm_reader(this):apply()
end

function class.read_tga(this)
  return pnm_reader(this):apply()
end

function class.read(this)
  return class.reader(this):apply()
end

return class
