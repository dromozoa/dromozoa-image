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

local linked_hash_table = require "dromozoa.commons.linked_hash_table"
local sequence = require "dromozoa.commons.sequence"
local string_reader = require "dromozoa.commons.string_reader"

local class = {}

function class.new(this)
  if type(this) == "string" then
    this = string_reader(this)
  end
  return {
    this = this;
  }
end

function class:magic()
  local this = self.this
  if this:match("P7\n") then
    return true
  end
end

function class:header()
  local this = self.this
  local that = linked_hash_table()
  while true do
    if this:match("ENDHDR\n") then
      break
    elseif this:match("HEIGHT%s+(%d+)%s*\n") then
      that.height = tonumber(this[1])
    elseif this:match("WIDTH%s+(%d+)[ \t]*\n") then
      that.width = tonumber(this[1])
    end
  end
end

function class:pam_header()
  local this = self.this
  local header = linked_hash_table()
  local tupltype = ""
  for line in this:lines() do
    line = line:gsub("^%s+", ""):gsub("%s+$", "")
    local token, value = line:match("^(%S+)%s+(.*)$")
    if token == nil then
      token = line
    end
    if token == "ENDHDR" then
      break
    elseif token == "HEIGHT" then
      header.height = tonumber(value)
    elseif token == "WIDTH" then
      header.width = tonumber(value)
    elseif token == "DEPTH" then
      header.depth = tonumber(value)
    elseif token == "MAXVAL" then
      header.maxval = tonumber(value)
    elseif token == "TUPLTYPE" then
      if tupltype == "" then
        tupltype = value
      else
        tupltype = tupltype .. "\n" .. value
      end
    else
      error("invalid token " .. token)
    end
  end
  header.tupltype = tupltype
  return header
end

function class:pam_image(header)
  local this = self.this
  local image = sequence()
  local width = header.width
  local height = header.height
  local depth = header.depth
  local bit_depth = math.log(header.maxval + 1, 2)
  if bit_depth == 8 then
    local n = width * height * depth
    for i = 1, n do
      local byte = this:read(1):byte()
      image:push(byte)
    end
  end
  return { header, image }
end

function class:pam()
  return self:pam_image(self:pam_header())
end

function class:apply()
  local this = self.this
  local matic = this:read(3)
  if matic == "P7\n" then
    return self:pam()
  end
end

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function (_, this)
    return setmetatable(class.new(this), metatable)
  end;
})
