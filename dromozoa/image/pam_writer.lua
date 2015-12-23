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

  local channels = this:channels()
  local tupltype
  if channels == 1 then
    tupltype = "GRAYSCALE"
  elseif channels == 2 then
    tupltype = "GRAYSCALE_ALPHA"
  elseif channels == 3 then
    tupltype = "RGB"
  elseif channels == 4 then
    tupltype = "RGB_ALPHA"
  else
    error("unsupported TUPLTYPE")
  end

  local max = this:max()
  local min = this:min()
  local m = max - min
  if m > 65535 then
    error("MAXVAL too big")
  end

  that
    :write("P7\n")
    :write("WIDTH ", this:width(), "\n")
    :write("HEIGHT ", this:height(), "\n")
    :write("DEPTH ", channels, "\n")
    :write("MAXVAL ", m, "\n")
    :write("TUPLTYPE ", tupltype, "\n")
    :write("ENDHDR\n")

  if m < 256 then
    if channels == 1 then
      for p in this:each() do
        local Y = p.Y - min
        that:write(string.char(Y - Y % 1))
      end
    elseif channels == 2 then
      for p in this:each() do
        local Y = p.Y - min
        local A = p.A - min
        that:write(string.char(Y - Y % 1, A - A % 1))
      end
    elseif channels == 3 then
      for p in this:each() do
        local R = p.R - min
        local G = p.G - min
        local B = p.B - min
        that:write(string.char(B - B % 1, G - G % 1, R - R % 1))
      end
    elseif channels == 4 then
      for p in this:each() do
        local R = p.R - min
        local G = p.G - min
        local B = p.B - min
        local A = p.A - min
        that:write(string.char(B - B % 1, G - G % 1, R - R % 1, A - A % 1))
      end
    end
  else
    if channels == 1 then
      for p in this:each() do
        local Y = p.Y - min
        that:write(uint16.char(Y - Y % 1, ">"))
      end
    elseif channels == 2 then
      for p in this:each() do
        local Y = p.Y - min
        local A = p.A - min
        that:write(uint16.char(Y - Y % 1, ">"), uint16.char(A - A % 1, ">"))
      end
    elseif channels == 3 then
      for p in this:each() do
        local R = p.R - min
        local G = p.G - min
        local B = p.B - min
        that:write(uint16.char(R - R % 1, ">"), uint16.char(G - G % 1, ">"), uint16.char(B - B % 1, ">"))
      end
    elseif channels == 4 then
      for p in this:each() do
        local R = p.R - min
        local G = p.G - min
        local B = p.B - min
        local A = p.A - min
        that:write(uint16.char(R - R % 1, ">"), uint16.char(G - G % 1, ">"), uint16.char(B - B % 1, ">"), uint16.char(A - A % 1, ">"))
      end
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
