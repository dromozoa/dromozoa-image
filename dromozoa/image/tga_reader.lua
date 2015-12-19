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

function class:read_uint8(n)
  if n == nil then
    n = 1
  end
  return self.this:read(n):byte(1, n)
end

function class:read_uint16(n)
  return uint16.read(self.this, n, "<")
end

function class:apply()
  local this = self.this

  local id_length = self:read_uint8()
  local color_map_type = self:read_uint8()
  local image_type_code = self:read_uint8()
  -- print(id_length, color_map_type, image_type_code)

  local color_map_origin = self:read_uint16()
  local color_map_length = self:read_uint16()
  local color_map_entry_size = self:read_uint8()
  -- print(color_map_origin, color_map_length, color_map_entry_size)

  local x_origin_image = self:read_uint16()
  local y_origin_image = self:read_uint16()
  local width  = self:read_uint16()
  local height = self:read_uint16()
  local image_pixel_size = self:read_uint8()
  local image_desc = self:read_uint8()
  -- print(x_origin_image, y_origin_image, width, height, image_pixel_size, image_desc)

  if id_length ~= 0 then
    this:seek(id_length)
  end

  assert(color_map_type == 0)

  local buffer;

  local i = 0
  local n = width * height * image_pixel_size / 8
  local run_length
  local pixel_bytes = image_pixel_size / 8
  local image = sequence()

  -- print(i, n)

  while i < n do
    local header = self:read_uint8()
    if header < 128 then
      -- raw packet
      local length = header + 1
      -- print("raw-length", length)
      for j = 1, length do
        local b, g, r = this:read(pixel_bytes):byte(1, pixel_bytes)
        image:push(r, g, b)
      end
      i = i + pixel_bytes * length
    else
      -- run length packet
      local length = header - 127
      -- print("run-length", length)
      local b, g, r = this:read(pixel_bytes):byte(1, pixel_bytes)
      for j = 1, length do
        image:push(r, g, b)
      end
      i = i + pixel_bytes * length
    end
  end

  local header = linked_hash_table()
  header.width = width
  header.height = height
  header.channels = pixel_bytes
  header.maxval = 255
  return { header, image }
end

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function (_, this)
    return setmetatable(class.new(this), metatable)
  end;
})
