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
local uint16 = require "dromozoa.commons.uint16"

local class = {}

function class.new(this)
  if type(this) == "string" then
    this = string_reader(this)
  end
  return {
    this = this;
  }
end

function class:read_plain(header)
  local this = self.this
  local pixels = sequence()
  local n = header.width * header.height * header.channels
  local min = header.min
  local max = header.max
  for i = 1, n do
    local value = this:read("*n")
    if value ~= nil and min <= value and value <= max and value % 1 == 0 then
      pixels[i] = value
    else
      error("invalid pixel")
    end
  end
  return class.super(header, pixels)
end

function class:read_raw(header)
  local this = self.this
  local pixels = sequence()
  local n = header.width * header.height * header.channels
  local max = header.max
  if max < 256 then
    for i = 4, n, 4 do
      pixels:push(this:read(4):byte(1, 4))
    end
    local m = n % 4
    if m > 0 then
      pixels:push(this:read(m):byte(1, m))
    end
  else
    for i = 2, n, 2 do
      pixels:push(uint16.read(this, 2, ">"))
    end
    local m = n % 2
    if m > 0 then
      pixels:push(uint16.read(this, 1, ">"))
    end
  end
  return class.super(header, pixels)
end

function class:read_pnm_header_value()
  local this = self.this
  while true do
    local value = this:read("*n")
    if value == nil then
      local char = this:read(1)
      if char == "#" then
        this:read()
      elseif char:find("%S") then
        error("invalid header")
      end
    else
      if value > 0 and value % 1 == 0 then
        return value
      else
        error("invalid header value")
      end
    end
  end
end

function class:read_pnm_header(magic)
  local this = self.this
  local header = linked_hash_table()
  header.width = self:read_pnm_header_value()
  header.height = self:read_pnm_header_value()
  header.min = 0
  header.max = self:read_pnm_header_value()
  if this:read(1):find("%S") then
    error("invalid header")
  end
  if magic:find("P[25]") then
    header.channels = 1
  else
    header.channels = 3
  end
  return header
end

function class:read_pam_header()
  local this = self.this
  local header = linked_hash_table()
  for line in this:lines() do
    local line = line:gsub("^%s+", ""):gsub("%s+$", "")
    if line == "ENDHDR" then
      break
    elseif line:find("^TUPLTYPE") then
      -- ignore
    else
      local token, value = line:match("^([A-Z]+)%s+([1-9]%d*)$")
      local value = tonumber(value)
      if token == "WIDTH" then
        header.width = value
      elseif token == "HEIGHT" then
        header.height = value
      elseif token == "DEPTH" then
        if value <= 4 then
          header.channels = value
        else
          error("invalid DEPTH")
        end
      elseif token == "MAXVAL" then
        header.min = 0
        header.max = value
      else
        error("invalid header")
      end
    end
  end
  if header.width == nil then
    error("WIDTH not found")
  end
  if header.height == nil then
    error("HEIGHT not found")
  end
  if header.channels == nil then
    error("DEPTH not found")
  end
  if header.max == nil then
    error("MAXVAL not found")
  end
  return header
end

function class:read_pnm(magic)
  local header = self:read_pnm_header(magic)
  if magic:find("P[56]") then
    return self:read_raw(header)
  else
    return self:read_plain(header)
  end
end

function class:read_pam()
  return self:read_raw(self:read_pam_header())
end

function class:apply()
  local this = self.this
  local magic = this:read(2)
  if magic:find("P[2356]") then
    if this:read(1):find("%s") then
      return self:read_pnm(magic)
    end
  elseif magic == "P7" then
    if this:read(1) == "\n" then
      return self:read_pam()
    end
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
