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

function class:raise(message)
  local this = self.this
  if message == nil then
    error("read error at position " .. this:seek())
  else
    error(message .. " at position " .. this:seek())
  end
end

function class:plain(header)
  local this = self.this
  local image = sequence()
  local n = header.width * header.height * header.channels
  local maxval = header.maxval
  for i = 1, n do
    local value = this:read("*n")
    if 0 <= value and value <= maxval and value % 1 == 0 then
      image[i] = value
    else
      self:raise()
    end
  end
  return { header, image }
end

function class:raw(header)
  local this = self.this
  local image = sequence()
  local maxval = header.maxval
  if maxval < 256 then
    local n = header.width * header.height * header.channels
    for i = 3, n, 4 do
      image:push(this:read(4):byte(1, 4))
    end
    local m = n % 4
    if m > 0 then
      image:push(this:read(m):byte(1, m))
    end
  else
    local n = header.width * header.height * header.channels
    for i = 1, n, 2 do
      local a, b, c, d = this:read(4):byte(1, 4)
      image:push(a * 256 + b, c * 256 + d)
    end
    local m = n % 2
    if m > 0 then
      local a, b = this:read(2):byte(1, 2)
      image:push(a * 256 + b)
    end
  end
  return { header, image }
end

function class:pnm_header_value()
  local this = self.this
  while true do
    local value = this:read("*n")
    if value == nil then
      local char = this:read(1)
      if char == "#" then
        this:read()
      elseif char:find("%S") then
        self:raise("invalid header")
      end
    else
      if value > 0 and value % 1 == 0 then
        return value
      else
        self:raise()
      end
    end
  end
end

function class:pnm_header(magic)
  local this = self.this
  local header = linked_hash_table()
  header.width = self:pnm_header_value()
  header.height = self:pnm_header_value()
  header.maxval = self:pnm_header_value()
  if this:read(1):find("%S") then
    self:raise()
  end
  if magic:find("P[25]") then
    header.channels = 1
  else
    header.channels = 3
  end
  return header
end

function class:pam_header()
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
          self:raise("unsupported DEPTH")
        end
      elseif token == "MAXVAL" then
        header.maxval = value
      else
        self:raise("invalid header")
      end
    end
  end
  if header.width == nil then
    self:raise("WIDTH not found")
  end
  if header.height == nil then
    self:raise("HEIGHT not found")
  end
  if header.channels == nil then
    self:raise("DEPTH not found")
  end
  if header.maxval == nil then
    self:raise("MAXVAL not found")
  end
  return header
end

function class:pnm(magic)
  local header = self:pnm_header(magic)
  if magic:find("P[56]") then
    return self:raw(header)
  else
    return self:plain(header)
  end
end

function class:pam()
  return self:raw(self:pam_header())
end

function class:apply()
  local this = self.this
  local magic = this:read(2)
  if magic:find("P[2356]") then
    if this:read(1):find("%s") then
      return self:pnm(magic)
    end
  elseif magic == "P7" then
    if this:read(1) == "\n" then
      return self:pam()
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
